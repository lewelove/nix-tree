dale.compile.album.key("verified", function(ctx, m)
  local fields = { "albumartist", "album", "date" }
  for _, field in ipairs(fields) do
    local hist = d.get(m, "history.album", field)
    local meta = d.get(m, "metadata.album", field)
    if hist and meta ~= hist then
      local meta_str = tostring(meta)
      local hist_str = tostring(hist)
      error(string.format("%s diverged! Metadata: '%s' | History: '%s'", field, meta_str, hist_str))
    end
  end
end)
