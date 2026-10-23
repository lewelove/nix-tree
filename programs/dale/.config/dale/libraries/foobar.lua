dale.library("foobar", { label = "Foobar2000",
  groupers = {
    "year_added_foobar",
  },
  orders = {
    "date_added_foobar",
  },
  match = function(a)
    return d.get(a, "keys.date_added_foobar") ~= nil
  end,
})

dale.grouper("year_added_foobar", { label = "Year Added",
  select = function(a)
    local date = d.get(a, "keys.date_added_foobar")
    if date and #date >= 4 then return date:sub(1, 4) end
  end,
})

dale.order("date_added_foobar", { label = "Date Added",
  reverse = true,
  sort = function(a)
    return d.get(a, "keys.date_added_foobar") or ""
  end,
})
