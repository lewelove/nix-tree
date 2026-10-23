dale.library("Experimental", {
  filters = { "default", "vapor_memory" },
  groupers = {
    "artist_tree",
  },
  orders = { "default", "cover_mtime" },
  match = function(a) return true end,
})

dale.order("cover_mtime", { label = "Cover Mtime",
  sort = function(a) return d.get(a, "covers.main.file.mtime") end,
})

dale.grouper("artist_tree", { label = "Artist Tree",
  select = function(a)
    local albumartists = d.get(a, "keys.albumartists")
    local albumartist = d.get(a, "albumartist")
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
