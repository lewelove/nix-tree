local function find_lyrics(ctx, m, i)
  local album_root = d.get(ctx, "paths.album_root")
  local track = d.get(m, "metadata.tracks", i)
  if not album_root or not track then return nil end

  local disc = tonumber(track.discnumber) or 1
  local track_no = tonumber(track.tracknumber) or i
  local total_discs = tonumber(ctx.total_discs) or 1

  local patterns = {}
  if total_discs > 1 then
    -- Multi-disc patterns: "1.05 - ...", "01.05 - ...", "1-05 - ...", "105 - ..."
    table.insert(patterns, string.format("^0*%d%%.0*%d[%%s%%._%%-]", disc, track_no))
    table.insert(patterns, string.format("^0*%d%%-0*%d[%%s%%._%%-]", disc, track_no))
    table.insert(patterns, string.format("^%d%02d[%%s%%._%%-]", disc, track_no))
  end
  -- Track number pattern: "05 - ...", "5. ...", "05.lrc", "05_..."
  table.insert(patterns, string.format("^0*%d[%%s%%._%%-]", track_no))

  local is_match = function(name)
    local ext = name:match("%.([^.]+)$")
    if ext ~= "lrc" and ext ~= "txt" then
      return false
    end
    for _, pat in ipairs(patterns) do
      if name:find(pat) then
        return true
      end
    end
    return false
  end

  for _, folder in ipairs({ "Lyrics", "lyrics" }) do
    local dir = d.fs.joinpath(album_root, folder)
    local matches = d.fs.find(is_match, { path = dir, type = "file", depth = 1, limit = 1 })
    if #matches > 0 then
      local path = matches[1]
      local ext = path:match("%.([^.]+)$") or "txt"
      return path, ext:lower()
    end
  end

  return nil
end

dale.compile.track.lyrics({
  type = function(ctx, m, i)
    local _, fmt = find_lyrics(ctx, m, i)
    return fmt or "txt"
  end,
  text = function(ctx, m, i)
    local path = find_lyrics(ctx, m, i)
    return path and d.fs.read(path) or nil
  end,
})
