function contains(val, target)
  if type(val) == "string" then
    return val:find(target, 1, true) ~= nil
  elseif type(val) == "table" then
    for _, item in ipairs(val) do
      if tostring(item):find(target, 1, true) then return true end
    end
  end
  return false
end

function clean_artist(artist)
  if not artist or artist == "" then return "" end
  local lower = artist:lower()
  if lower:sub(1, 4) == "the " then
    return artist:sub(5)
  end
  return artist
end

function contains_in_table(tbl, target, exact)
  if type(tbl) ~= "table" or target == nil then
    return false
  end

  local is_exact = (exact == nil or exact == true)

  for _, val in pairs(tbl) do
    if is_exact then
      if val == target then
        return true
      end
    else
      if type(val) == "string" and type(target) == "string" then
        if val:find(target, 1, true) ~= nil then
          return true
        end
      elseif tostring(val) == tostring(target) then
        return true
      end
    end

    if type(val) == "table" and contains_in_table(val, target, exact) then
      return true
    end
  end

  return false
end

function format_duration(ms)
  if not ms or ms <= 0 then return "0m" end
  local total_secs = math.floor(ms / 1000)
  local hours = math.floor(total_secs / 3600)
  local mins = math.floor((total_secs % 3600) / 60)
  if hours > 0 then
    return string.format("%dh %dm", hours, mins)
  end
  return string.format("%dm", mins)
end

function format_duration_clock(ms)
  if not ms or ms <= 0 then return "00:00" end

  local total_secs = math.floor(ms / 1000)
  local hours = math.floor(total_secs / 3600)
  local mins = math.floor((total_secs % 3600) / 60)
  local secs = total_secs - (hours * 3600) - (mins * 60)

  local hours_str = string.format("%d", hours)
  local mins_str = ""
  local secs_str = ""

  if mins < 10 then
    mins_str = string.format("0%d", mins)
  else
    mins_str = string.format("%d", mins)
  end

  if secs < 10 then
    secs_str = string.format("0%d", secs)
  else
    secs_str = string.format("%d", secs)
  end

  return hours_str .. ":" .. mins_str .. ":" .. secs_str
end
