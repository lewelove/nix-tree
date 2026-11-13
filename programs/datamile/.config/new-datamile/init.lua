-- Datamile golden configuration.
--
-- Rules:
--   * Use d.* APIs directly. Do not wrap Datamile APIs in local helpers.
--   * Declare every media type with d.media.type(name).
--   * d.compile.<type>.* is the only way to populate a compiled media object.
--   * d.compile.<type>.lock(fn) makes the type a root type.
--   * d.compile.<type>.media(field, child_type) nests child media.
--   * d.compile.<type>.tag(name, fn) returns a scalar or a list of scalars.
--   * d.compile.<type>.object(name, fn) returns arbitrary JSON.
--   * d.compile.<type>.location(fn) returns optional physical provenance.
--   * d.compile.<type>.images(name, fn) returns the image contract.
--   * Every select function returns sources: { path = ... } or { data = ... }.
--   * Every compile function receives a source, not a path.
--   * id is semantic and runs after tags. Never derive identity from a path.
--   * location is optional and describes a real file or directory.
--   * Rust owns no album, track, film, or media-type knowledge.

require("helpers")
require("album")
require("track")

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

datamile.config({
  storage = {
    music_directory = "/run/media/lewelove/1000xhome/backup-everything/FB2K/Library Historyfied!/",
  },
  server = {
    port = 8000,
  },
  manifest = {
    audio_extensions = { "flac" },
  },
  compiler = {},
})

datamile.cache.image({ filter = "catmullrom", size = 200 })
datamile.cache.image({ filter = "catmullrom", size = 627 })
