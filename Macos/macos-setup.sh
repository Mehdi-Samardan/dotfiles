#!/usr/bin/env bash

echo "Applying Mehdi's macOS preferences..."

# =========================
# APPEARANCE
# =========================
defaults write -g AppleInterfaceStyle -string "Dark"
defaults write -g AppleAccentColor -int -1
defaults write -g AppleHighlightColor -string "0.000000 1.000000 0.498039"
defaults write -g AppleMenuBarFontSize -string "Large"
defaults write -g AppleReduceDesktopTinting -bool true

# =========================
# UI BEHAVIOR
# =========================
defaults write -g AppleShowScrollBars -string "WhenScrolling"
defaults write -g AppleActionOnDoubleClick -string "Maximize"
defaults write -g AppleWindowTabbingMode -string "always"
defaults write -g AppleSpacesSwitchOnActivate -bool true

# =========================
# KEYBOARD / TEXT
# =========================
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticInlinePredictionEnabled -bool false

# =========================
# FINDER
# =========================
defaults write com.apple.finder AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# =========================
# DOCK
# =========================
defaults write com.apple.dock show-recents -bool false

# =========================
# TRACKPAD
# =========================
defaults write -g com.apple.swipescrolldirection -bool false

# =========================
# SIRI
# =========================
defaults write com.apple.Siri VoiceTriggerUserEnabled -bool false

# =========================
# RESTART SERVICES
# =========================
killall Finder || true
killall Dock || true
killall SystemUIServer || true

echo "Done. Some changes may require logout/reboot."
