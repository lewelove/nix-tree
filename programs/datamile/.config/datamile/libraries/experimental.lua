datamile.library("Experimental", {
  filters = { "default", "vapor_memory" },
  groupers = { "artist_tree" },
  orders = { "default", "cover_mtime" },
  match = function(a) return true end,
})

datamile.order("cover_mtime", { label = "Cover Mtime",
  sort = function(a) return d.get(a, "images.main.1.source.file.mtime") end,
})
