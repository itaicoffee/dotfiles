# Dotfiles Installation Makefile
# This Makefile creates symbolic links and sets permissions for dotfiles

# Define variables
DOTFILES_DIR := $(shell pwd)
HOME_DIR := $(HOME)
BIN_DIR := /usr/local/bin
CONFIG_DIR := $(HOME_DIR)/.config
XBAR_PLUGINS_DIR := $(HOME)/Library/Application\ Support/xbar/plugins

# Default target
.PHONY: all
all: install

# Main installation target
.PHONY: install
install: check_brew install_packages create_dirs install_configs install_bin install_xbar ensure_services_running check-chrome-profiles install-xbar-menubar-scripts install-zshrc ensure-profile

# Check if Homebrew is installed
.PHONY: check_brew
check_brew:
	@which brew > /dev/null || (echo "Homebrew is required but not installed. Please install Homebrew first: https://brew.sh" && exit 1)

# Install required packages if not already installed
.PHONY: install_packages
install_packages:
	@echo "Checking for required packages..."
	@if ! brew list yabai &>/dev/null; then \
		echo "Installing yabai..."; \
		brew install koekeishiya/formulae/yabai; \
	else \
		echo "yabai is already installed"; \
	fi
	@if ! brew list skhd &>/dev/null; then \
		echo "Installing skhd..."; \
		brew install koekeishiya/formulae/skhd; \
	else \
		echo "skhd is already installed"; \
	fi
	@if ! brew list xbar &>/dev/null; then \
		echo "Installing xbar..."; \
		brew install xbar; \
	else \
		echo "xbar is already installed"; \
	fi
	@if ! brew list wezterm &>/dev/null; then \
		echo "Installing wezterm..."; \
		brew install wezterm; \
	else \
		echo "wezterm is already installed"; \
	fi
	@if ! command -v wezterm &>/dev/null; then \
		echo "Setting up wezterm CLI..."; \
		if [ -f /Applications/WezTerm.app/Contents/Resources/wezterm ]; then \
			sudo ln -sf /Applications/WezTerm.app/Contents/Resources/wezterm $(BIN_DIR)/wezterm; \
		elif [ -f $(HOME)/Applications/WezTerm.app/Contents/Resources/wezterm ]; then \
			sudo ln -sf $(HOME)/Applications/WezTerm.app/Contents/Resources/wezterm $(BIN_DIR)/wezterm; \
		else \
			echo "⚠️ Warning: WezTerm CLI not found at expected locations. Installation will continue."; \
		fi \
	fi

# Create necessary directories
.PHONY: create_dirs
create_dirs:
	@echo "Creating necessary directories..."
	@mkdir -p $(CONFIG_DIR)/yabai
	@mkdir -p $(CONFIG_DIR)/skhd
	@mkdir -p $(CONFIG_DIR)/wezterm
	@mkdir -p $(CONFIG_DIR)/book
	@mkdir -p "$(XBAR_PLUGINS_DIR)"
	@mkdir -p $(HOME_DIR)/.local/bin
	@if [ ! -d $(BIN_DIR) ]; then \
		echo "Warning: $(BIN_DIR) does not exist. Attempting to create it..."; \
		sudo mkdir -p $(BIN_DIR) || echo "Failed to create $(BIN_DIR). You may need to create it manually with sudo."; \
	fi

# Install configuration files
.PHONY: install_configs
install_configs:
	@echo "Installing configuration files..."
	@ln -sf $(DOTFILES_DIR)/yabairc $(CONFIG_DIR)/yabai/yabairc
	@ln -sf $(DOTFILES_DIR)/skhdrc $(CONFIG_DIR)/skhd/skhdrc
	@ln -sf $(DOTFILES_DIR)/profile $(HOME_DIR)/.profile
	@ln -sf $(DOTFILES_DIR)/book_config.json $(CONFIG_DIR)/book/config.json
	@ln -sf $(DOTFILES_DIR)/wezterm.lua $(CONFIG_DIR)/wezterm/wezterm.lua

