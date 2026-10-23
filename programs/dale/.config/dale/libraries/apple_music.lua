dale.library("apple_music", { label = "Apple Music",
  groupers = {
    "year_added_applemusic",
    "genre",
    "decade",
  },
  orders = {
    "date_added_applemusic",
    "default",
    "az",
    "year",
  },
  match = function(a)
    return d.get(a, "keys.date_added_applemusic") ~= nil
  end,
})

dale.grouper("year_added_applemusic", { label = "Year Added",
  select = function(a)
    local date = d.get(a, "keys.date_added_applemusic")
    if date and #date >= 4 then return date:sub(1, 4) end
  end,
})

dale.order("date_added_applemusic", { label = "Date Added",
  reverse = true,
  sort = function(a)
    return d.get(a, "keys.date_added_applemusic") or ""
  end,
})
