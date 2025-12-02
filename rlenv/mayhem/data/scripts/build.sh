#!/bin/bash
set -euo pipefail

# RLENV Build Script
# This script rebuilds the application from source located at /rlenv/source/pocketlang/
#
# Original image: ghcr.io/mayhemheroes/pocketlang:master
# Git revision: 68ae71b3d56a017a77f6b11a7dda0b04a36ddf92

# ============================================================================
# Environment Variables
# ============================================================================
# No special environment variables needed for this C project

# ============================================================================
# REQUIRED: Change to Source Directory
# ============================================================================
cd /rlenv/source/pocketlang/

# ============================================================================
# Clean Previous Build (recommended)
# ============================================================================
# Remove old build artifacts to ensure fresh rebuild
echo "Cleaning previous build artifacts..."
make clean || true
rm -rf build/

# ============================================================================
# Build Commands (NO NETWORK, NO PACKAGE INSTALLATION)
# ============================================================================
echo "Building pocketlang..."
make -j8

# The Makefile builds the debug target by default
# Output: ./build/Debug/bin/pocket

# ============================================================================
# Copy Artifacts (use 'cat >' for busybox compatibility)
# ============================================================================
# Ensure target directory exists
mkdir -p /repo/build/Debug/bin

# Copy built executable to expected location
echo "Copying build artifact to /repo/build/Debug/bin/pocket..."
cat build/Debug/bin/pocket > /repo/build/Debug/bin/pocket

# ============================================================================
# Set Permissions
# ============================================================================
chmod 777 /repo/build/Debug/bin/pocket 2>/dev/null || true

# 777 allows validation script (running as UID 1000) to overwrite during rebuild
# 2>/dev/null || true prevents errors if chmod not available

# ============================================================================
# REQUIRED: Verify Build Succeeded
# ============================================================================
if [ ! -f /repo/build/Debug/bin/pocket ]; then
    echo "Error: Build artifact not found at /repo/build/Debug/bin/pocket"
    exit 1
fi

# Verify executable bit
if [ ! -x /repo/build/Debug/bin/pocket ]; then
    echo "Warning: Build artifact is not executable, setting executable bit..."
    chmod +x /repo/build/Debug/bin/pocket 2>/dev/null || true
fi

# Verify file size
SIZE=$(stat -c%s /repo/build/Debug/bin/pocket 2>/dev/null || stat -f%z /repo/build/Debug/bin/pocket 2>/dev/null || echo 0)
if [ "$SIZE" -lt 1000 ]; then
    echo "Warning: Build artifact is suspiciously small ($SIZE bytes)"
fi

echo "Build completed successfully: /repo/build/Debug/bin/pocket ($SIZE bytes)"
