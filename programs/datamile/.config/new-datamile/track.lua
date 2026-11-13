d.media.type("track")

local function from(ctx, key)
  return d.get(ctx, "manifest." .. key) or d.get(ctx, "audio.tags." .. key)
end

d.compile.track.tag("ctdbid", function(ctx)
  return from(ctx, "ctdbid")
end)

d.compile.track.tag("instrumental", function(ctx)
  return from(ctx, "instrumental")
end)

d.compile.track.tag("replaygain_track_gain", function(ctx)
  return from(ctx, "replaygain_track_gain")
end)

d.compile.track.tag("musicbrainz_releasetrackid", function(ctx)
  return d.get(ctx, "manifest.musicbrainz_releasetrackid") or d.get(ctx, "mb_track.id")
end)

d.compile.track.tag("musicbrainz_recordingid", function(ctx)
  return d.get(ctx, "manifest.musicbrainz_recordingid")
    or d.get(ctx, "mb_track.recording.id")
end)

d.compile.track.tag("musicbrainz_artistid", function(ctx)
  return d.get(ctx, "manifest.musicbrainz_artistid")
    or d.get(ctx, "mb_track.artist-credit.1.artist.id")
end)

d.compile.track.object("embedded", function(ctx)
  if ctx.path == nil then
    return ctx.manifest
  end

  return ctx.audio and ctx.audio.tags
end)

d.compile.track.object("lyrics", function(ctx)
  local path = ctx.lyrics_path
  if not path then
    return nil
  end

  return {
    type = (path:match("%.([^.]+)$") or "txt"):lower(),
    text = d.fs.read(path),
  }
end)
