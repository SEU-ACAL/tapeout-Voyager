#!/bin/bash
#
# Migration Processor Library
# FPGA to XEPIC conversion logic
#
# This file uses externalized pattern/replacement management for better maintainability:
# - All sed patterns and replacements are loaded from pattern.sh
# - Python script templates are configurable via environment variables
# - Code is more readable and patterns can be easily modified in one place

# Load patterns (utils.sh is already loaded by main script)
PROCESSOR_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PROCESSOR_SCRIPT_DIR/pattern.sh"

# Note: utils.sh and its constants are loaded by the main script

# Validate that all required patterns are loaded
if ! validate_patterns; then
    log_error "模式验证失败，脚本无法继续执行"
    exit "$EXIT_ERROR"
fi

# ====================================================================
# NOTE: All patterns and replacements are now loaded from pattern.sh
# ====================================================================

# ====================================================================
# FUNCTIONS
# ====================================================================

# Add XEPIC macros to file
add_xepic_macros() {
    local target_file="$1"
    
    log_info "Adding XEPIC macros to: $(basename "$target_file")"
    
    local macro_definitions=""
    for macro in "${XEPIC_MACROS[@]}"; do
        macro_definitions="${macro_definitions}\`define $macro\\n"
    done
    
    if sed -i "/^module /i\\${macro_definitions}" "$target_file"; then
        return 0
    else
        return "$EXIT_ERROR"
    fi
}

# Process VCU118FPGATestHarness.sv
process_test_harness_file() {
    local src_dir="$1"
    local dst_dir="$2"
    
    local src_file="$src_dir/VCU118FPGATestHarness.sv"
    local dst_file="$dst_dir/VCU118FPGATestHarness.sv"
    
    if [[ ! -f "$src_file" ]]; then
        return "$EXIT_ERROR"
    fi
    
    if ! safe_copy_file "$src_file" "$dst_file"; then
        return "$EXIT_ERROR"
    fi
    
    add_xepic_macros "$dst_file" || return $?
    
    # Modify fpgaPLLIn_reset signal
    if ! sed -i "/${PATTERN_FPGA_PLL_RESET}/c\\${REPLACEMENT_FPGA_PLL_RESET}" "$dst_file"; then
        return "$EXIT_ERROR"
    fi
    
    # Modify system clock interface
    if ! sed -i "/${PATTERN_SYS_CLOCK_START}/,/${PATTERN_SYS_CLOCK_END}/c\\${REPLACEMENT_SYS_CLOCK}" "$dst_file"; then
        return "$EXIT_ERROR"
    fi
    
    # Modify FPGA clock interface
    if ! sed -i "/${PATTERN_FPGA_CLOCK_START}/,/${PATTERN_FPGA_CLOCK_END}/c\\${REPLACEMENT_FPGA_CLOCK}" "$dst_file"; then
        return "$EXIT_ERROR"
    fi
    
    # Remove original instances and add conditional compilation
    if ! python_remove_hardware_instances "$dst_file"; then
        return "$EXIT_ERROR"
    fi
    
    if ! add_conditional_compilation_block "$dst_file"; then
        return "$EXIT_ERROR"
    fi
    
    # Ensure endmodule exists
    if ! tail -n 5 "$dst_file" | grep -q "endmodule"; then
        echo "endmodule" >> "$dst_file"
    fi
    
    return 0
}

# Process XilinxVCU118MIGIsland.sv
process_mig_island_file() {
    local src_dir="$1"
    local dst_dir="$2"
    
    local src_file="$src_dir/XilinxVCU118MIGIsland.sv"
    local dst_file="$dst_dir/XilinxVCU118MIGIsland.sv"
    
    if [[ ! -f "$src_file" ]]; then
        return "$EXIT_ERROR"
    fi
    
    if ! safe_copy_file "$src_file" "$dst_file"; then
        return "$EXIT_ERROR"
    fi
    
    add_xepic_macros "$dst_file" || return $?
    
    # Remove original _blackbox_c0_init_calib_complete declaration
    if ! sed -i "/${PATTERN_BLACKBOX_CALIB_COMPLETE}/d" "$dst_file"; then
        return "$EXIT_ERROR"
    fi
    
    # Add reset logic after _axi4asink_auto_out_r_ready line
    local temp_file="${dst_file}.tmp"
    if ! awk -v pattern="${PATTERN_AXI4ASINK_R_READY}" -v replacement="${REPLACEMENT_RESET_LOGIC}" '
        $0 ~ pattern {
            print $0
            print replacement
            next
        }
        {print}
    ' "$dst_file" > "$temp_file"; then
        rm -f "$temp_file"
        return "$EXIT_ERROR"
    fi
    
    if ! mv "$temp_file" "$dst_file"; then
        return "$EXIT_ERROR"
    fi
    
    # Modify reset signal connection
    if ! sed -i "s/${PATTERN_RESET_CONNECTION}/${REPLACEMENT_RESET_CONNECTION}/" "$dst_file"; then
        return "$EXIT_ERROR"
    fi
    
    # Add XRAM interface
    if ! python_add_xram_interface "$dst_file"; then
        return "$EXIT_ERROR"
    fi
    
    return 0
}

