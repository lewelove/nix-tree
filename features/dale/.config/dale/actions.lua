local root_dir = d.fs.normalize("~/dev/dale")

local function rust_bin(name)
  return d.fs.normalize(d.fs.joinpath(root_dir, "target/release", name))
end

local function py_bin(name)
  return d.fs.normalize(d.fs.joinpath(root_dir, "actions", name))
end

local function add_arg(args, flag, val)
  if val == nil or val == "" or val == "Unknown" then
    return
  end
  if type(val) == "table" then
    val = table.concat(val, "; ")
    if val == "" or val == "Unknown" then
      return
    end
  end
  table.insert(args, flag)
  table.insert(args, tostring(val))
end

dale.action("open_terminal", {
  label = "Open Terminal",
  description = "Open terminal inside album directory",
  run = function(ctx)
    for _, entry in ipairs(ctx.albums) do
      d.system({ "alacritty" }, { cwd = entry.path, detach = true })
    end
  end
})

dale.action("open_config_in_terminal", {
  label = "Open Config in Terminal",
  description = "Open terminal inside Dale configuration directory",
  run = function(ctx)
    local config_dir = d.fs.normalize("~/.config/dale")
    d.system({ "alacritty", "-e", "sh", "-c", 'nvim -s <(printf " e")' }, { cwd = config_dir, detach = true })
  end
})

dale.action("theme", {
  label = "Generate Theme",
  description = "Extract dominant colors from album cover",
  run = function(ctx)
    local is_force = ctx.options:find("%-f") or ctx.options:find("%-%-force")
    for _, entry in ipairs(ctx.albums) do
      local args = {
        rust_bin("theme"),
        "--path", entry.path,
        "--algo", "kmeansnv",
        "--sort", "gradient",
        "--args", "k=12,n=12,d=0.0",
        "--threshold", "0.001",
        "--open-with", "nvl"
      }
      if is_force then
        table.insert(args, "--force")
      end
      d.system(args, { stdio = "inherit" })
    end
  end
})

dale.action("collect", {
  label = "Collect Metadata",
  description = "Fetch and scaffold album from Discogs or MusicBrainz URL",
  run = function(ctx)
    local url = d.str.trim(ctx.options)
    if url == "" then
      error("collect: URL argument is required in options")
    end

    local args = {
      rust_bin("collect"),
      "--url", url,
      "--root", d.fs.normalize("/run/media/lewelove/1000xhome/backup-everything/FB2K/Virtual Albums Stage/"),
      "--format-album", "{albumartist} - {album}"
    }

    d.system(args, { stdio = "inherit" })
  end
})

dale.action("mbf", {
  label = "MusicBrainz Fetch",
  description = "Fetch raw JSON metadata from MusicBrainz",
  run = function(ctx)
    local url = d.str.trim(ctx.options)
    local entry = ctx.albums[1]
    local info_dir = d.fs.joinpath(entry.path, "Info")
    local rel_file = d.fs.joinpath(info_dir, "musicbrainz_release.json")
    local rg_file = d.fs.joinpath(info_dir, "musicbrainz_releasegroup.json")

    d.system({
      rust_bin("musicbrainz_fetch"),
      "--url", url,
      "-o", rel_file,
      "--retry", "3"
    }, { stdio = "inherit" })

    local rel_data = d.fs.read_json(rel_file)
    local rg_id = d.get(rel_data, "release-group.id")

    d.system({ "sleep", "1" })

    d.system({
      rust_bin("musicbrainz_fetch"),
      "--release-group-id", rg_id,
      "-o", rg_file,
      "--retry", "3"
    }, { stdio = "inherit" })
  end
})

dale.action("mbffid", {
  label = "MusicBrainz Fetch From ID",
  description = "Fetch raw JSON metadata from MusicBrainz using id.toml",
  run = function(ctx)
    for _, entry in ipairs(ctx.albums) do
      local id_path = d.fs.joinpath(entry.path, "id.toml")
      local id_data = d.fs.read_toml(id_path)
      local rel_id = d.get(id_data, "album.musicbrainz_albumid")

      local info_dir = d.fs.joinpath(entry.path, "Info")
      local rel_file = d.fs.joinpath(info_dir, "musicbrainz_release.json")
      local rg_file = d.fs.joinpath(info_dir, "musicbrainz_releasegroup.json")

      d.system({
        rust_bin("musicbrainz_fetch"),
        "--release-id", rel_id,
        "-o", rel_file,
        "--retry", "3"
      }, { stdio = "inherit" })

      local rel_data = d.fs.read_json(rel_file)
      local rg_id = d.get(rel_data, "release-group.id")

      d.system({ "sleep", "1" })

      d.system({
        rust_bin("musicbrainz_fetch"),
        "--release-group-id", rg_id,
        "-o", rg_file,
        "--retry", "3"
      }, { stdio = "inherit" })
    end
  end
})

