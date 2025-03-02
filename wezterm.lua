-- ~/.config/wezterm/wezterm.lua
local wezterm = require 'wezterm'
local config = {}

-- Set a color scheme
config.color_scheme = 'Dracula'

-- Font settings
-- config.font = wezterm.font 'Fira Code'
config.font_size = 17.0

-- Window settings
config.initial_rows = 40
config.initial_cols = 120

return config 
