#!/bin/sh

# Force Xcode Cloud to only build for Apple Silicon (arm64)
# This prevents the build from attempting to compile for Intel (x86_64),
# which resolves the 'Float16 is unavailable' error.

export ARCHS="arm64"
export ONLY_ACTIVE_ARCH="YES"
export VALID_ARCHS="arm64"