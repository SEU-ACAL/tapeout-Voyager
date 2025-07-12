#!/bin/bash
#
# Utilities Library
# All-in-one utility library for bash scripts

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_ERROR=1

# Simple logging functions
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

# Safe file copy
safe_copy_file() {
    local src_file="$1"
    local dst_file="$2"
    
    if [[ ! -f "$src_file" ]]; then
        log_error "Source file not found: $src_file"
        return 1
    fi
    
    local dst_dir
    dst_dir="$(dirname "$dst_file")"
    
    if [[ ! -d "$dst_dir" ]]; then
        if ! mkdir -p "$dst_dir" 2>/dev/null; then
            log_error "Failed to create directory: $dst_dir"
            return 1
        fi
    fi
    
    if cp "$src_file" "$dst_file" 2>/dev/null; then
        return 0
    else
        log_error "File copy failed: $src_file -> $dst_file"
        return 1
    fi
}

# Safe directory operations
safe_create_directory() {
    local dir_path="$1"
    
    if [[ -d "$dir_path" ]]; then
        return 0
    fi
    
    if mkdir -p "$dir_path" 2>/dev/null; then
        return 0
    else
        log_error "Failed to create directory: $dir_path"
        return 1
    fi
}

safe_remove_directory() {
    local dir_path="$1"
    
    if [[ ! -d "$dir_path" ]]; then
        return 0
    fi
    
    if ! rm -rf "$dir_path" 2>/dev/null; then
        log_error "Failed to remove directory: $dir_path"
        return 1
    fi
    
    return 0
} 