-- ~/.config/wezterm/wezterm.lua
local wezterm = require("wezterm")
local config = {}
local quake = os.getenv("WEZTERM_QUAKE") == "1"

config.color_scheme = "Dracula"
config.font_size = 17.0
config.window_background_opacity = 0.9
config.macos_window_background_blur = 30
config.window_padding = { left = 12, right = 12, top = 10, bottom = 10 }
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE | MACOS_FORCE_DISABLE_SHADOW"

local function mark_quake(window)
  if window.set_title then
    window:set_title("opencode-quake")
  end
  local ok, gui = pcall(function()
    return window:gui_window()
  end)
  if ok and gui then
    if gui.set_title then
      gui:set_title("opencode-quake")
    end
    if wezterm.gui and wezterm.gui.screens then
      local screen = wezterm.gui.screens().active
      local height = math.floor(screen.height * 0.4)
      gui:set_position(screen.x, screen.y)
      gui:set_inner_size(screen.width, height)
    end
  end
end

if quake then
  config.initial_rows = 16
  config.initial_cols = 220
  wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
    tab:set_title("opencode-quake")
    mark_quake(window)
  end)
else
  config.initial_rows = 40
  config.initial_cols = 120
end

return config
