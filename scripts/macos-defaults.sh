#!/usr/bin/env bash
# macos-defaults.sh — Declarative macOS preferences
# Idempotent: safe to re-run at any time.
# Translated from nix-darwin system.defaults configuration.
set -euo pipefail

echo "==> Applying macOS defaults..."

# Gating helpers: some defaults keys are perf-oriented (Intel-only) or were
# reworked in Tahoe (macOS 26) and may be inert on newer systems.
ARCH="$(uname -m)"
MACOS_MAJOR="$(sw_vers -productVersion 2>/dev/null | cut -d. -f1)"
: "${MACOS_MAJOR:=0}"

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
# Tahoe reworked Finder's title bar; the undocumented POSIX-path key may be inert on 26+.
if [[ "$MACOS_MAJOR" -lt 26 ]]; then
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
fi

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
# Tahoe (26+) reworked menu-bar internals; these NSStatusItem keys may be inert.
# Skip on 26+ to avoid noise; configure manually via System Settings if needed.
if [[ "$MACOS_MAJOR" -lt 26 ]]; then
  # Sound: Always show in menu bar
  defaults write com.apple.controlcenter "NSStatusItem Visible AudioVideoModule" -int 1
  defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -int 1
  defaults -currentHost write com.apple.controlcenter Sound -int 18

  # Now Playing: Always hide from menu bar
  defaults write com.apple.controlcenter "NSStatusItem Visible NowPlaying" -int 0
  defaults -currentHost write com.apple.controlcenter NowPlaying -int 8
fi

# ==============================================================================
# Custom User Preferences — Locale, weekday, date format
# ==============================================================================
defaults write NSGlobalDomain AppleLocale -string "en_MX"
defaults write NSGlobalDomain AppleFirstWeekday -dict gregorian -int 2     # Monday
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict 1 -string "y-MM-dd"

# ==============================================================================
# Spotlight
# ==============================================================================
# Tahoe (26+) added AI-powered Spotlight Actions on top of the mdutil index;
# disabling it kills those features and degrades Raycast/Mail/Notes search.
# The menu-bar Spotlight icon is also now managed via Control Center on 26+,
# so MenuItemHidden may be inert. Gate to pre-Tahoe.
if [[ "$MACOS_MAJOR" -lt 26 ]]; then
  defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1
fi
# NOTE: Cmd+Space / Cmd+Option+Space (Spotlight shortcuts) are disabled in
# scripts/import-prefs.sh after the symbolichotkeys import, so Raycast can claim them.

# ==============================================================================
# Accessibility
# ==============================================================================
# Reduce Motion / Transparency were added as a performance tweak for older Intel
# Macs. Apple Silicon doesn't need them, and the previous `sudo defaults write`
# version wrote to root's prefs (not the current user), so this never worked on
# Apple Silicon anyway. Gate to Intel only; on M-series this becomes a no-op.
if [[ "$ARCH" == "x86_64" ]]; then
  defaults write com.apple.universalaccess reduceMotion -bool true
  defaults write com.apple.universalaccess reduceTransparency -bool true
fi

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

  # Customize Expanded Control Strip items
  defaults write com.apple.controlstrip FullCustomized -array \
    "com.apple.system.group.brightness" \
    "com.apple.system.group.keyboard-brightness" \
    "com.apple.system.mission-control" \
    "com.apple.system.launchpad" \
    "com.apple.system.group.media" \
    "com.apple.system.group.volume"
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
