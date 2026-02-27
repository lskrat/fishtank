#!/bin/bash
set -e

# Define paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${PROJECT_ROOT}/release-linux"
ARCHIVE_NAME="openclaw-linux-x64.tar.gz"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH."
    echo "To build a Linux-compatible package on macOS, Docker is required to compile native dependencies (sharp, sqlite-vec, etc.) for Linux."
    echo "Please install Docker Desktop for Mac: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

echo ">>> Building OpenClaw for Linux (x64)..."

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Run the build inside a Node.js Docker container
# We mount the project root to /app
# We use a separate build directory inside the container to avoid polluting the host's node_modules
docker run --rm \
    -v "${PROJECT_ROOT}:/source" \
    -v "${OUTPUT_DIR}:/out" \
    node:22-bookworm bash -c '
    set -e
    
    echo ">>> Setting up build environment..."
    # Create a working directory
    mkdir -p /app
    cd /app
    
    # Copy necessary files for installation
    cp /source/package.json .
    cp /source/pnpm-lock.yaml .
    # Copy source code for building
    cp -r /source/src .
    cp -r /source/scripts .
    cp -r /source/extensions .
    cp -r /source/ui .
    cp /source/tsconfig.json .
    cp /source/openclaw.mjs .
    cp /source/.npmrc . 2>/dev/null || true
    
    echo ">>> Installing dependencies (Linux x64)..."
    npm install -g pnpm@10.23.0
    
    # Configure pnpm to use hoisted linker for easier portability
    pnpm config set node-linker hoisted
    
    # Install all dependencies (including devDeps for building)
    pnpm install --frozen-lockfile
    
    echo ">>> Building project..."
    pnpm build
    
    echo ">>> Pruning dev dependencies..."
    pnpm prune --prod
    
    echo ">>> Packaging..."
    # Create the final archive
    # We include: dist, node_modules, package.json, openclaw.mjs, extensions, skills
    # We explicitly exclude src, test, etc. to save space
    
    # Copy skills from source (they are not built)
    cp -r /source/skills .
    
    # Create the tarball
    tar -czf /out/openclaw-linux-x64.tar.gz \
        package.json \
        openclaw.mjs \
        dist \
        node_modules \
        extensions \
        skills

    # Create a README for the user
    cat > /out/README.txt <<EOF
OpenClaw Linux Package
======================

Installation Instructions:
1. Copy 'openclaw-linux-x64.tar.gz' to your Linux machine.
2. Ensure Node.js 22+ is installed on the Linux machine.
   (Download from https://nodejs.org/dist/v22.12.0/node-v22.12.0-linux-x64.tar.xz if offline)
3. Extract the package:
   mkdir -p openclaw
   tar -xzf openclaw-linux-x64.tar.gz -C openclaw
   cd openclaw
4. Run OpenClaw:
   node dist/index.js gateway run --port 18789

Note: This package includes Linux-compatible binaries for sqlite-vec, sharp, etc.
EOF
        
    echo ">>> Build complete inside container."
'

echo ">>> Success! Linux package created at: ${OUTPUT_DIR}/${ARCHIVE_NAME}"
echo ">>> You can now transfer ${ARCHIVE_NAME} to your offline Linux machine."
