#!/usr/bin/env bash
# macos-defaults.sh — Declarative macOS preferences
# Idempotent: safe to re-run at any time.
# Translated from nix-darwin system.defaults configuration.
set -euo pipefail

echo "==> Applying macOS defaults..."

# ==============================================================================
# Dock
# ==============================================================================
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 46
defaults write com.apple.dock tilesize -int 35
defaults write com.apple.dock mineffect -string "genie"
defaults write com.apple.dock static-only -bool true          # Show only open apps
defaults write com.apple.dock show-process-indicators -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock persistent-apps -array           # Remove all pinned apps
defaults write com.apple.dock wvous-tr-corner -int 2           # Top-right hot corner: Mission Control
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 3           # Bottom-right hot corner: Application Windows
defaults write com.apple.dock wvous-br-modifier -int 0

# ==============================================================================
# Finder
# ==============================================================================
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder CreateDesktop -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"       # Search current folder
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"       # Column view
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# ==============================================================================
# Window Manager
# ==============================================================================
defaults write com.apple.WindowManager GloballyEnabled -bool false
defaults write com.apple.WindowManager StandardHideWidgets -bool true
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# ==============================================================================
# Trackpad
# ==============================================================================
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true       # Tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 1

# ==============================================================================
# NSGlobalDomain — Appearance, units, keyboard
# ==============================================================================
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true
defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 1

# ==============================================================================
# Custom User Preferences — Locale, weekday, date format
# ==============================================================================
defaults write NSGlobalDomain AppleLocale -string "en_MX"
defaults write NSGlobalDomain AppleFirstWeekday -dict gregorian -int 2     # Monday
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict 1 -string "y-MM-dd"

# ==============================================================================
# Apply settings without requiring logout
# ==============================================================================
echo "==> Restarting affected services..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

# Activate system settings changes
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true

echo "==> macOS defaults applied."
