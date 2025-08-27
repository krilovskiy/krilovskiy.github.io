#!/bin/bash

# Script to copy codebase content to clipboard with flexible filtering
# Usage: ./copy.sh [include_types] [include_dirs] [exclude_types] [exclude_dirs]
# Example: ./copy.sh "go,yaml,sh" "." "png,jpg,jpeg" ".*,gen,thirdparty,external"

set -e

# Default values
INCLUDE_TYPES="${1:-*}"           # File types to include (e.g., "go,yaml,sh" or "*" for all)
INCLUDE_DIRS="${2:-.}"            # Directories to search (comma-separated)
EXCLUDE_TYPES="${3:-png,jpg,jpeg,gif,pdf,zip,tar,gz}" # File types to exclude
EXCLUDE_DIRS="${4:-.*,gen,thirdparty,external,vendor,node_modules,dist,build}"  # Directories to exclude

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

# Build find command
build_find_command() {
    local find_cmd="find"
    
    # Add include directories
    IFS=',' read -ra DIRS <<< "$INCLUDE_DIRS"
    for dir in "${DIRS[@]}"; do
        find_cmd="$find_cmd $dir"
    done
    
    # Add excluded directories
    local prune_args=""
    IFS=',' read -ra EXCLUDED <<< "$EXCLUDE_DIRS"
    for excl in "${EXCLUDED[@]}"; do
        if [ -n "$prune_args" ]; then
            prune_args="$prune_args -o -path '*/$excl*'"
        else
            prune_args="-path '*/$excl*'"
        fi
    done
    
    if [ -n "$prune_args" ]; then
        find_cmd="$find_cmd \( $prune_args \) -prune -o"
    fi
    
    # Add file type conditions
    find_cmd="$find_cmd -type f"
    
    # Add include file types
    if [ "$INCLUDE_TYPES" != "*" ]; then
        local include_args=""
        IFS=',' read -ra TYPES <<< "$INCLUDE_TYPES"
        for type in "${TYPES[@]}"; do
            if [ -n "$include_args" ]; then
                include_args="$include_args -o -iname '*.$type'"
            else
                include_args="-iname '*.$type'"
            fi
        done
        if [ -n "$include_args" ]; then
            find_cmd="$find_cmd \( $include_args \)"
        fi
    fi
    
    # Add exclude file types
    IFS=',' read -ra EXCL_TYPES <<< "$EXCLUDE_TYPES"
    for type in "${EXCL_TYPES[@]}"; do
        find_cmd="$find_cmd ! -iname '*.$type'"
    done
    
    echo "$find_cmd"
}

# Main execution
main() {
    print_info "📋 Copying codebase content to clipboard..."
    print_info "   Include types: $INCLUDE_TYPES"
    print_info "   Include dirs: $INCLUDE_DIRS"
    print_info "   Exclude types: $EXCLUDE_TYPES"
    print_info "   Exclude dirs: $EXCLUDE_DIRS"
    
    # Build and execute find command
    local find_cmd=$(build_find_command)
    
    # Count files
    local file_count=$(eval "$find_cmd -print" 2>/dev/null | wc -l)
    print_info "   Found $file_count files to copy"
    
    if [ "$file_count" -eq 0 ]; then
        print_warning "⚠️  No files found matching criteria"
        exit 0
    fi
    
    # Copy to clipboard
    (
        echo '```'
        eval "$find_cmd -print" 2>/dev/null | while read -r file; do
            # Check if file is text (not binary)
            if grep -Iq . "$file" 2>/dev/null; then
                printf "\n----- %s -----\n" "$file"
                # Escape triple backticks to prevent markdown issues
                sed 's/```/\\`\\`\\`/g' "$file"
            fi
        done
        echo '```'
    ) | pbcopy
    
    print_info "✅ Content copied to clipboard ($file_count files)"
}

# Check if pbcopy is available
if ! command -v pbcopy &> /dev/null; then
    print_error "❌ pbcopy command not found. This script requires macOS."
    exit 1
fi

# Run main function
main