# Install bin scripts
.PHONY: install_bin
install_bin:
	@echo "Installing bin scripts to /usr/local/bin..."
	@for file in $(DOTFILES_DIR)/bin/*; do \
		filename=$$(basename $$file); \
		if [ -e $(BIN_DIR)/$$filename ]; then \
			echo "⚠️  Warning: $(BIN_DIR)/$$filename already exists, skipping"; \
		else \
			echo "Creating symlink for $$filename in $(BIN_DIR)"; \
			sudo ln -sf $$file $(BIN_DIR)/$$filename; \
			sudo chmod +x $$file; \
		fi; \
	done

# Install xbar plugins
.PHONY: install_xbar
install_xbar:
	@echo "Installing xbar plugins..."
	@for file in $(DOTFILES_DIR)/xbar/*; do \
		filename=$$(basename $$file); \
		ln -sf "$$file" "$(XBAR_PLUGINS_DIR)/$$filename"; \
		chmod +x "$$file"; \
	done
	@for file in $(DOTFILES_DIR)/menubar/*; do \
		filename=$$(basename $$file); \
		ln -sf "$$file" "$(HOME_DIR)/.local/bin/$$filename"; \
		chmod +x "$$file"; \
	done

# Start services
.PHONY: start_services
start_services:
	@echo "Starting services..."
	@yabai --start-service || echo "Failed to start yabai. Try starting manually with 'yabai --start-service'"
	@skhd --start-service || echo "Failed to start skhd. Try starting manually with 'skhd --start-service'"

# Ensure services are running
.PHONY: ensure_services_running
ensure_services_running:
	@echo "Ensuring all services are running..."
	@if command -v yabai >/dev/null 2>&1; then \
		if ! pgrep -q yabai; then \
			echo "yabai is not running, starting it..."; \
			yabai --start-service || echo "Failed to start yabai. Try starting manually with 'yabai --start-service'"; \
		else \
			echo "yabai is already running"; \
		fi \
	else \
		echo "yabai command not found. Skipping yabai service start."; \
	fi
	@if command -v skhd >/dev/null 2>&1; then \
		if ! pgrep -q skhd; then \
			echo "skhd is not running, starting it..."; \
			skhd --start-service || echo "Failed to start skhd. Try starting manually with 'skhd --start-service'"; \
		else \
			echo "skhd is already running"; \
		fi \
	else \
		echo "skhd command not found. Skipping skhd service start."; \
	fi
	@if [ -d "/Applications/xbar.app" ] || [ -d "$(HOME)/Applications/xbar.app" ]; then \
		if ! pgrep -q xbar; then \
			echo "xbar is not running, starting it..."; \
			open -a xbar || echo "Failed to start xbar"; \
		else \
			echo "xbar is already running"; \
		fi \
	else \
		echo "xbar application not found. Skipping xbar start."; \
	fi

# Uninstall everything
.PHONY: uninstall
uninstall:
	@echo "Uninstalling dotfiles..."
	@rm -f $(CONFIG_DIR)/yabai/yabairc
	@rm -f $(CONFIG_DIR)/skhd/skhdrc
	@rm -f $(HOME_DIR)/.profile
	@rm -f $(HOME_DIR)/.book_config.json
	@rm -f $(CONFIG_DIR)/wezterm/wezterm.lua
	@for file in $(DOTFILES_DIR)/bin/*; do \
		filename=$$(basename $$file); \
		if [ -L $(BIN_DIR)/$$filename ] && [ $$(readlink $(BIN_DIR)/$$filename) = "$$file" ]; then \
			echo "Removing symlink $(BIN_DIR)/$$filename"; \
			sudo rm -f $(BIN_DIR)/$$filename; \
		fi; \
	done
	@for file in $(DOTFILES_DIR)/xbar/*; do \
		filename=$$(basename $$file); \
		rm -f "$(XBAR_PLUGINS_DIR)/$$filename"; \
	done
	@for file in $(DOTFILES_DIR)/menubar/*; do \
		filename=$$(basename $$file); \
		rm -f "$(HOME_DIR)/.local/bin/$$filename"; \
	done

# Help target
.PHONY: help
help:
	@echo "Dotfiles Installation Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all             - Default target, same as install"
	@echo "  install         - Install all dotfiles and required packages"
	@echo "  install_packages - Install required packages (yabai, skhd, xbar)"
	@echo "  start_services  - Start yabai and skhd services"
	@echo "  ensure_services_running - Make sure all services are running"
	@echo "  uninstall       - Remove all installed dotfiles"
	@echo "  help            - Show this help message"
	@echo ""
	@echo "Individual installation targets:"
	@echo "  check_brew      - Check if Homebrew is installed"
	@echo "  create_dirs     - Create necessary directories"
	@echo "  install_configs - Install configuration files"
	@echo "  install_bin     - Install bin scripts"
	@echo "  install_xbar    - Install xbar plugins"
	@echo "  check-chrome-profiles - Check Chrome profile environment variables"
	@echo "  list-chrome-profiles - List available Chrome profiles"
	@echo "  set-chrome-profile - Set Chrome profile environment variable"

# Check Chrome profile environment variables (now sourcing ~/.profile first)
check-chrome-profiles:
	@echo "Checking Chrome profile environment variables..."
	@if [ -f "$(HOME)/.profile" ]; then \
		echo "Sourcing ~/.profile to check for Chrome profile variables..."; \
		CHROME_PROFILE_WORK=$$(source "$(HOME)/.profile" 2>/dev/null && echo "$$CHROME_PROFILE_WORK"); \
		CHROME_PROFILE_PERSONAL=$$(source "$(HOME)/.profile" 2>/dev/null && echo "$$CHROME_PROFILE_PERSONAL"); \
		CHROME_PROFILE_DEFAULT=$$(source "$(HOME)/.profile" 2>/dev/null && echo "$$CHROME_PROFILE_DEFAULT"); \
		if [ -z "$$CHROME_PROFILE_WORK" ]; then \
			echo "WARNING: CHROME_PROFILE_WORK is not defined in ~/.profile"; \
			echo "Run 'make list-chrome-profiles' to see available profiles"; \
			echo "Then set it with 'make set-chrome-profile PROFILE_TYPE=WORK PROFILE_NAME=YourProfileName'"; \
		else \
			echo "CHROME_PROFILE_WORK is set to: $$CHROME_PROFILE_WORK"; \
		fi; \
		if [ -z "$$CHROME_PROFILE_PERSONAL" ]; then \
			echo "WARNING: CHROME_PROFILE_PERSONAL is not defined in ~/.profile"; \
		else \
			echo "CHROME_PROFILE_PERSONAL is set to: $$CHROME_PROFILE_PERSONAL"; \
		fi; \
		if [ -z "$$CHROME_PROFILE_DEFAULT" ]; then \
			echo "WARNING: CHROME_PROFILE_DEFAULT is not defined in ~/.profile"; \
		else \
			echo "CHROME_PROFILE_DEFAULT is set to: $$CHROME_PROFILE_DEFAULT"; \
		fi; \
	else \
		echo "~/.profile doesn't exist yet. Run 'make ensure-profile' first."; \
		echo "Then set Chrome profiles with 'make set-chrome-profile PROFILE_TYPE=TYPE PROFILE_NAME=NAME'"; \
	fi

# List available Chrome profiles
list-chrome-profiles:
	@echo "Listing available Chrome profiles..."
	@if [ -d "$$HOME/Library/Application Support/Google/Chrome" ]; then \
		echo "Found profiles on macOS:"; \
		ls -1 "$$HOME/Library/Application Support/Google/Chrome" | grep -E "Profile|Default"; \
	elif [ -d "$$HOME/.config/google-chrome" ]; then \
		echo "Found profiles on Linux:"; \
		ls -1 "$$HOME/.config/google-chrome" | grep -E "Profile|Default"; \
	elif [ -d "$$LOCALAPPDATA/Google/Chrome/User Data" ]; then \
		echo "Found profiles on Windows:"; \
		ls -1 "$$LOCALAPPDATA/Google/Chrome/User Data" | grep -E "Profile|Default"; \
	else \
		echo "No Chrome profiles found in standard locations."; \
	fi

# Set Chrome profile environment variable
set-chrome-profile:
	@if [ -z "$(PROFILE_TYPE)" ] || [ -z "$(PROFILE_NAME)" ]; then \
		echo "Usage: make set-chrome-profile PROFILE_TYPE=WORK|PERSONAL|DEFAULT PROFILE_NAME=YourProfileName"; \
		exit 1; \
	fi
	@echo "Setting CHROME_PROFILE_$(PROFILE_TYPE)=$(PROFILE_NAME)"
	@echo "export CHROME_PROFILE_$(PROFILE_TYPE)=\"$(PROFILE_NAME)\"" >> $(HOME)/.profile
	@echo "Added to ~/.profile. Restart your terminal or run 'source ~/.profile'"
	@echo "Note: Make sure your ~/.zshrc sources ~/.profile for these settings to take effect"

# Detect shell type
SHELL_TYPE := $(shell if [ -n "$$ZSH_VERSION" ]; then echo "zsh"; elif [ -n "$$BASH_VERSION" ]; then echo "bash"; else echo "unknown"; fi)

# Create directory for xbar plugins if it doesn't exist
$(XBAR_PLUGINS_DIR):
	@echo "Creating xbar plugins directory..."
	@mkdir -p "$(HOME)/Library/Application Support/xbar/plugins"

# Symlink menubar scripts to xbar plugins folder
install-xbar-menubar-scripts: 
	@echo "Creating xbar plugins directory if needed..."
	@mkdir -p "$(HOME)/Library/Application Support/xbar/plugins"
	@echo "Symlinking menubar scripts to xbar plugins folder..."
	@for script in $(shell find ./menubar -name "*.sh" -o -name "*.py" -o -name "*.js" 2>/dev/null); do \
		chmod +x "$$script"; \
		ln -sf "$(PWD)/$$script" "$(HOME)/Library/Application Support/xbar/plugins/$$(basename $$script)"; \
		echo "Linked: $$script"; \
	done

# Symlink zshrc from the repo to ~/.zshrc
install-zshrc:
	@echo "Setting up ~/.zshrc as symlink to repository zshrc..."
	@if [ -f "$(HOME)/.zshrc" ] && [ ! -L "$(HOME)/.zshrc" ]; then \
		echo "Backing up existing ~/.zshrc to ~/.zshrc.backup"; \
		mv "$(HOME)/.zshrc" "$(HOME)/.zshrc.backup"; \
	fi
	@ln -sf "$(PWD)/zshrc" "$(HOME)/.zshrc"
	@echo "Created symlink: $(HOME)/.zshrc -> $(PWD)/zshrc"

# Ensure profile exists for machine-specific settings (if it doesn't exist yet)
ensure-profile:
	@if [ ! -f "$(HOME)/.profile" ]; then \
		echo "Creating ~/.profile for machine-specific settings..."; \
		echo "# Machine-specific settings - not managed by git" > "$(HOME)/.profile"; \
		echo "# Add your machine-specific environment variables and settings here" >> "$(HOME)/.profile"; \
		echo "" >> "$(HOME)/.profile"; \
	else \
		echo "~/.profile already exists for machine-specific settings"; \
	fi
	@echo "Note: Make sure your ~/.zshrc sources ~/.profile for machine-specific settings" 