local function audio_extensions()
  local configured = d.get(REGISTRY.config, "compiler.audio_extensions")
    or d.get(REGISTRY.config, "manifest.audio_extensions")
  if type(configured) == "table" and #configured > 0 then
    return configured
  end

  return d.fs.audio_extensions()
end

local function harvest(path)
  local files = {}
  for _, file in ipairs(d.fs.files(path, { ext = audio_extensions() })) do
    table.insert(files, { path = file, audio = d.fs.read_audio(file) })
  end

  local sorted = d.list.sort_by(files, function(item)
    return {
      d.str.leading_int(d.get(item.audio, "tags.discnumber")) or 1,
      d.str.leading_int(d.get(item.audio, "tags.tracknumber")) or math.huge,
      item.path,
    }
  end)

  local paths = {}
  for _, item in ipairs(sorted) do
    table.insert(paths, item.path)
  end

  return paths
end

local track = d.media("track", {
  kind = { "file", "virtual" },
  select = function(parent)
    if parent.virtual then
      local album_meta = d.get(parent, "manifest.album") or {}
      local seeds = {}
      for _, entry in ipairs(d.get(parent, "manifest.tracks") or {}) do
        table.insert(seeds, { manifest = d.tbl.extend("force", album_meta, entry) })
      end
      return seeds
    end

    return harvest(parent.path)
  end,
})

local function disc_number(ctx)
  return tonumber(d.get(ctx, "audio.tags.discnumber"))
    or tonumber(d.get(ctx, "manifest.discnumber"))
    or 1
end

local function track_number(ctx)
  return tonumber(d.get(ctx, "audio.tags.tracknumber"))
    or tonumber(d.get(ctx, "manifest.tracknumber"))
    or 0
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

track.input("audio", function(ctx)
  if ctx.path == nil then
    return nil
  end

  return d.fs.read_audio(ctx.path)
end)

track.input("mb_track", function(ctx)
  if ctx.path == nil then
    return nil
  end

  local index = d.get(ctx, "parent.mb_index") or {}
  local key = disc_number(ctx) .. ":" .. track_number(ctx)
  return index[key]
end)

track.input("lyrics_path", function(ctx)
  if ctx.path == nil then
    return nil
  end

  local files = d.get(ctx, "parent.lyrics_files") or {}
  local total_discs = d.get(ctx, "parent.total_discs") or 1
  return find_lyrics(files, lyrics_patterns(disc_number(ctx), track_number(ctx), total_discs))
end)

track.file("lyrics", function(ctx)
  return ctx.lyrics_path
end)

track.id(function(ctx)
  local tags = ctx.tags
  local disc = tonumber(tags.discnumber or 1)
  local number = tostring(tags.tracknumber or "")
  if disc > 1 then
    number = tostring(tags.discnumber) .. "." .. number
  end

  return table.concat({
    tags.albumartist or tags.artist or "",
    tags.album or "",
    number,
    tags.title or "",
  }, " - ")
end)

local function from(ctx, key)
  return d.get(ctx, "manifest." .. key) or d.get(ctx, "audio.tags." .. key)
end

for _, key in ipairs({
  "artist",
  "albumartist",
  "album",
  "title",
  "tracknumber",
  "discnumber",
  "date",
  "genre",
  "composer",
}) do
  track.tag(key, function(ctx)
    return from(ctx, key)
  end)
end

track.object("info", function(ctx)
  local audio = ctx.audio
  if not audio then
    return {
      sample_rate = 0,
      bits_per_sample = 0,
      bitrate_kbps = 0,
      encoding = "virtual",
      channels = 0,
      duration_milliseconds = 0,
      duration_formatted = "0:00",
    }
  end

  return {
    sample_rate = audio.sample_rate,
    bits_per_sample = audio.bit_depth or 0,
    bitrate_kbps = audio.audio_bitrate or 0,
    encoding = audio.format,
    channels = audio.channels or 0,
    duration_milliseconds = audio.duration_milliseconds or 0,
    duration_formatted = d.fmt.clock(audio.duration_milliseconds or 0),
  }
end)

track.tag("ctdbid", function(ctx)
  return from(ctx, "ctdbid")
end)

track.tag("instrumental", function(ctx)
  return from(ctx, "instrumental")
end)

track.tag("replaygain_track_gain", function(ctx)
  return from(ctx, "replaygain_track_gain")
end)

track.tag("musicbrainz_releasetrackid", function(ctx)
  return d.get(ctx, "manifest.musicbrainz_releasetrackid") or d.get(ctx, "mb_track.id")
end)

track.tag("musicbrainz_recordingid", function(ctx)
  return d.get(ctx, "manifest.musicbrainz_recordingid")
    or d.get(ctx, "mb_track.recording.id")
end)

track.tag("musicbrainz_artistid", function(ctx)
  return d.get(ctx, "manifest.musicbrainz_artistid")
    or d.get(ctx, "mb_track.artist-credit.1.artist.id")
end)

track.object("embedded", function(ctx)
  if ctx.path == nil then
    return ctx.manifest
  end

  return ctx.audio and ctx.audio.tags
end)

track.object("lyrics", function(ctx)
  local path = ctx.lyrics_path
  if not path then
    return nil
  end

  return {
    type = d.fs.ext(path) or "txt",
    text = d.fs.read(path),
  }
end)
