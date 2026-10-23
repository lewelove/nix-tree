dale.compile.album.key("albumartists", function(ctx, m)
  return d.get(m, "metadata.album.albumartists")
end)

dale.compile.album.key("media", function(ctx, m)
  return d.get(m, "metadata.album.media")
end)

dale.compile.album.key("collection", function(ctx, m)
  return d.get(m, "metadata.album.collection")
end)

dale.compile.album.key("shelves", function(ctx, m)
  return d.get(m, "metadata.album.shelves")
end)

dale.compile.album.key("my_year", function(ctx, m)
  return d.get(m, "metadata.album.my_year")
end)

dale.compile.album.key("replaygain_album_gain", function(ctx, m)
  return d.get(m, "metadata.album.replaygain_album_gain")
end)

dale.compile.album.key("genre", function(ctx, m)
  local genre = d.get(m, "metadata.album.genre")
  return d.fn.coalesce(genre, { "Unknown" })
end)

dale.compile.album.key("styles", function(ctx, m)
  local root = d.get(ctx, "paths.album_root")
  local discogs = root and d.fs.read_json(root .. "/Info/discogs_master.json")
  return d.get(discogs, "styles")
end)

dale.compile.album.key("comment", function(ctx, m)
  local country = d.get(m, "metadata.album.country") or ""
  local label = d.get(m, "metadata.album.label") or ""
  local cat = d.get(m, "metadata.album.catalognumber") or ""

  if country ~= "" or label ~= "" or cat ~= "" then
    local date = d.get(m, "metadata.album.release_date")
    local year = date and date:sub(1, 4) or ""
    local parts = {}
    if year ~= "" then table.insert(parts, year) end
    if country ~= "" then table.insert(parts, country) end
    if label ~= "" then table.insert(parts, label) end
    if cat ~= "" then table.insert(parts, cat) end
    return table.concat(parts, " ")
  end

  local c = d.get(m, "metadata.album.comment")
  return d.fn.type_check(c, "string")
end)

dale.compile.album.key("custom_albumartist", function(ctx, m)
  local custom = d.get(m, "metadata.album.custom_albumartist")
  local artistartist = d.get(m, "metadata.album.artistartist")
  local albumartist = d.get(m, "metadata.album.albumartist")
  return d.fn.coalesce(custom, artistartist, albumartist)
end)

dale.compile.album.key("cover_chroma", function(ctx, m)
  local root = d.get(ctx, "paths.album_root")
  local metrics = root and d.fs.read_json(root .. "/Info/cover_metrics.json")
  return d.get(metrics, "chroma")
end)

dale.compile.album.key("cover_entropy", function(ctx, m)
  local root = d.get(ctx, "paths.album_root")
  local metrics = root and d.fs.read_json(root .. "/Info/cover_metrics.json")
  return d.get(metrics, "entropy")
end)

dale.compile.album.key("path", function(ctx, m)
  return ctx.paths.rel_path
end)

dale.compile.tracks.key("ctdbid", function(ctx, m, i)
  local val = d.get(m, "metadata.tracks", i, "ctdbid")
  return d.fn.type_check(val, "string")
end)

dale.compile.tracks.key("instrumental", function(ctx, m, i)
  local val = d.get(m, "metadata.tracks", i, "instrumental")
  return d.fn.type_check(val, "boolean")
end)

dale.compile.tracks.key("replaygain_track_gain", function(ctx, m, i)
  local val = d.get(m, "metadata.tracks", i, "replaygain_track_gain")
  return d.fn.type_check(val, "string")
end)

dale.compile.tracks.key("embedded", function(ctx, m, i)
  return d.get(ctx, "tracks", i, "embedded")
end)
