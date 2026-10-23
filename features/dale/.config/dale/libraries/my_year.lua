dale.library("my_year", { label = "My Year",
  groupers = {
    "my_year_grouper",
  },
  orders = {
    "default",
    "date_added",
  },
  match = function(a)
    return d.get(a, "keys.my_year") ~= nil
  end,
})

dale.grouper("my_year_grouper", { label = "Year",
  select = function(a)
    return d.get(a, "keys.my_year")
  end,
})
