#!/bin/sh

# Skip package plugin validation so Xcode Cloud doesn't hang or fail
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

# (Optional) Skip macro validation as well, just in case a package relies on macros
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES