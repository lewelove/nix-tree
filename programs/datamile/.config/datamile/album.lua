local album = d.media.type("album")

album.lock(function(target)
  return d.fs.joinpath(target.path, "album.lock.json")
end)

album.select(function(scope)
  return d.fs.roots(scope, { marker = "album.toml", prune = false })
end)

album.input("manifest", function(ctx)
  return d.fs.read_toml(d.fs.joinpath(ctx.path, "album.toml"))
end)

album.input("virtual", function(ctx)
  local virtual = d.fs.read_toml(d.fs.joinpath(ctx.path, "virtual.toml"))
  return d.get(virtual, "album.virtual") == true
end)

album.input("history", function(ctx)
  return d.fs.read_toml(d.fs.joinpath(ctx.path, "history.toml"))
end)

album.input("discogs", function(ctx)
  return d.fs.read_json(d.fs.joinpath(ctx.path, "Info/discogs_master.json"))
end)

album.input("mb_release", function(ctx)
  return d.fs.read_json(d.fs.joinpath(ctx.path, "Info/musicbrainz_release.json"))
end)

album.input("cover_metrics", function(ctx)
  return d.fs.read_json(d.fs.joinpath(ctx.path, "Info/cover_metrics.json"))
end)

-- All lyric files for the album, read once per album.
local function list_lyrics(album_path)
  local files = {}
  for _, dirname in ipairs({ "Lyrics", "lyrics" }) do
    local dir = d.fs.joinpath(album_path, dirname)
    if d.fs.exists(dir) then
      for rel, kind in d.fs.dir(dir, { depth = 1 }) do
        local ext = rel:match("%.([^.]+)$")
        if kind == "file" and (ext == "lrc" or ext == "txt") then
          table.insert(files, d.fs.joinpath(dir, rel))
        end
      end
    end
  end
  return files
end

local function lyrics_patterns(disc, number, total_discs)
  local patterns = {}
  if total_discs > 1 then
    table.insert(patterns, string.format("^0*%d%%.0*%d[%%s%%._%%-]", disc, number))
    table.insert(patterns, string.format("^0*%d%%-0*%d[%%s%%._%%-]", disc, number))
    table.insert(patterns, string.format("^%d%02d[%%s%%._%%-]", disc, number))
  end
  table.insert(patterns, string.format("^0*%d[%%s%%._%%-]", number))
  return patterns
end

local function find_lyrics(files, patterns)
  for _, file in ipairs(files) do
    local name = d.fs.basename(file)
    for _, pattern in ipairs(patterns) do
      if name:find(pattern) then
        return file
      end
    end
  end
  return nil
end

-- MusicBrainz track lookup keyed by "disc:number", built once per album.
local function index_mb(release)
  local index = {}
  for _, medium in ipairs(d.get(release, "media") or {}) do
    local position = tonumber(d.get(medium, "position")) or 1
    for _, track in ipairs(d.get(medium, "tracks") or {}) do
      local number = tonumber(d.get(track, "position")) or 0
      index[position .. ":" .. number] = track
    end
  end
  return index
end

-- One harvest pass per album; each track seed carries its audio, MusicBrainz
-- track and lyric file downward.
album.child("tracks", "track", function(ctx)
  if ctx.virtual then
    local album_meta = d.get(ctx, "manifest.album") or {}
    local seeds = {}
    for _, entry in ipairs(d.get(ctx, "manifest.tracks") or {}) do
      table.insert(seeds, { manifest = d.tbl.extend("force", album_meta, entry) })
    end
    return seeds
  end

  local seeds = d.media.select("track", { path = ctx.path, recursive = true })

  local discs = {}
  for _, seed in ipairs(seeds) do
    discs[tostring(d.get(seed.audio, "tags.discnumber") or 1)] = true
  end

  local total_discs = math.max(d.tbl.count(discs), 1)
  local lyrics = list_lyrics(ctx.path)
  local mb = index_mb(ctx.mb_release)

  for _, seed in ipairs(seeds) do
    local disc = tonumber(d.get(seed.audio, "tags.discnumber")) or 1
    local number = tonumber(d.get(seed.audio, "tags.tracknumber")) or 0
    seed.mb_track = mb[disc .. ":" .. number]
    seed.lyrics_path = find_lyrics(lyrics, lyrics_patterns(disc, number, total_discs))
  end

  return seeds
end)

album.id(function(ctx)
  local media = d.get(REGISTRY.config, "storage.media_directory")
  if not media or media == "" then
    return nil
  end

  return d.fs.relpath(media, ctx.path)
end)

album.location(function(ctx)
  local stat = d.fs.stat(ctx.path)
  if not stat then
    return nil
  end

  return { kind = "directory", path = ctx.path, mtime = stat.mtime }
end)

album.tag("albumartist", function(ctx)
  return d.get(ctx, "manifest.album.albumartist")
    or d.get(ctx, "manifest.album.artist")
end)

album.tag("album", function(ctx)
  return d.get(ctx, "manifest.album.album")
end)

album.tag("date", function(ctx)
  return d.get(ctx, "manifest.album.date")
    or d.get(ctx, "manifest.album.release_date")
end)

album.tag("albumartists", function(ctx)
  return d.get(ctx, "manifest.album.albumartists")
end)

album.tag("media", function(ctx)
  return d.get(ctx, "manifest.album.media")
end)

album.tag("collection", function(ctx)
  return d.get(ctx, "manifest.album.collection")
end)

album.tag("shelves", function(ctx)
  return d.get(ctx, "manifest.album.shelves")
end)

album.tag("my_year", function(ctx)
  return d.get(ctx, "manifest.album.my_year")
end)

album.tag("replaygain_album_gain", function(ctx)
  return d.get(ctx, "manifest.album.replaygain_album_gain")
end)

album.tag("genre", function(ctx)
  return d.fn.coalesce(d.get(ctx, "manifest.album.genre"), { "Unknown" })
end)

album.tag("styles", function(ctx)
  return d.get(ctx, "discogs.styles")
end)

album.tag("comment", function(ctx)
  local country = d.get(ctx, "manifest.album.country") or ""
  local label = d.get(ctx, "manifest.album.label") or ""
  local catalog = d.get(ctx, "manifest.album.catalognumber") or ""

  if country ~= "" or label ~= "" or catalog ~= "" then
    local date = d.get(ctx, "manifest.album.release_date")
    local year = date and date:sub(1, 4) or ""
    local parts = {}
    if year ~= "" then table.insert(parts, year) end
    if country ~= "" then table.insert(parts, country) end
    if label ~= "" then table.insert(parts, label) end
    if catalog ~= "" then table.insert(parts, catalog) end
    return table.concat(parts, " ")
  end

  return d.get(ctx, "manifest.album.comment")
end)

album.tag("custom_albumartist", function(ctx)
  return d.fn.coalesce(
    d.get(ctx, "manifest.album.custom_albumartist"),
    d.get(ctx, "manifest.album.artistartist"),
    d.get(ctx, "manifest.album.albumartist")
  )
end)

album.tag("cover_chroma", function(ctx)
  return d.get(ctx, "cover_metrics.chroma")
end)

album.tag("cover_entropy", function(ctx)
  return d.get(ctx, "cover_metrics.entropy")
end)

album.tag("path", function(ctx)
  return d.fs.relpath(REGISTRY.config.storage.media_directory, ctx.path)
end)

album.tag("musicbrainz_albumid", function(ctx)
  return d.get(ctx, "mb_release.id") or d.get(ctx, "manifest.album.musicbrainz_albumid")
end)

album.tag("musicbrainz_releasegroupid", function(ctx)
  return d.get(ctx, "mb_release.release-group.id")
    or d.get(ctx, "manifest.album.musicbrainz_releasegroupid")
end)

album.tag("musicbrainz_albumartistid", function(ctx)
  return d.get(ctx, "mb_release.artist-credit.1.artist.id")
    or d.get(ctx, "manifest.album.musicbrainz_albumartistid")
end)

album.tag("musicbrainz_releasetype", function(ctx)
  local primary = d.get(ctx, "mb_release.release-group.primary-type")
  local secondary = d.get(ctx, "mb_release.release-group.secondary-types")
  if primary and secondary and #secondary > 0 then
    return primary .. "; " .. table.concat(secondary, "; ")
  end
  return primary or d.get(ctx, "manifest.album.musicbrainz_releasetype")
end)

album.tag("releasecountry", function(ctx)
  return d.get(ctx, "mb_release.country") or d.get(ctx, "manifest.album.country")
end)

album.tag("label", function(ctx)
  return d.get(ctx, "mb_release.label-info.1.label.name") or d.get(ctx, "manifest.album.label")
end)

album.tag("catalognumber", function(ctx)
  return d.get(ctx, "mb_release.label-info.1.catalog-number")
    or d.get(ctx, "manifest.album.catalognumber")
end)

album.tag("date_added_foobar", function(ctx)
  return d.fn.type_check(d.get(ctx, "history.album.date_added_foobar"), "datetime")
end)

album.tag("date_added_applemusic", function(ctx)
  return d.fn.type_check(d.get(ctx, "history.album.date_added_applemusic"), "datetime")
end)

album.tag("date_added_youtube", function(ctx)
  return d.fn.type_check(d.get(ctx, "history.album.date_added_youtube"), "datetime")
end)

album.tag("date_added_datamile", function(ctx)
  return d.fn.type_check(d.get(ctx, "history.album.date_added_datamile"), "datetime")
end)

album.tag("date_added_applemusic_unknown", function(ctx)
  return d.fn.type_check(d.get(ctx, "history.album.date_added_applemusic_unknown"), "datetime")
end)

album.tag("date_added_datamile_unknown", function(ctx)
  return d.fn.type_check(d.get(ctx, "history.album.date_added_datamile_unknown"), "datetime")
end)

album.tag("date_added", function(ctx)
  local keys = {
    "date_added_youtube",
    "date_added_applemusic",
    "date_added_foobar",
    "date_added_datamile",
    "date_added_applemusic_unknown",
    "date_added_datamile_unknown",
  }

  local earliest = nil
  for _, key in ipairs(keys) do
    local value = d.get(ctx, "history.album." .. key)
    if value and value ~= "" and (not earliest or value < earliest) then
      earliest = value
    end
  end

  return earliest
end)

album.object("info", function(ctx)
  local tracks = ctx.tracks or {}
  local discs = {}

  for _, item in ipairs(tracks) do
    discs[tostring(d.get(item, "tags.discnumber") or 1)] = true
  end

  local duration = d.list.sum(tracks, function(item)
    return d.get(item, "objects.info.duration_milliseconds") or 0
  end)

  return {
    virtual = ctx.virtual,
    total_tracks = #tracks,
    total_discs = math.max(d.tbl.count(discs), 1),
    duration_milliseconds = duration,
    duration_formatted = d.fmt.clock(duration),
  }
end)

local function is_hex_color(value)
  if type(value) ~= "string" then
    return false
  end

  local digits = value:match("^#(%x+)$")
  return digits ~= nil and ({ 3, 4, 6, 8 })[#digits] == true
end

local function color_list(value)
  if type(value) == "string" then
    value = { value }
  end
  if type(value) ~= "table" then
    return nil
  end

  local colors = {}
  for _, item in ipairs(value) do
    if is_hex_color(item) then
      table.insert(colors, item)
    end
  end

  return #colors > 0 and colors or nil
end

album.object("colors", function(ctx)
  local theme = d.fs.read_toml(d.fs.joinpath(ctx.path, "theme.toml"))
  local raw = d.get(theme, "album.colors")
  if type(raw) ~= "table" then
    return nil
  end

  local colors = { background = color_list(raw.background) }
  if is_hex_color(raw.foreground) then
    colors.foreground = raw.foreground
  end
  if not colors.background and not colors.foreground then
    return nil
  end

  return colors
end)

album.image("main", function(ctx)
  local cover = d.fs.first(ctx.path, {
    "cover.png",
    "cover.jpg",
    "cover.jpeg",
    "folder.png",
    "folder.jpg",
    "folder.jpeg",
  })
  if not cover then
    return nil
  end

  return {
    fit = { "crop", 1080, 1080 },
    filter = "catmullrom",
    sources = d.fs.basename(cover),
  }
end)

album.object("manifests", function(ctx)
  local result = {}

  for _, name in ipairs({ "album", "history", "id", "local", "theme", "virtual" }) do
    local file = d.fs.joinpath(ctx.path, name .. ".toml")
    if d.fs.exists(file) then
      local stat = d.fs.stat(file)
      result[name] = {
        file = {
          path = d.fs.relpath(ctx.path, file),
          mtime = stat.mtime,
          byte_size = stat.byte_size,
        },
      }
    end
  end

  return result
end)

album.object("verified", function(ctx)
  for _, field in ipairs({ "albumartist", "album", "date" }) do
    local meta = d.get(ctx, "manifest.album." .. field)
    local hist = d.get(ctx, "history.album." .. field)
    if hist and meta and meta ~= hist then
      error(string.format("%s diverged! Metadata: '%s' | History: '%s'", field, tostring(meta), tostring(hist)))
    end
  end

  return true
end)
