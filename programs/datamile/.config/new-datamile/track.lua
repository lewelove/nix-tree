d.media.type("track")

d.compile.track.id(function(_, tags)
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

d.compile.track.location(function(source)
  if not source.path then
    return nil
  end

  local stat = d.fs.stat(source.path)

  return {
    kind = "file",
    path = source.path,
    mtime = stat.mtime,
    byte_size = stat.byte_size,
  }
end)

d.compile.track.tag("ctdbid", function(source)
  return d.get(source, "data.ctdbid")
    or d.get(d.fs.read_audio(source.path), "tags.ctdbid")
end)

d.compile.track.tag("instrumental", function(source)
  return d.get(source, "data.instrumental")
    or d.get(d.fs.read_audio(source.path), "tags.instrumental")
end)

d.compile.track.tag("replaygain_track_gain", function(source)
  return d.get(source, "data.replaygain_track_gain")
    or d.get(d.fs.read_audio(source.path), "tags.replaygain_track_gain")
end)

d.compile.track.tag("musicbrainz_releasetrackid", function(source)
  local from_manifest = d.get(source, "data.musicbrainz_releasetrackid")
  if from_manifest then
    return from_manifest
  end

  if not source.path then
    return nil
  end

  local root = d.fs.root(source.path, "album.toml")
  local release = root and d.fs.read_json(d.fs.joinpath(root, "Info/musicbrainz_release.json"))
  if not release or not release.media then return nil end

  local audio = d.fs.read_audio(source.path)
  local disc = tonumber(audio.tags.discnumber) or 1
  local number = tonumber(audio.tags.tracknumber) or 0

  for _, medium in ipairs(release.media) do
    if (tonumber(medium.position) or 1) == disc and medium.tracks then
      for _, track in ipairs(medium.tracks) do
        if (tonumber(track.position) or 0) == number then
          return track.id
        end
      end
    end
  end

  return nil
end)

d.compile.track.tag("musicbrainz_recordingid", function(source)
  local from_manifest = d.get(source, "data.musicbrainz_recordingid")
  if from_manifest then
    return from_manifest
  end

  if not source.path then
    return nil
  end

  local root = d.fs.root(source.path, "album.toml")
  local release = root and d.fs.read_json(d.fs.joinpath(root, "Info/musicbrainz_release.json"))
  if not release or not release.media then return nil end

  local audio = d.fs.read_audio(source.path)
  local disc = tonumber(audio.tags.discnumber) or 1
  local number = tonumber(audio.tags.tracknumber) or 0

  for _, medium in ipairs(release.media) do
    if (tonumber(medium.position) or 1) == disc and medium.tracks then
      for _, track in ipairs(medium.tracks) do
        if (tonumber(track.position) or 0) == number then
          return d.get(track, "recording.id")
        end
      end
    end
  end

  return nil
end)

d.compile.track.tag("musicbrainz_artistid", function(source)
  local from_manifest = d.get(source, "data.musicbrainz_artistid")
  if from_manifest then
    return from_manifest
  end

  if not source.path then
    return nil
  end

  local root = d.fs.root(source.path, "album.toml")
  local release = root and d.fs.read_json(d.fs.joinpath(root, "Info/musicbrainz_release.json"))
  if not release or not release.media then return nil end

  local audio = d.fs.read_audio(source.path)
  local disc = tonumber(audio.tags.discnumber) or 1
  local number = tonumber(audio.tags.tracknumber) or 0

  for _, medium in ipairs(release.media) do
    if (tonumber(medium.position) or 1) == disc and medium.tracks then
      for _, track in ipairs(medium.tracks) do
        if (tonumber(track.position) or 0) == number then
          return d.get(track, "artist-credit.1.artist.id")
        end
      end
    end
  end

  return nil
end)

d.compile.track.object("embedded", function(source)
  if not source.path then
    return source.data
  end

  return d.fs.read_audio(source.path).tags
end)

d.compile.track.object("lyrics", function(source)
  if not source.path then
    return nil
  end

  local root = d.fs.root(source.path, "album.toml")
  if not root then return nil end

  local audio = d.fs.read_audio(source.path)
  local disc = tonumber(audio.tags.discnumber) or 1
  local number = tonumber(audio.tags.tracknumber) or 0
  local discs = {}

  for _, other_path in ipairs(d.media.select("track", { path = root })) do
    if other_path.path then
      local other = d.fs.read_audio(other_path.path)
      discs[tostring(other.tags.discnumber or "1")] = true
    end
  end

  local total_discs = 0
  for _ in pairs(discs) do total_discs = total_discs + 1 end
  if total_discs < 1 then total_discs = 1 end

  local patterns = {}
  if total_discs > 1 then
    table.insert(patterns, string.format("^0*%d%%.0*%d[%%s%%._%%-]", disc, number))
    table.insert(patterns, string.format("^0*%d%%-0*%d[%%s%%._%%-]", disc, number))
    table.insert(patterns, string.format("^%d%02d[%%s%%._%%-]", disc, number))
  end
  table.insert(patterns, string.format("^0*%d[%%s%%._%%-]", number))

  local matches = d.fs.find(function(name)
    local ext = name:match("%.([^.]+)$")
    if ext ~= "lrc" and ext ~= "txt" then
      return false
    end
    for _, pattern in ipairs(patterns) do
      if name:find(pattern) then
        return true
      end
    end
    return false
  end, {
    path = d.fs.joinpath(root, "Lyrics"),
    type = "file",
    depth = 1,
    limit = 1,
  })

  if #matches == 0 then
    matches = d.fs.find(function(name)
      local ext = name:match("%.([^.]+)$")
      if ext ~= "lrc" and ext ~= "txt" then
        return false
      end
      for _, pattern in ipairs(patterns) do
        if name:find(pattern) then
          return true
        end
      end
      return false
    end, {
      path = d.fs.joinpath(root, "lyrics"),
      type = "file",
      depth = 1,
      limit = 1,
    })
  end

  if #matches == 0 then return nil end

  return {
    type = (matches[1]:match("%.([^.]+)$") or "txt"):lower(),
    text = d.fs.read(matches[1]),
  }
end)
