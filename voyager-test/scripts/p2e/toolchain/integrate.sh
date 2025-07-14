#!/bin/bash
#
# FPGA to XEPIC Migration Script

set -euo pipefail

# Script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load libraries
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/migrate_processor.sh"

# Usage
usage() {
    echo "Usage: $0 <source_directory> [output_directory]"
    echo ""
    echo "  source_directory   Directory containing Verilog files"
    echo "  output_directory   Output directory (default: modified_v)"
    exit "$EXIT_SUCCESS"
}

# Parse arguments
if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

SOURCE_DIR="$1"
OUTPUT_DIR="${2:-gen-collateral}"

# Validate source directory
if [[ ! -d "$SOURCE_DIR" ]]; then
    log_error "Source directory not found: $SOURCE_DIR"
    exit "$EXIT_ERROR"
fi

# Check required files
for file in "${VERILOG_FILES[@]}"; do
    if [[ ! -f "$SOURCE_DIR/$file" ]]; then
        log_error "Required file not found: $file"
        exit "$EXIT_ERROR"
    fi
done

# Setup output directory
# if [[ -d "$OUTPUT_DIR" ]]; then
#     log_info "Removing existing output directory: $OUTPUT_DIR"
#     safe_remove_directory "$OUTPUT_DIR" || exit "$EXIT_ERROR"
# fi
if [[ -d "$OUTPUT_DIR" ]]; then
    log_info "Output directory exists, will update files: $OUTPUT_DIR"
    # only delete the files that are in the list
    if [[ "$SOURCE_DIR" != "$OUTPUT_DIR" ]]; then
        rm -f "$OUTPUT_DIR/VCU118FPGATestHarness.sv" "$OUTPUT_DIR/XilinxVCU118MIGIsland.sv"
    fi
else
    log_info "Creating output directory: $OUTPUT_DIR"
    safe_create_directory "$OUTPUT_DIR" || exit "$EXIT_ERROR"
fi


# Process files
log_info "Processing VCU118FPGATestHarness.sv..."
if ! process_test_harness_file "$SOURCE_DIR" "$OUTPUT_DIR"; then
    log_error "Failed to process VCU118FPGATestHarness.sv"
    exit "$EXIT_ERROR"
fi

log_info "Processing XilinxVCU118MIGIsland.sv..."
if ! process_mig_island_file "$SOURCE_DIR" "$OUTPUT_DIR"; then
    log_error "Failed to process XilinxVCU118MIGIsland.sv"
    exit "$EXIT_ERROR"
fi

# Validate results
if ! validate_processing_results "$OUTPUT_DIR"; then
    log_error "Processing validation failed"
    exit "$EXIT_ERROR"
fi

log_info "Migration completed successfully"
log_info "Output directory: $OUTPUT_DIR" 