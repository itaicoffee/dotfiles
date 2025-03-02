# Dotfiles Installation Makefile
# This Makefile creates symbolic links and sets permissions for dotfiles

# Define variables
DOTFILES_DIR := $(shell pwd)
HOME_DIR := $(HOME)
BIN_DIR := /usr/local/bin
CONFIG_DIR := $(HOME_DIR)/.config
XBAR_PLUGINS_DIR := $(HOME_DIR)/Library/Application\ Support/xbar/plugins

# Default target
.PHONY: all
all: install

# Main installation target
.PHONY: install
install: check_brew install_packages create_dirs install_configs install_bin install_xbar ensure_services_running

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
			echo "⚠️ Warning: WezTerm application found but CLI not found at expected location"; \
		fi \
	fi

# Create necessary directories
.PHONY: create_dirs
create_dirs:
	@echo "Creating necessary directories..."
	@mkdir -p $(CONFIG_DIR)/yabai
	@mkdir -p $(CONFIG_DIR)/skhd
	@mkdir -p "$(XBAR_PLUGINS_DIR)"
	@mkdir -p $(HOME_DIR)/.local/bin
	@if [ ! -d $(BIN_DIR) ]; then \
		echo "Warning: $(BIN_DIR) does not exist. You may need to create it manually with sudo."; \
		echo "Run: sudo mkdir -p $(BIN_DIR)"; \
		exit 1; \
	fi

# Install configuration files
.PHONY: install_configs
install_configs:
	@echo "Installing configuration files..."
	@ln -sf $(DOTFILES_DIR)/yabairc $(CONFIG_DIR)/yabai/yabairc
	@ln -sf $(DOTFILES_DIR)/skhdrc $(CONFIG_DIR)/skhd/skhdrc
	@ln -sf $(DOTFILES_DIR)/profile $(HOME_DIR)/.profile
	@ln -sf $(DOTFILES_DIR)/book_config.json $(HOME_DIR)/.book_config.json

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
	@if ! pgrep -q yabai; then \
		echo "yabai is not running, starting it..."; \
		yabai --start-service || echo "Failed to start yabai. Try starting manually with 'yabai --start-service'"; \
	else \
		echo "yabai is already running"; \
	fi
	@if ! pgrep -q skhd; then \
		echo "skhd is not running, starting it..."; \
		skhd --start-service || echo "Failed to start skhd. Try starting manually with 'skhd --start-service'"; \
	else \
		echo "skhd is already running"; \
	fi
	@if ! pgrep -q xbar; then \
		echo "xbar is not running, starting it..."; \
		open -a xbar || echo "Failed to start xbar"; \
	else \
		echo "xbar is already running"; \
	fi

# Uninstall everything
.PHONY: uninstall
uninstall:
	@echo "Uninstalling dotfiles..."
	@rm -f $(CONFIG_DIR)/yabai/yabairc
	@rm -f $(CONFIG_DIR)/skhd/skhdrc
	@rm -f $(HOME_DIR)/.profile
	@rm -f $(HOME_DIR)/.book_config.json
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