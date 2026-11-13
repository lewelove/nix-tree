d.media.type("album")

d.compile.album.tag("albumartists", function(source)
  return d.get(d.fs.read_toml(d.fs.joinpath(source.path, "album.toml")), "album.albumartists")
end)

d.compile.album.tag("media", function(source)
  return d.get(d.fs.read_toml(d.fs.joinpath(source.path, "album.toml")), "album.media")
end)

d.compile.album.tag("collection", function(source)
  return d.get(d.fs.read_toml(d.fs.joinpath(source.path, "album.toml")), "album.collection")
end)

d.compile.album.tag("shelves", function(source)
  return d.get(d.fs.read_toml(d.fs.joinpath(source.path, "album.toml")), "album.shelves")
end)

d.compile.album.tag("my_year", function(source)
  return d.get(d.fs.read_toml(d.fs.joinpath(source.path, "album.toml")), "album.my_year")
end)

d.compile.album.tag("replaygain_album_gain", function(source)
  return d.get(d.fs.read_toml(d.fs.joinpath(source.path, "album.toml")), "album.replaygain_album_gain")
end)

d.compile.album.tag("genre", function(source)
  return d.fn.coalesce(
    d.get(d.fs.read_toml(d.fs.joinpath(source.path, "album.toml")), "album.genre"),
    { "Unknown" }
  )
end)

d.compile.album.tag("styles", function(source)
  return d.get(d.fs.read_json(d.fs.joinpath(source.path, "Info/discogs_master.json")), "styles")
end)

d.compile.album.tag("comment", function(source)
  local manifest = d.fs.read_toml(d.fs.joinpath(source.path, "album.toml"))
  local country = d.get(manifest, "album.country") or ""
  local label = d.get(manifest, "album.label") or ""
  local catalog = d.get(manifest, "album.catalognumber") or ""

  if country ~= "" or label ~= "" or catalog ~= "" then
    local date = d.get(manifest, "album.release_date")
    local year = date and date:sub(1, 4) or ""
    local parts = {}
    if year ~= "" then table.insert(parts, year) end
    if country ~= "" then table.insert(parts, country) end
    if label ~= "" then table.insert(parts, label) end
    if catalog ~= "" then table.insert(parts, catalog) end
    return table.concat(parts, " ")
  end

  return d.get(manifest, "album.comment")
end)

d.compile.album.tag("custom_albumartist", function(source)
  local manifest = d.fs.read_toml(d.fs.joinpath(source.path, "album.toml"))
  return d.fn.coalesce(
    d.get(manifest, "album.custom_albumartist"),
    d.get(manifest, "album.artistartist"),
    d.get(manifest, "album.albumartist")
  )
end)

d.compile.album.tag("cover_chroma", function(source)
  return d.get(d.fs.read_json(d.fs.joinpath(source.path, "Info/cover_metrics.json")), "chroma")
end)

d.compile.album.tag("cover_entropy", function(source)
  return d.get(d.fs.read_json(d.fs.joinpath(source.path, "Info/cover_metrics.json")), "entropy")
end)

d.compile.album.tag("path", function(source)
  return d.fs.relpath(REGISTRY.config.storage.music_directory, source.path)
end)

d.compile.album.tag("musicbrainz_albumid", function(source)
  local release = d.fs.read_json(d.fs.joinpath(source.path, "Info/musicbrainz_release.json"))
  local manifest = d.fs.read_toml(d.fs.joinpath(source.path, "album.toml"))
  return d.get(release, "id") or d.get(manifest, "album.musicbrainz_albumid")
end)

d.compile.album.tag("musicbrainz_releasegroupid", function(source)
  local release = d.fs.read_json(d.fs.joinpath(source.path, "Info/musicbrainz_release.json"))
  local manifest = d.fs.read_toml(d.fs.joinpath(source.path, "album.toml"))
  return d.get(release, "release-group.id") or d.get(manifest, "album.musicbrainz_releasegroupid")
end)

d.compile.album.tag("musicbrainz_albumartistid", function(source)
  local release = d.fs.read_json(d.fs.joinpath(source.path, "Info/musicbrainz_release.json"))
  local manifest = d.fs.read_toml(d.fs.joinpath(source.path, "album.toml"))
  return d.get(release, "artist-credit.1.artist.id") or d.get(manifest, "album.musicbrainz_albumartistid")
end)

d.compile.album.tag("musicbrainz_releasetype", function(source)
  local release = d.fs.read_json(d.fs.joinpath(source.path, "Info/musicbrainz_release.json"))
  local primary = d.get(release, "release-group.primary-type")
  local secondary = d.get(release, "release-group.secondary-types")
  if primary and secondary and #secondary > 0 then
    return primary .. "; " .. table.concat(secondary, "; ")
  end
  return primary or d.get(d.fs.read_toml(d.fs.joinpath(source.path, "album.toml")), "album.musicbrainz_releasetype")
end)

d.compile.album.tag("releasecountry", function(source)
  local release = d.fs.read_json(d.fs.joinpath(source.path, "Info/musicbrainz_release.json"))
  local manifest = d.fs.read_toml(d.fs.joinpath(source.path, "album.toml"))
  return d.get(release, "country") or d.get(manifest, "album.country")
end)

