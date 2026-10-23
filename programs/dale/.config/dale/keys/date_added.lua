local function add_date_key(name)
  dale.compile.album.key(name, function(ctx, m)
    local val = d.get(m, "history.album." .. name)
    return d.fn.type_check(val, "datetime")
  end)
end

add_date_key("date_added_foobar")
add_date_key("date_added_applemusic")
add_date_key("date_added_youtube")
add_date_key("date_added_dale")

dale.compile.album.key("date_added", function(ctx, m)
  local hist = d.get(m, "history.album")
  if not hist then return nil end

  local keys = {
    "date_added_youtube",
    "date_added_applemusic",
    "date_added_foobar",
    "date_added_dale",
    "date_added_applemusic_unknown",
    "date_added_dale_unknown",
  }

  local earliest = nil
  for _, key in ipairs(keys) do
    local dt = d.get(hist, key)
    if dt and dt ~= "" and (not earliest or dt < earliest) then
      earliest = dt
    end
  end

  return d.fn.present(earliest)
end)
