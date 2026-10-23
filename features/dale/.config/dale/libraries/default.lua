dale.library( "all_albums", { label = "All Albums",
  filters = {
    "main_library",
    "vapor_memory",
    "signal_memory",
  },
  groupers = {
    "genre",
    "styles",
    "artist_tree",
    "year",
    "folder",
    "total_discs",
    "total_tracks",
    "year_added",
    "chroma",
  },
  orders = {
    "default",
    "az",
    "year",
    "date_added",
    "duration",
    "cover_hash",
    "chroma",
    "entropy",
    "last_edited",
    "random",
  },
  match = function(a)
    return true
  end
})
