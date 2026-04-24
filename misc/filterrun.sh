#!/usr/bin/env bash

set -e  # Exit immediately if a command fails

# --- Paths ---
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_ROOT/filters/build"

echo "==> Project root: $PROJECT_ROOT"
echo "==> Build dir: $BUILD_DIR"

# --- Create build directory if needed ---
mkdir -p "$BUILD_DIR"

# --- Configure with CMake ---
echo "==> Running CMake..."
cd "$BUILD_DIR"
cmake ..

# --- Build ---
echo "==> Building..."
make -j$(nproc)

# --- Run executable ---
echo "==> Running filter_test..."
./filter_test

# --- Return to root ---
cd "$PROJECT_ROOT"

# --- Run parser ---
echo "==> Running parser..."
python3 parser.py

echo "==> Done!"

