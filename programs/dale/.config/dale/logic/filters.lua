dale.filter("default", { label = "Default",
  match = function(a) return true end,
})

dale.filter("main_library", { label = "Main Library",
  match = function(a)
    local coll = d.get(a, "keys.collection")
    if contains(coll, "Vapor Memory") then return false end

    local genre = d.get(a, "keys.genre")
    if contains(genre, "Signalwave") or contains(genre, "Vaporwave") then return false end

    local is_virtual = d.get(a, "info.virtual")
    return is_virtual ~= true
  end,
})

dale.filter("vapor_memory", { label = "Vapor Memory",
  match = function(a)
    local coll = d.get(a, "keys.collection")
    local genre = d.get(a, "keys.genre")
    return contains(coll, "Vapor Memory") or contains(genre, "Vaporwave")
  end,
})