dale.action("embed", {
  label = "Embed Tags",
  description = "Embed metadata from album.lock.json into audio files",
  run = function(ctx)
    for _, entry in ipairs(ctx.albums) do
      local album = entry.lock.album
      local tracks = entry.lock.tracks

      local args = {
        rust_bin("embed"),
        "--delete-other-tags",
        "--delete-other-covers",
      }

      local cover_path = d.get(album, "covers.main.file.path")
      if cover_path then
        add_arg(args, "--cover", d.fs.joinpath(entry.path, cover_path))
      end

      local multi_disc = album.info.total_discs > 1

      for _, track in ipairs(tracks) do
        add_arg(args, "--track", d.fs.joinpath(entry.path, track.file.path))
        add_arg(args, "--album", album.album)
        add_arg(args, "--albumartist", album.albumartist)
        add_arg(args, "--date", album.date)
        add_arg(args, "--genre", d.get(album, "keys.genre"))
        add_arg(args, "--comment", d.get(album, "keys.comment"))
        add_arg(args, "--musicbrainz-albumid", d.get(album, "keys.musicbrainz_albumid"))
        add_arg(args, "--musicbrainz-releasegroupid", d.get(album, "keys.musicbrainz_releasegroupid"))
        add_arg(args, "--musicbrainz-albumartistid", d.get(album, "keys.musicbrainz_albumartistid"))
        add_arg(args, "--releasetype", d.get(album, "keys.musicbrainz_releasetype"))
        add_arg(args, "--releasecountry", d.get(album, "keys.releasecountry") or d.get(album, "keys.country"))
        add_arg(args, "--barcode", d.get(album, "keys.barcode"))
        add_arg(args, "--publisher", d.get(album, "keys.label"))
        add_arg(args, "--catalognumber", d.get(album, "keys.catalognumber"))
        add_arg(args, "--title", track.title)
        add_arg(args, "--artist", track.artist)
        add_arg(args, "--tracknumber", track.tracknumber)

        if multi_disc then
          add_arg(args, "--discnumber", track.discnumber)
        end

        add_arg(args, "--musicbrainz-releasetrackid", d.get(track, "keys.musicbrainz_releasetrackid"))
        add_arg(args, "--musicbrainz-trackid", d.get(track, "keys.musicbrainz_trackid") or d.get(track, "keys.musicbrainz_recordingid"))
        add_arg(args, "--musicbrainz-artistid", d.get(track, "keys.musicbrainz_artistid"))
        add_arg(args, "--replaygain-track-gain", d.get(track, "keys.replaygain_track_gain"))
        add_arg(args, "--lyrics", d.get(track, "lyrics.text") or d.get(track, "keys.lyrics"))
      end

      d.system(args, { stdio = "inherit" })
    end
  end
})

dale.action("rename", {
  label = "Rename Files",
  description = "Standardize track filenames according to metadata",
  run = function(ctx)
    local is_auto = ctx.options:find("%-y") or ctx.options:find("%-%-auto")
    for _, entry in ipairs(ctx.albums) do
      local args = { py_bin("rename"), "--path", entry.path }
      if is_auto then
        table.insert(args, "-y")
      end
      d.system(args, { stdio = ctx.isatty and "inherit" or "pipe" })
    end
  end
})

dale.action("lyrics", {
  label = "Fetch Lyrics",
  description = "Fetch track lyrics from Genius",
  run = function(ctx)
    local secrets = d.fs.read_dotenv("~/.secrets/dale.env")
    local token = secrets and secrets.GENIUS_ACCESS_TOKEN
    for _, entry in ipairs(ctx.albums) do
      local args = { py_bin("lyrics") }
      add_arg(args, "--path", entry.path)
      add_arg(args, "--token", token)
      d.system(args, { stdio = "inherit" })
    end
  end
})

