# Dotfiles Installation Makefile
# This Makefile creates symbolic links and sets permissions for dotfiles.
# Everything installs into $HOME (no sudo required): bin scripts go to
# ~/.local/bin. Legacy /usr/local/bin symlinks from older installs can be
# removed with `make cleanup-legacy-bin`.

# Define variables
DOTFILES_DIR := $(shell pwd)
HOME_DIR := $(HOME)
BIN_DIR := $(HOME_DIR)/.local/bin
CONFIG_DIR := $(HOME_DIR)/.config
XBAR_PLUGINS_DIR := $(HOME_DIR)/Library/Application\ Support/xbar/plugins
LEGACY_BIN_DIR := /usr/local/bin

# Default target
.PHONY: all
all: install

# Main installation target
# Note: check-chrome-profiles is interactive and intentionally NOT part of
# install. Run it separately when setting up a new machine.
.PHONY: install
install: check_brew install_packages create_dirs install_configs install_bin install_xbar install-zshrc ensure-profile ensure_services_running

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
	@if ! brew list zoxide &>/dev/null; then \
		echo "Installing zoxide..."; \
		brew install zoxide; \
	else \
		echo "zoxide is already installed"; \
	fi
	@if ! command -v wezterm &>/dev/null; then \
		echo "Setting up wezterm CLI..."; \
		mkdir -p $(BIN_DIR); \
		if [ -f /Applications/WezTerm.app/Contents/Resources/wezterm ]; then \
			ln -sfn /Applications/WezTerm.app/Contents/Resources/wezterm $(BIN_DIR)/wezterm; \
		elif [ -f $(HOME)/Applications/WezTerm.app/Contents/Resources/wezterm ]; then \
			ln -sfn $(HOME)/Applications/WezTerm.app/Contents/Resources/wezterm $(BIN_DIR)/wezterm; \
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
	@mkdir -p $(BIN_DIR)

# Install configuration files
.PHONY: install_configs
install_configs:
	@echo "Installing configuration files..."
	@ln -sfn $(DOTFILES_DIR)/yabairc $(CONFIG_DIR)/yabai/yabairc
	@ln -sfn $(DOTFILES_DIR)/skhdrc $(CONFIG_DIR)/skhd/skhdrc
	@ln -sfn $(DOTFILES_DIR)/book_config.json $(CONFIG_DIR)/book/config.json
	@ln -sfn $(DOTFILES_DIR)/wezterm.lua $(CONFIG_DIR)/wezterm/wezterm.lua

