#!/usr/bin/env bash
# macos-defaults.sh — Declarative macOS preferences
# Idempotent: safe to re-run at any time.
# Translated from nix-darwin system.defaults configuration.
set -euo pipefail

echo "==> Applying macOS defaults..."

[ "$EUID" -ne 0 ] && echo "Sudo is required to disable spotlight"

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
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
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
# Keyboard & Text Input
# ==============================================================================
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool false
defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false

# ==============================================================================
# Keyboard Layouts
# ==============================================================================
defaults write com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID -string "com.apple.keylayout.LatinAmerican"
defaults write com.apple.TextInputMenu visible -bool true

# ==============================================================================
# Control Center
# ==============================================================================
# Sound: Always show in menu bar
defaults write com.apple.controlcenter "NSStatusItem Visible AudioVideoModule" -int 1
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -int 1
defaults -currentHost write com.apple.controlcenter Sound -int 18

# Now Playing: Always hide from menu bar
defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -int 0
defaults -currentHost write com.apple.controlcenter NowPlaying -int 8

# ==============================================================================
# Custom User Preferences — Locale, weekday, date format
# ==============================================================================
defaults write NSGlobalDomain AppleLocale -string "en_MX"
defaults write NSGlobalDomain AppleFirstWeekday -dict gregorian -int 2     # Monday
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict 1 -string "y-MM-dd"

# ==============================================================================
# Spotlight
# ==============================================================================
# Hide menu bar icon
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

# Disable indexing on all mounted volumes
sudo mdutil -a -i off 2>/dev/null || true

# ==============================================================================
# Accessibility
# ==============================================================================
# Disable Visual "Eye Candy" (Reduce motion and transparency) for better performance
# Note: Sudo is required for universalaccess on this system
sudo defaults write com.apple.universalaccess reduceMotion -bool true
sudo defaults write com.apple.universalaccess reduceTransparency -bool true

# ==============================================================================
# Touch Bar
# ==============================================================================
# Only apply if Touch Bar hardware is detected
if ioreg -l | grep "Touch Bar" > /dev/null; then
  echo "==> Configuring Touch Bar..."
  # Touch Bar shows: Expanded Control Strip
  defaults write com.apple.touchbar.agent PresentationModeGlobal -string fullControlStrip

  # Press and hold fn key to: Show F1, F2, etc. Keys
  defaults write com.apple.touchbar.agent PresentationModeFnModes -dict-add fullControlStrip functionKeys

  # Show typing suggestions: OFF
  defaults write NSGlobalDomain NSAutomaticTypingSuggestionEnabled -bool false
fi

# ==============================================================================
# Apply settings without requiring logout
# ==============================================================================
echo "==> Restarting affected services..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
killall ControlCenter 2>/dev/null || true
killall ControlStrip 2>/dev/null || true
killall TouchBarServer 2>/dev/null || true

# Activate system settings changes
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true

echo "==> macOS defaults applied."
echo
echo "    NOTE: Keyboard layouts and system shortcuts require a logout/login to take effect."