dale.action("search_cover", {
  label = "Search Cover",
  description = "Search high-res artwork on MusicHoarders",
  run = function(ctx)
    for _, entry in ipairs(ctx.albums) do
      local artist = d.get(entry, "lock.album.albumartist") or d.get(entry, "lock.album.artist")
      local album = d.get(entry, "lock.album.album")
      local args = { py_bin("search_cover") }
      if artist and album then
        add_arg(args, "--artist", artist)
        add_arg(args, "--album", album)
      else
        add_arg(args, "--path", entry.path)
      end
      d.system(args, { detach = true })
    end
  end
})

dale.action("cover_metrics", {
  label = "Cover Metrics",
  description = "Calculate chroma and entropy for album cover",
  run = function(ctx)
    local is_force = ctx.options:find("%-f") or ctx.options:find("%-%-force")
    for _, entry in ipairs(ctx.albums) do
      local args = { rust_bin("calculate_cover_metrics"), "--path", entry.path }
      if is_force then
        table.insert(args, "--force")
      end
      d.system(args, { stdio = "inherit" })
    end
  end
})

dale.action("mbs", {
  label = "MusicBrainz Search",
  description = "Search release groups on MusicBrainz",
  run = function(ctx)
    local launcher = (jit and jit.os == "OSX") and "open" or "xdg-open"

    local function search_mb(artist, title)
      local query
      if artist == "" then
        query = string.format('releasegroup:"%s"', title)
      elseif title == "" then
        query = string.format('artist:"%s"', artist)
      else
        query = string.format('artist:"%s" AND releasegroup:"%s"', artist, title)
      end

      local encoded = ""
      for c in query:gmatch(".") do
        if c:match("[%w_.~-]") then
          encoded = encoded .. c
        else
          encoded = encoded .. string.format("%%%02X", string.byte(c))
        end
      end

      local url = string.format(
        "https://musicbrainz.org/search?type=release_group&method=advanced&query=%s",
        encoded
      )
      d.system({ launcher, url }, { detach = true })
    end

    if #ctx.albums > 0 then
      for _, entry in ipairs(ctx.albums) do
        local artist = d.get(entry, "lock.album.albumartist") or d.get(entry, "lock.album.artist") or ""
        local title = d.get(entry, "lock.album.album") or ""
        if artist ~= "" or title ~= "" then
          search_mb(artist, title)
        end
      end
    elseif ctx.options and ctx.options ~= "" then
      local parts = d.str.split(ctx.options, " - ", true)
      if #parts >= 2 then
        search_mb(d.str.trim(parts[1]), d.str.trim(parts[2]))
      else
        search_mb("", d.str.trim(ctx.options))
      end
    end
  end
})

dale.action("css", {
  label = "Copy Search String",
  description = "Copy 'Artist - Album' search string to clipboard",
  run = function(ctx)
    local target = ctx.albums and ctx.albums[1]
    if not target then return end

    local artist = d.get(target, "lock.album.albumartist") or d.get(target, "lock.album.artist") or ""
    local title = d.get(target, "lock.album.album") or ""

    if artist ~= "" and title ~= "" then
      local query = string.format("%s - %s", artist, title)
      local clip_cmd = { "wl-copy" }
      d.system(clip_cmd, { stdin = query, detach = true })
    end
  end
})

dale.action("cs", {
  label = "Cover Source",
  description = "Download cover image from URL",
  run = function(ctx)
    local url = ctx.options:match("%S+")
    local ext = url:gsub("%?.*$", ""):match("(%.[^./\\]+)$") or ""
    local file = string.format("Digital Covers/source%d%s", os.time(), ext)
    d.system({ "mkdir", "-p", "Digital Covers" })
    d.system({ "wget", "-O", file, url }, { stdio = "inherit" })
  end
})

dale.action("rts", {
  label = "RuTracker Search",
  description = "Search album releases on RuTracker",
  run = function(ctx)
    local function open_tracker(query)
      if query == "" then return end

      local enc = d.system({
        "python3",
        "-c",
        "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]), end='')",
        query,
      })
      if not enc.ok then return end

      local url = "https://rutracker.org/forum/tracker.php?nm=" .. enc.stdout
      d.system({ "xdg-open", url }, { detach = true })
    end

    if #ctx.albums > 0 then
      for _, entry in ipairs(ctx.albums) do
        local artist = d.get(entry, "lock.album.albumartist") or d.get(entry, "lock.album.artist") or ""
        local title = d.get(entry, "lock.album.album") or ""
        local query = (artist ~= "" and title ~= "") and (artist .. " " .. title) or (artist .. title)
        open_tracker(d.str.trim(query))
      end
    elseif ctx.options and ctx.options ~= "" then
      open_tracker(d.str.trim(ctx.options))
    end
  end,
})