# Python: Remove hardware instances
python_remove_hardware_instances() {
    local target_file="$1"
    
    export PY_TARGET_FILE="$target_file"
    export PY_INSTANCES_TO_REMOVE="${HARDWARE_INSTANCES_TO_REMOVE[*]}"
    
    python << 'EOF'
import os

filename = os.environ.get('PY_TARGET_FILE')
instances_to_remove = os.environ.get('PY_INSTANCES_TO_REMOVE').split()

with open(filename, 'r') as f:
    lines = f.readlines()

new_lines = []
i = 0
while i < len(lines):
    line = lines[i].strip()
    
    # Check for instances to remove using configurable patterns
    should_remove = False
    for pattern in instances_to_remove:
        if line.startswith(pattern):
            should_remove = True
            break
    
    if should_remove:
        # Skip until instance end
        while i < len(lines):
            if lines[i].strip().endswith(');') or lines[i].strip().startswith(');'):
                i += 1
                break
            i += 1
    else:
        new_lines.append(lines[i])
        i += 1

with open(filename, 'w') as f:
    f.writelines(new_lines)
EOF
    
    return $?
}

# Add conditional compilation block
add_conditional_compilation_block() {
    local target_file="$1"
    
    local temp_file="${target_file}.tmp"
    local in_block=false
    
    while IFS= read -r line; do
        echo "$line"
        
        if [[ "$line" =~ $PATTERN_ANALOG_TO_UINT_START ]]; then
            in_block=true
        elif [[ "$in_block" == true && "$line" =~ $PATTERN_ANALOG_TO_UINT_END ]]; then
            printf '%s\n' "$REPLACEMENT_CONDITIONAL_BLOCK"
            in_block=false
        fi
    done < "$target_file" > "$temp_file"
    
    if ! mv "$temp_file" "$target_file"; then
        rm -f "$temp_file"
        return "$EXIT_ERROR"
    fi
    
    return 0
}

# Python: Add XRAM interface
python_add_xram_interface() {
    local target_file="$1"
    
    export PY_TARGET_FILE="$target_file"
    export PY_XRAM_SEARCH_PATTERN="$XRAM_SEARCH_PATTERN"
    export PY_XRAM_ANCHOR_PATTERN="$XRAM_ANCHOR_PATTERN"
    export PY_XRAM_VCU118MIG_PATTERN="$XRAM_VCU118MIG_PATTERN"
    export PY_XEPIC_XRAM_TEMPLATE="$XEPIC_XRAM_TEMPLATE"
    export PY_XRAM_ENDIF_CODE="$XRAM_ENDIF_CODE"
    
    python << 'EOF'
import os

filename = os.environ.get('PY_TARGET_FILE')
search_pattern = os.environ.get('PY_XRAM_SEARCH_PATTERN')
anchor_pattern = os.environ.get('PY_XRAM_ANCHOR_PATTERN')
vcu118mig_pattern = os.environ.get('PY_XRAM_VCU118MIG_PATTERN')
xepic_template = os.environ.get('PY_XEPIC_XRAM_TEMPLATE')
endif_code = os.environ.get('PY_XRAM_ENDIF_CODE')

with open(filename, 'r') as f:
    content = f.read()

# Find axi4asink module end position using configurable patterns
axi4asink_end = content.find(anchor_pattern, content.find(search_pattern))
if axi4asink_end != -1:
    axi4asink_end += len(anchor_pattern)  # include anchor pattern
    
    # Insert XEPIC code after axi4asink, before vcu118mig
    content = content[:axi4asink_end] + xepic_template + content[axi4asink_end:]
    
    # Find vcu118mig module end and insert endif
    vcu118mig_start = content.find(vcu118mig_pattern)
    if vcu118mig_start != -1:
        vcu118mig_end = content.find(anchor_pattern, vcu118mig_start)
        if vcu118mig_end != -1:
            vcu118mig_end += len(anchor_pattern)  # include anchor pattern
            content = content[:vcu118mig_end] + endif_code + content[vcu118mig_end:]

# Write back to file
with open(filename, 'w') as f:
    f.write(content)
EOF
    
    return $?
}

# Validate processing results
validate_processing_results() {
    local dst_dir="$1"
    
    
    local errors=0
    
    for file in "${VERILOG_FILES[@]}"; do
        local file_path="$dst_dir/$file"
        
        if [[ ! -f "$file_path" ]]; then
            ((errors++))
            continue
        fi
        
        if [[ ! -s "$file_path" ]]; then
            ((errors++))
            continue
        fi
        
        # Check XEPIC macros
        local macro_count
        macro_count=$(grep -c "XEPIC_P2E" "$file_path" 2>/dev/null || echo "0")
        
        if [[ "$macro_count" -eq 0 ]]; then
            log_error "XEPIC macros not found in $file"
            ((errors++))
        fi
        
    done
    
    if [[ $errors -gt 0 ]]; then
        return "$EXIT_ERROR"
    fi
    
    return 0
} 