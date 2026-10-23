local function read_mb_json(ctx)
  local root = d.get(ctx, "paths.album_root")
  return root and d.fs.read_json(root .. "/Info/musicbrainz_release.json")
end

local function get_mb_track(ctx, m, i)
  local json = read_mb_json(ctx)
  if not json or not json.media then return nil end

  local disc_no = tonumber(d.get(m, "metadata.tracks", i, "discnumber")) or 1
  local track_no = tonumber(d.get(m, "metadata.tracks", i, "tracknumber")) or i

  for _, medium in ipairs(json.media) do
    local med_pos = tonumber(medium.position) or 1
    if med_pos == disc_no and medium.tracks then
      for _, t in ipairs(medium.tracks) do
        local t_pos = tonumber(t.position) or 0
        if t_pos == track_no then
          return t
        end
      end
    end
  end

  if json.media[1] and json.media[1].tracks and json.media[1].tracks[i] then
    return json.media[1].tracks[i]
  end

  return nil
end

dale.compile.album.key("musicbrainz_albumid", function(ctx, m)
  local json = read_mb_json(ctx)
  return d.get(json, "id") or d.get(m, "id.album.musicbrainz_albumid")
end)

dale.compile.album.key("musicbrainz_releasegroupid", function(ctx, m)
  local json = read_mb_json(ctx)
  return d.get(json, "release-group.id") or d.get(m, "id.album.musicbrainz_releasegroupid")
end)

dale.compile.album.key("musicbrainz_albumartistid", function(ctx, m)
  local json = read_mb_json(ctx)
  return d.get(json, "artist-credit.1.artist.id") or d.get(m, "id.album.musicbrainz_albumartistid")
end)

dale.compile.album.key("musicbrainz_releasetype", function(ctx, m)
  local json = read_mb_json(ctx)
  local p_type = d.get(json, "release-group.primary-type")
  local s_types = d.get(json, "release-group.secondary-types")
  if p_type and s_types and #s_types > 0 then
    return p_type .. "; " .. table.concat(s_types, "; ")
  end
  return p_type
end)

dale.compile.album.key("releasecountry", function(ctx, m)
  local json = read_mb_json(ctx)
  return d.get(json, "country")
end)

dale.compile.album.key("label", function(ctx, m)
  local json = read_mb_json(ctx)
  return d.get(json, "label-info.1.label.name") or d.get(m, "metadata.album.label")
end)

dale.compile.album.key("catalognumber", function(ctx, m)
  local json = read_mb_json(ctx)
  return d.get(json, "label-info.1.catalog-number") or d.get(m, "metadata.album.catalognumber")
end)

-- dale.compile.album.key("musicbrainz_release_url", function(ctx, m)
--   local json = read_mb_json(ctx)
--   local id = d.get(json, "id") or d.get(m, "id.album.musicbrainz_albumid")
--   if id then return "https://musicbrainz.org/release/" .. id end
-- end)
--
-- dale.compile.album.key("musicbrainz_releasegroup_url", function(ctx, m)
--   local json = read_mb_json(ctx)
--   local id = d.get(json, "release-group.id") or d.get(m, "id.album.musicbrainz_releasegroupid")
--   if id then return "https://musicbrainz.org/release-group/" .. id end
-- end)
--
-- dale.compile.album.key("musicbrainz_albumartist_url", function(ctx, m)
--   local json = read_mb_json(ctx)
--   local id = d.get(json, "artist-credit.1.artist.id") or d.get(m, "id.album.musicbrainz_albumartistid")
--   if id then return "https://musicbrainz.org/artist/" .. id end
-- end)
--
-- dale.compile.album.key("discogs_release_url", function(ctx, m)
--   local id = d.get(m, "id.album.discogs_releaseid")
--   if id then return "https://discogs.com/release/" .. tostring(id) end
-- end)
--
-- dale.compile.album.key("discogs_master_url", function(ctx, m)
--   local id = d.get(m, "id.album.discogs_masterid")
--   if id then return "https://discogs.com/master/" .. tostring(id) end
-- end)

dale.compile.track.key("musicbrainz_releasetrackid", function(ctx, m, i)
  local t = get_mb_track(ctx, m, i)
  return d.get(t, "id") or d.get(m, "id.tracks", i, "musicbrainz_releasetrackid")
end)

dale.compile.track.key("musicbrainz_recordingid", function(ctx, m, i)
  local t = get_mb_track(ctx, m, i)
  return d.get(t, "recording.id")
end)

dale.compile.track.key("musicbrainz_artistid", function(ctx, m, i)
  local t = get_mb_track(ctx, m, i)
  return d.get(t, "artist-credit.1.artist.id")
end)
