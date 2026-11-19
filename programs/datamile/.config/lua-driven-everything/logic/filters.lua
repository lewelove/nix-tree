datamile.filter("default", { label = "Default",
  match = function(a) return true end,
})

datamile.filter("main_library", { label = "Main Library",
  match = function(a)
    local coll = d.get(a, "tags.collection")
    if d.fn.has(coll, "Vapor Memory") then return false end

    local genre = d.get(a, "tags.genre")
    if d.fn.has(genre, "Signalwave") or d.fn.has(genre, "Vaporwave") then return false end

    return d.get(a, "objects.info.virtual") ~= true
  end,
})

datamile.filter("vapor_memory", { label = "Vapor Memory",
  match = function(a)
    local coll = d.get(a, "tags.collection")
    local genre = d.get(a, "tags.genre")
    return d.fn.has(coll, "Vapor Memory") or d.fn.has(genre, "Vaporwave")
  end,
})
