local track = d.media.type("track")

local function audio_extensions()
  local configured = d.get(REGISTRY.config, "compiler.audio_extensions")
    or d.get(REGISTRY.config, "manifest.audio_extensions")
  if type(configured) == "table" and #configured > 0 then
    return configured
  end

  return d.fs.audio_extensions()
end

local function harvest(path)
  local seeds = {}
  for _, file in ipairs(d.fs.files(path, { ext = audio_extensions() })) do
    table.insert(seeds, { path = file, audio = d.fs.read_audio(file) })
  end

  return d.list.sort_by(seeds, function(item)
    return {
      d.str.leading_int(d.get(item.audio, "tags.discnumber")) or 1,
      d.str.leading_int(d.get(item.audio, "tags.tracknumber")) or math.huge,
      item.path,
    }
  end)
end

track.select(function(scope)
  return harvest(scope.path)
end)

track.input("audio", function(ctx)
  if ctx.audio ~= nil then
    return ctx.audio
  end
  if ctx.path == nil then
    return nil
  end

  return d.fs.read_audio(ctx.path)
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

track.location(function(ctx)
  if ctx.path == nil then
    return nil
  end

  local stat = d.fs.stat(ctx.path)
  if not stat then
    return nil
  end

  return {
    kind = "file",
    path = ctx.path,
    mtime = stat.mtime,
    byte_size = stat.byte_size,
  }
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