d.compile.album.tag("label", function(source)
  local release = d.fs.read_json(d.fs.joinpath(source.path, "Info/musicbrainz_release.json"))
  local manifest = d.fs.read_toml(d.fs.joinpath(source.path, "album.toml"))
  return d.get(release, "label-info.1.label.name") or d.get(manifest, "album.label")
end)

d.compile.album.tag("catalognumber", function(source)
  local release = d.fs.read_json(d.fs.joinpath(source.path, "Info/musicbrainz_release.json"))
  local manifest = d.fs.read_toml(d.fs.joinpath(source.path, "album.toml"))
  return d.get(release, "label-info.1.catalog-number") or d.get(manifest, "album.catalognumber")
end)

d.compile.album.tag("date_added_foobar", function(source)
  local history = d.fs.read_toml(d.fs.joinpath(source.path, "history.toml"))
  return d.fn.type_check(d.get(history, "album.date_added_foobar"), "datetime")
end)

d.compile.album.tag("date_added_applemusic", function(source)
  local history = d.fs.read_toml(d.fs.joinpath(source.path, "history.toml"))
  return d.fn.type_check(d.get(history, "album.date_added_applemusic"), "datetime")
end)

d.compile.album.tag("date_added_youtube", function(source)
  local history = d.fs.read_toml(d.fs.joinpath(source.path, "history.toml"))
  return d.fn.type_check(d.get(history, "album.date_added_youtube"), "datetime")
end)

d.compile.album.tag("date_added_datamile", function(source)
  local history = d.fs.read_toml(d.fs.joinpath(source.path, "history.toml"))
  return d.fn.type_check(d.get(history, "album.date_added_datamile"), "datetime")
end)

d.compile.album.tag("date_added_applemusic_unknown", function(source)
  local history = d.fs.read_toml(d.fs.joinpath(source.path, "history.toml"))
  return d.fn.type_check(d.get(history, "album.date_added_applemusic_unknown"), "datetime")
end)

d.compile.album.tag("date_added_datamile_unknown", function(source)
  local history = d.fs.read_toml(d.fs.joinpath(source.path, "history.toml"))
  return d.fn.type_check(d.get(history, "album.date_added_datamile_unknown"), "datetime")
end)

d.compile.album.tag("date_added", function(source)
  local history = d.fs.read_toml(d.fs.joinpath(source.path, "history.toml"))
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
    local value = d.get(history, "album." .. key)
    if value and value ~= "" and (not earliest or value < earliest) then
      earliest = value
    end
  end

  return earliest
end)

d.compile.album.object("info", function(source)
  local tracks = d.media.select("track", source)
  local duration = 0
  local discs = {}

  for _, track in ipairs(tracks) do
    local disc = d.get(track, "data.discnumber")
    if not disc and track.path then
      disc = d.get(d.fs.read_audio(track.path), "tags.discnumber")
    end
    discs[tostring(disc or "1")] = true

    if track.path then
      duration = duration + (d.fs.read_audio(track.path).duration_milliseconds or 0)
    end
  end

  local total_discs = 0
  for _ in pairs(discs) do total_discs = total_discs + 1 end
  if total_discs < 1 then total_discs = 1 end

  local total_secs = math.floor(duration / 1000)
  local hours = math.floor(total_secs / 3600)
  local mins = math.floor((total_secs % 3600) / 60)
  local secs = total_secs - (hours * 3600) - (mins * 60)
  local formatted = hours > 0
    and string.format("%d:%02d:%02d", hours, mins, secs)
    or string.format("%d:%02d", mins, secs)

  local virtual_toml = d.fs.joinpath(source.path, "virtual.toml")
  local virtual = d.fs.exists(virtual_toml)
    and d.get(d.fs.read_toml(virtual_toml), "album.virtual") == true
    or false

  return {
    virtual = virtual,
    total_tracks = #tracks,
    total_discs = total_discs,
    duration_milliseconds = duration,
    duration_formatted = formatted,
  }
end)

d.compile.album.object("manifests", function(source)
  local result = {}

  for _, name in ipairs({ "album", "history", "id", "local", "theme", "virtual" }) do
    local file = d.fs.joinpath(source.path, name .. ".toml")
    if d.fs.exists(file) then
      local stat = d.fs.stat(file)
      result[name] = {
        file = {
          path = d.fs.relpath(source.path, file),
          mtime = stat.mtime,
          byte_size = stat.byte_size,
        },
      }
    end
  end

  return result
end)

d.compile.album.object("verified", function(source)
  local manifest = d.fs.read_toml(d.fs.joinpath(source.path, "album.toml"))
  local history = d.fs.read_toml(d.fs.joinpath(source.path, "history.toml"))

  for _, field in ipairs({ "albumartist", "album", "date" }) do
    local meta = d.get(manifest, "album." .. field)
    local hist = d.get(history, "album." .. field)
    if hist and meta and meta ~= hist then
      error(string.format("%s diverged! Metadata: '%s' | History: '%s'", field, tostring(meta), tostring(hist)))
    end
  end

  return true
end)

d.compile.album.images("main", function(source)
  for _, name in ipairs({
    "cover.png",
    "cover.jpg",
    "cover.jpeg",
    "folder.png",
    "folder.jpg",
    "folder.jpeg",
  }) do
    if d.fs.exists(d.fs.joinpath(source.path, name)) then
      return {
        fit = { "crop", 1080, 1080 },
        filter = "catmullrom",
        sources = name,
      }
    end
  end

  return nil
end)

d.compile.album.media("tracks", "track")
