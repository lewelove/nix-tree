local chroma_order = {
  Monochrome = 1,
  Bleak = 2,
  Standard = 3,
  Vivid = 4,
  Saturated = 5,
}

datamile.grouper("genre", { label = "Genre",
  select = function(a) return d.get(a, "tags.genre") or "Unknown" end,
  format = function(g)
    return {
      label = g.value,
      sublabel = format_duration_clock(g.duration_millis),
    }
  end
})

datamile.grouper("styles", { label = "Styles",
  select = function(a) return d.get(a, "tags.styles") or "Unknown" end,
  format = function(g)
    return {
      label = g.value,
      sublabel = format_duration_clock(g.duration_millis),
    }
  end
})

datamile.grouper("year", { label = "Decades & Years",
  select = function(a)
    local date = d.get(a, "tags.date")
    if date and #date >= 4 then return date:sub(1, 4) end
    return "Unknown"
  end,
  format = function(g)
    if g.value == "Unknown" then
      return { label = "Unknown", sort = 0 }
    end

    if g.value:match("^%d+0s$") then
      return { label = g.value, sort = tonumber(g.value:sub(1, 4)) or 0 }
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

    return { label = g.value, sort = g.value }
  end,
})

datamile.grouper("total_tracks", { label = "Total Tracks",
  select = function(a)
    return tostring(d.get(a, "objects.info.total_tracks") or 0)
  end,
  format = function(g)
    return { label = g.value, sort = tonumber(g.value) or 0 }
  end,
})

datamile.grouper("total_discs", { label = "Total Discs",
  select = function(a)
    return tostring(d.get(a, "objects.info.total_discs") or 1)
  end,
  format = function(g)
    return { label = g.value, sort = tonumber(g.value) or 1 }
  end,
})

datamile.grouper("year_added", { label = "Year Added",
  select = function(a)
    local date = d.get(a, "tags.date_added")
    if date and #date >= 4 then return date:sub(1, 4) end
    return "Unknown"
  end,
})

datamile.grouper("chroma", { label = "Chroma",
  reverse = true,
  select = function(a)
    local val = tonumber(d.get(a, "tags.cover_chroma")) or 0
    if val < 0.17 then return "Monochrome"
    elseif val < 21 then return "Bleak"
    elseif val < 45 then return "Standard"
    elseif val < 60 then return "Vivid"
    else return "Saturated" end
  end,
  format = function(g)
    return { label = g.value, sort = chroma_order[g.value] or 0 }
  end,
})

datamile.grouper("folder", { label = "Folders",
  select = function(a)
    local rel_path = d.get(a, "tags.path")
    if not rel_path or rel_path == "" then return "Unknown" end
    return rel_path
  end,
  format = function(g)
    if g.value == "Unknown" then
      return { label = "Unknown", sort = "zzz" }
    end

    local parent, folder_name = g.value:match("^(.-)/([^/]+)$")
    if parent and folder_name then
      return {
        label = folder_name,
        parent = parent,
        sort = folder_name:lower(),
      }
    end

    return { label = g.value, sort = g.value:lower() }
  end,
})

datamile.grouper("artist_tree", { label = "Artist Tree",
  select = function(a)
    local albumartists = d.get(a, "tags.albumartists")
    local albumartist = d.get(a, "tags.albumartist")
    return d.fn.coalesce(albumartists, albumartist, "Unknown")
  end,
  format = function(g)
    if #g.value == 1 or g.value == "#" then
      return {
        label = g.value,
        sort = g.value == "#" and "zzz" or g.value:lower(),
      }
    end

    local clean = clean_artist(g.value)
    local first = clean:sub(1, 1):upper()
    local bucket = first:match("%a") and first or "#"

    return {
      label = g.value,
      sublabel = format_duration(g.duration_millis),
      parent = bucket,
      sort = clean:lower(),
    }
  end,
})
