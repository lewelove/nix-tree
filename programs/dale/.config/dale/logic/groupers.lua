local chroma_order = {
  Monochrome = 1,
  Bleak = 2,
  Standard = 3,
  Vivid = 4,
  Saturated = 5,
}

dale.grouper("genre", { label = "Genre",
  select = function(a) return d.get(a, "keys.genre") or "Unknown" end,
  format = function(g)
    return {
      label = g.value,
      sublabel = format_duration_clock(g.duration_millis),
      -- sort = -g.duration_millis or 0,
    }
  end
})

dale.grouper("styles", { label = "Styles",
  select = function(a) return d.get(a, "keys.styles") or "Unknown" end,
  format = function(g)
    return {
      label = g.value,
      sublabel = format_duration_clock(g.duration_millis),
      -- sort = -g.duration_millis or 0,
    }
  end
})

dale.grouper("year", { label = "Decades & Years",
  select = function(a)
    local date = d.get(a, "date")
    if date and #date >= 4 then return date:sub(1, 4) end
    return "Unknown"
  end,
  format = function(g)
    if g.value == "Unknown" then
      return {
        label = "Unknown",
        sort = 0,
      }
    end

    if g.value:match("^%d+0s$") then
      return {
        label = g.value,
        sort = tonumber(g.value:sub(1, 4)) or 0,
      }
    end

    local year_num = tonumber(g.value)
    if year_num and #g.value >= 4 then
      local decade = g.value:sub(1, 3) .. "0s"
      return {
        label = g.value,
        parent = decade,
        sublabel = format_duration(g.duration_millis),
        sort = year_num,
      }
    end

    return {
      label = g.value,
      sort = g.value,
    }
  end,
})

dale.grouper("total_tracks", { label = "Total Tracks",
  select = function(a)
    local tracks = d.get(a, "info.total_tracks") or 0
    return tostring(tracks)
  end,
  format = function(g)
    return {
      label = g.value,
      sort = tonumber(g.value) or 0,
    }
  end,
})

dale.grouper("total_discs", { label = "Total Discs",
  select = function(a)
    local discs = d.get(a, "info.total_discs") or 1
    return tostring(discs)
  end,
  format = function(g)
    return {
      label = g.value,
      sort = tonumber(g.value) or 1,
    }
  end,
})

dale.grouper("year_added", { label = "Year Added",
  select = function(a)
    local date = d.get(a, "keys.date_added")
    if date and #date >= 4 then return date:sub(1, 4) end
    return "Unknown"
  end,
})

dale.grouper("chroma", { label = "Chroma",
  reverse = true,
  select = function(a)
    local raw = d.get(a, "keys.cover_chroma")
    local val = tonumber(raw) or 0
    if val < 0.17 then return "Monochrome"
    elseif val < 21 then return "Bleak"
    elseif val < 45 then return "Standard"
    elseif val < 60 then return "Vivid"
    else return "Saturated" end
  end,
  format = function(g)
    return {
      label = g.value,
      sort = chroma_order[g.value] or 0,
    }
  end,
})

dale.grouper("folder", { label = "Folders",
  select = function(a)
    local rel_path = d.get(a, "keys.path")
    if not rel_path or rel_path == "" then return "Unknown" end
    return rel_path
  end,
  format = function(g)
    if g.value == "Unknown" then
      return {
        label = "Unknown",
        sort = "zzz",
      }
    end

    -- Split "A/B/C" into parent: "A/B", label: "C"
    local parent, folder_name = g.value:match("^(.-)/([^/]+)$")

    if parent and folder_name then
      return {
        label = folder_name,
        parent = parent,
        sort = folder_name:lower(),
      }
    else
      -- Root level directory (no '/' remaining)
      return {
        label = g.value,
        sort = g.value:lower(),
      }
    end
  end,
})
