require("helpers")

require("keys.default")
require("keys.date_added")
require("keys.id")
require("keys.verified")
require("keys.lyrics")

require("logic.filters")
require("logic.orders")
require("logic.groupers")

require("libraries.default")
require("libraries.apple_music")
require("libraries.foobar")
require("libraries.my_year")

require("libraries.experimental")

require("cabinets.collections")

require("interfaces")

require("actions")

dale.config({
  storage = {
    music_directory = "/run/media/lewelove/1000xhome/backup-everything/FB2K/Library Historyfied!/",
  },
  server = {
    port = 8000,
  },
  manifest = {
    audio_extensions = { "flac" },
  },
  compiler = {
    manifests = { "id", "history" },
  },
})

dale.cache.cover({ filter = "catmullrom", size = 200 })
dale.cache.cover({ filter = "catmullrom", size = 627 })
