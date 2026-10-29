--- System -----------------------------------------------------

-- kill hyprland and escape to tty
-- hl.bind (
--   "CONTROL + ALT + Escape",
--   hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'") )

-- powermenu
hl.bind (
  "CONTROL + ALT + Delete",
  hl.dsp.exec_cmd("powermenu") )

-- btop
hl.bind (
  "CONTROL + ALT + Insert",
  hl.dsp.exec_cmd(x.terminal .. " -e btop") )

-- close window safely
local safe_kill = require("scripts.safe-kill")
hl.bind (
  "SUPER + Q",
  safe_kill )

-- close window
hl.bind (
  "SUPER + SHIFT + Q",
  hl.dsp.window.close() )

-- toggle floating
hl.bind (
  "SUPER + E",
  hl.dsp.window.float({ action = "toggle" }) )

-- toggle fullscreen
hl.bind (
  "SUPER + Tab",
  hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }) )

-- pin windows
hl.bind (
  "SUPER + P",
  hl.dsp.window.pin() )

-- cycle focus through windows
hl.bind (
  "SUPER + Left",
  hl.dsp.focus({ direction = "l" }) )

hl.bind (
  "SUPER + Right",
  hl.dsp.focus({ direction = "r" }) )

-- drag/resize windows with lmb/rmb and dragging
hl.bind (
  "SUPER + mouse:272",
  hl.dsp.window.drag(),
  { mouse = true } )

hl.bind (
  "SUPER + mouse:273",
  hl.dsp.window.resize(),
  { mouse = true } )

-- -- swap windows within workspace
-- hl.bind (
--   "SUPER + SHIFT + Left",
--   hl.dsp.window.swap({ direction = "l" }) )
--
-- hl.bind (
--   "SUPER + SHIFT + Right",
--   hl.dsp.window.swap({ direction = "r", group_aware = true }) )

-- swap columns within scrolling workspace
hl.bind (
  "SUPER + SHIFT + Left",
  hl.dsp.layout("swapcol l") )

hl.bind (
  "SUPER + SHIFT + Right",
  hl.dsp.layout("swapcol r") )

-- rezise scrolling column

hl.bind (
  "SUPER + Up",
  hl.dsp.layout("fit active") )

hl.bind (
  "SUPER + Down",
  hl.dsp.layout("colresize 0.7") )

hl.bind (
  "SUPER + SHIFT + Down",
  hl.dsp.layout("colresize 0.5") )

--- Control ----------------------------------------------------

-- audio devices
hl.bind (
  "SUPER + F1",
  hl.dsp.exec_cmd("pactl set-default-sink EDIFIER-R1380DB-EQ-SPL90-20260609") )

hl.bind (
  "SUPER + F2",
  hl.dsp.exec_cmd("pactl set-default-sink AIYIMA-DAC-A5-PRO-SWAP") )

hl.bind (
  "SUPER + F3",
  hl.dsp.exec_cmd("pactl set-default-sink REDMI-BUDS-6-ACTIVE-EQ && bluetoothctl connect 90:EF:4A:FC:27:9F") )

-- audio volume
hl.bind (
  "Prior",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-"),
  { repeating = true } )

hl.bind (
  "Next",
  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 3%+"),
  { repeating = true } )

-- rebind of Lock key on KEYCHRON keyboard
local keychron_lock_key = "SUPER + L"

-- mpd client
hl.bind (
  keychron_lock_key,
  hl.dsp.exec_cmd("rmpc togglepause") )

hl.bind (
  "CONTROL + " .. keychron_lock_key,
  hl.dsp.exec_cmd("rmpc single oneshot") )

hl.bind (
  "CONTROL + SHIFT + " .. keychron_lock_key,
  hl.dsp.exec_cmd("rmpc single off") )

--- x ---------------------------------------------------

hl.bind (
  "SUPER + Return",
  hl.dsp.exec_cmd(x.terminal) )

hl.bind (
  "SUPER + R",
  hl.dsp.exec_cmd(x.menu) )

hl.bind (
  "SUPER + SHIFT + E",
  hl.dsp.exec_cmd(x.file_manager) )

hl.bind (
  "SUPER + SHIFT + B",
  hl.dsp.exec_cmd(x.browser) )

hl.bind (
  "SUPER + KP_Multiply",
  hl.dsp.exec_cmd(x.calculator) )

hl.bind (
  "SUPER + SHIFT + P",
  hl.dsp.exec_cmd(x.password_manager) )

hl.bind (
  "SUPER + Grave",
  hl.dsp.exec_cmd(x.bookmarks) )

hl.bind (
  "SUPER + SHIFT + Return",
  hl.dsp.exec_cmd(x.terminal .. " -e " .. x.lab_ssh) )

hl.bind (
  "SUPER + SHIFT + S",
  hl.dsp.exec_cmd("ns --ng && notify-send '~/nix-config is mirrored'") )

-- screenshots
local screenshot = require("scripts.screenshot")

hl.bind (
  "Print",
  function() screenshot("output") end )

hl.bind (
  "CONTROL + Print",
  function() screenshot("window") end )

hl.bind (
  "CONTROL + SHIFT + Print",
  function() screenshot("region") end )

-- pick color
hl.bind (
  "ALT + Print",
  hl.dsp.exec_cmd("hyprpicker -a | wl-copy") )

-- paste utils
hl.bind (
  "SUPER + V",
  hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu -w 130 | cliphist-copy") )

hl.bind (
  "SUPER + SHIFT + V",
  hl.dsp.exec_cmd("wrap-paste") )

hl.bind (
  "SUPER + Apostrophe",
  hl.dsp.exec_cmd("fuzzel-file-paste") )

hl.bind (
  "SUPER + Semicolon",
  hl.dsp.exec_cmd("fuzzel-copy") )