# Install bin scripts (~/.local/bin, no sudo needed)
.PHONY: install_bin
install_bin:
	@echo "Installing bin scripts to $(BIN_DIR)..."
	@mkdir -p $(BIN_DIR)
	@for file in $(DOTFILES_DIR)/bin/*; do \
		filename=$$(basename $$file); \
		if [ "$$filename" = "dict" ]; then continue; fi; \
		chmod +x "$$file"; \
		ln -sfn "$$file" "$(BIN_DIR)/$$filename"; \
		echo "Linked: $$filename"; \
	done

# Install xbar plugins (incl. menubar scripts)
.PHONY: install_xbar
install_xbar:
	@echo "Installing xbar plugins..."
	@mkdir -p "$(XBAR_PLUGINS_DIR)"
	@for file in $(DOTFILES_DIR)/xbar/* $(DOTFILES_DIR)/menubar/*; do \
		filename=$$(basename $$file); \
		chmod +x "$$file"; \
		ln -sfn "$$file" "$(XBAR_PLUGINS_DIR)/$$filename"; \
		echo "Linked: $$filename"; \
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
	@rm -f $(CONFIG_DIR)/book/config.json
	@rm -f $(CONFIG_DIR)/wezterm/wezterm.lua
	@if [ -L "$(HOME_DIR)/.zshrc" ] && [ "$$(readlink "$(HOME_DIR)/.zshrc")" = "$(DOTFILES_DIR)/zshrc" ]; then \
		echo "Removing ~/.zshrc symlink"; \
		rm "$(HOME_DIR)/.zshrc"; \
		if [ -f "$(HOME_DIR)/.zshrc.backup" ]; then \
			echo "Restoring ~/.zshrc.backup"; \
			mv "$(HOME_DIR)/.zshrc.backup" "$(HOME_DIR)/.zshrc"; \
		fi; \
	fi
	@for file in $(DOTFILES_DIR)/bin/*; do \
		filename=$$(basename $$file); \
		if [ -L "$(BIN_DIR)/$$filename" ] && [ "$$(readlink "$(BIN_DIR)/$$filename")" = "$$file" ]; then \
			echo "Removing $(BIN_DIR)/$$filename"; \
			rm -f "$(BIN_DIR)/$$filename"; \
		fi; \
	done
	@for file in $(DOTFILES_DIR)/xbar/* $(DOTFILES_DIR)/menubar/*; do \
		filename=$$(basename $$file); \
		rm -f "$(XBAR_PLUGINS_DIR)/$$filename"; \
	done
	@echo "~/.profile was kept (it holds machine-specific settings). Remove it manually if desired."

# Remove symlinks that older versions of this Makefile created in /usr/local/bin
.PHONY: cleanup-legacy-bin
cleanup-legacy-bin:
	@echo "Removing legacy symlinks from $(LEGACY_BIN_DIR) (requires sudo)..."
	@for file in $(DOTFILES_DIR)/bin/*; do \
		filename=$$(basename $$file); \
		if [ -L "$(LEGACY_BIN_DIR)/$$filename" ] && [ "$$(readlink "$(LEGACY_BIN_DIR)/$$filename")" = "$$file" ]; then \
			echo "Removing $(LEGACY_BIN_DIR)/$$filename"; \
			sudo rm -f "$(LEGACY_BIN_DIR)/$$filename"; \
		fi; \
	done
	@echo "Done."

# Lint shell configs and scripts (informational)
.PHONY: lint
lint:
	@echo "Linting..."
	@zsh -n $(DOTFILES_DIR)/zshrc && echo "zshrc: OK"
	@if command -v shellcheck >/dev/null 2>&1; then \
		scripts=$$(find $(DOTFILES_DIR)/bin $(DOTFILES_DIR)/xbar $(DOTFILES_DIR)/menubar -type f ! -name "dict" -exec file {} + | grep -i "shell script" | cut -d: -f1); \
		scripts="$$scripts $(DOTFILES_DIR)/chrome-profiles-setup.sh"; \
		echo $$scripts | xargs -n1 shellcheck || echo "shellcheck found issues (see above)"; \
	else \
		echo "shellcheck not installed — run: brew install shellcheck"; \
	fi

# Help target
.PHONY: help
help:
	@echo "Dotfiles Installation Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all                     - Default target, same as install"
	@echo "  install                 - Install all dotfiles and required packages"
	@echo "  install_packages        - Install required packages (yabai, skhd, xbar, wezterm, zoxide)"
	@echo "  start_services          - Start yabai and skhd services"
	@echo "  ensure_services_running - Make sure all services are running"
	@echo "  uninstall               - Remove all installed dotfiles"
	@echo "  cleanup-legacy-bin      - Remove old /usr/local/bin symlinks (needs sudo)"
	@echo "  lint                    - Lint zshrc and shell scripts"
	@echo "  help                    - Show this help message"
	@echo ""
	@echo "Individual installation targets:"
	@echo "  check_brew      - Check if Homebrew is installed"
	@echo "  create_dirs     - Create necessary directories"
	@echo "  install_configs - Install configuration files"
	@echo "  install_bin     - Install bin scripts to ~/.local/bin"
	@echo "  install_xbar    - Install xbar plugins"
	@echo "  install-zshrc   - Symlink ~/.zshrc to the repo zshrc"
	@echo "  ensure-profile  - Create local ~/.profile for machine-specific settings"
	@echo ""
	@echo "Chrome profiles:"
	@echo "  check-chrome-profiles  - Interactively match Chrome profiles to WORK/PERSONAL/DEFAULT"
	@echo "  list-chrome-profiles   - List available Chrome profiles"
	@echo "  set-chrome-profile     - Set Chrome profile environment variable"

# Interactively match available Chrome profiles to WORK/PERSONAL/DEFAULT.
# Reads the profiles that actually exist on this machine and prompts for any
# CHROME_PROFILE_* that isn't already set in ~/.profile (see
# chrome-profiles-setup.sh). Already-set values are left untouched.
.PHONY: check-chrome-profiles
check-chrome-profiles:
	@bash "$(DOTFILES_DIR)/chrome-profiles-setup.sh"

# List available Chrome profiles
.PHONY: list-chrome-profiles
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
.PHONY: set-chrome-profile
set-chrome-profile:
	@if [ -z "$(PROFILE_TYPE)" ] || [ -z "$(PROFILE_NAME)" ]; then \
		echo "Usage: make set-chrome-profile PROFILE_TYPE=WORK|PERSONAL|DEFAULT PROFILE_NAME=YourProfileName"; \
		exit 1; \
	fi
	@echo "Setting CHROME_PROFILE_$(PROFILE_TYPE)=$(PROFILE_NAME)"
	@echo "export CHROME_PROFILE_$(PROFILE_TYPE)=\"$(PROFILE_NAME)\"" >> $(HOME)/.profile
	@echo "Added to ~/.profile. Restart your terminal or run 'source ~/.profile'"

# Symlink zshrc from the repo to ~/.zshrc
.PHONY: install-zshrc
install-zshrc:
	@echo "Setting up ~/.zshrc as symlink to repository zshrc..."
	@if [ -f "$(HOME)/.zshrc" ] && [ ! -L "$(HOME)/.zshrc" ]; then \
		echo "Backing up existing ~/.zshrc to ~/.zshrc.backup"; \
		mv "$(HOME)/.zshrc" "$(HOME)/.zshrc.backup"; \
	fi
	@ln -sf "$(DOTFILES_DIR)/zshrc" "$(HOME)/.zshrc"
	@echo "Created symlink: $(HOME)/.zshrc -> $(DOTFILES_DIR)/zshrc"

# Ensure ~/.profile exists as a real (non-symlink) local file for
# machine-specific settings. Migrates the old repo-symlink setup.
.PHONY: ensure-profile
ensure-profile:
	@if [ -L "$(HOME_DIR)/.profile" ]; then \
		echo "Converting ~/.profile from symlink to a real local file..."; \
		tmp=$$(mktemp); \
		cat "$(HOME_DIR)/.profile" > "$$tmp"; \
		rm "$(HOME_DIR)/.profile"; \
		mv "$$tmp" "$(HOME_DIR)/.profile"; \
	fi
	@if [ ! -f "$(HOME_DIR)/.profile" ]; then \
		echo "Creating ~/.profile for machine-specific settings..."; \
		printf '# Machine-specific settings - not managed by git.\n' > "$(HOME_DIR)/.profile"; \
		printf '# Add your machine-specific environment variables and settings here\n\n' >> "$(HOME_DIR)/.profile"; \
	else \
		echo "~/.profile exists for machine-specific settings"; \
	fi
