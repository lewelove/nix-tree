dale.order("default", { label = "Default",
  sort = function(a)
    local custom = d.get(a, "keys.custom_albumartist")
    local albumartist = d.get(a, "albumartist")
    local raw = custom or albumartist or ""
    local cleaned = clean_artist(raw)

    local date = d.get(a, "date") or ""
    local album = d.get(a, "album") or ""
    return { cleaned:lower(), date, album:lower() }
  end,
})

dale.order("az", { label = "Alphabetical",
  sort = function(a)
    local album = d.get(a, "album") or ""
    return album:lower()
  end,
})

dale.order("year", { label = "Year",
  reverse = true,
  sort = function(a)
    local date = d.get(a, "date")
    local id = d.get(a, "id")
    return { date, id }
  end,
})

dale.order("duration", { label = "Duration",
  -- reverse = true,
  sort = function(a)
    local val = d.get(a, "info.duration_milliseconds")
    return tonumber(val) or 0
  end,
})

dale.order("cover_hash", { label = "Cover Hash",
  sort = function(a) return d.get(a, "covers.main.file.address") or "" end,
})

dale.order("random", { label = "Random",
  sort = function(a) return "0" end,
})

dale.order("chroma", { label = "Chroma",
  reverse = true,
  sort = function(a)
    local val = d.get(a, "keys.cover_chroma")
    return tonumber(val) or 0
  end,
})

dale.order("entropy", { label = "Entropy",
  reverse = true,
  sort = function(a)
    local val = d.get(a, "keys.cover_entropy")
    return tonumber(val) or 0
  end,
})

dale.order("date_added", { label = "Date Added",
  reverse = true,
  sort = function(a) return d.get(a, "keys.date_added") or "" end,
})

dale.order("last_edited", { label = "Last Edited",
  reverse = true,
  sort = function(a)
    local max_mtime = 0

    local manifests = d.get(a, "manifests")
    if type(manifests) == "table" then
      for _, m in pairs(manifests) do
        local raw = d.get(m, "file.mtime")
        local mtime = tonumber(raw) or 0
        if mtime > max_mtime then max_mtime = mtime end
      end
    end

    local tracks = d.get(a, "tracks")
    if type(tracks) == "table" then
      for _, t in ipairs(tracks) do
        local raw = d.get(t, "file.mtime")
        local mtime = tonumber(raw) or 0
        if mtime > max_mtime then max_mtime = mtime end
      end
    end

    return max_mtime
  end,
})
