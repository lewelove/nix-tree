datamile.order("default", { label = "Default",
  sort = function(a)
    local custom = d.get(a, "tags.custom_albumartist")
    local albumartist = d.get(a, "tags.albumartist")
    local raw = custom or albumartist or ""
    local cleaned = clean_artist(raw)

    local date = d.get(a, "tags.date") or ""
    local album = d.get(a, "tags.album") or ""
    return { cleaned:lower(), date, album:lower() }
  end,
})

datamile.order("az", { label = "Alphabetical",
  sort = function(a)
    return (d.get(a, "tags.album") or ""):lower()
  end,
})

datamile.order("year", { label = "Year",
  reverse = true,
  sort = function(a)
    local date = d.get(a, "tags.date")
    local id = d.get(a, "id")
    return { date, id }
  end,
})

datamile.order("duration", { label = "Duration",
  sort = function(a)
    return tonumber(d.get(a, "objects.info.duration_milliseconds")) or 0
  end,
})

datamile.order("cover_hash", { label = "Cover Hash",
  sort = function(a) return d.get(a, "images.main.1.address") or "" end,
})

datamile.order("random", { label = "Random",
  sort = function(a) return "0" end,
})

datamile.order("chroma", { label = "Chroma",
  reverse = true,
  sort = function(a)
    return tonumber(d.get(a, "tags.cover_chroma")) or 0
  end,
})

datamile.order("entropy", { label = "Entropy",
  reverse = true,
  sort = function(a)
    return tonumber(d.get(a, "tags.cover_entropy")) or 0
  end,
})

datamile.order("date_added", { label = "Date Added",
  reverse = true,
  sort = function(a) return d.get(a, "tags.date_added") or "" end,
})

datamile.order("last_edited", { label = "Last Edited",
  reverse = true,
  sort = function(a)
    local max_mtime = 0

    local manifests = d.get(a, "objects.manifests")
    if type(manifests) == "table" then
      for _, m in pairs(manifests) do
        local mtime = tonumber(d.get(m, "file.mtime")) or 0
        if mtime > max_mtime then max_mtime = mtime end
      end
    end

    local tracks = d.get(a, "tracks")
    if type(tracks) == "table" then
      for _, t in ipairs(tracks) do
        local mtime = tonumber(d.get(t, "location.mtime")) or 0
        if mtime > max_mtime then max_mtime = mtime end
      end
    end

    return max_mtime
  end,
})
