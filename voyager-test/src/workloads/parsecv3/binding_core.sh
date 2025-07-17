#!/bin/bash

# Script to update GC_KERNEL path in gcc.bldconf
# This script updates the export GC_KERNEL line to point to the cpu_linux_pthread.o file

set -e

# Define the configuration file path (relative to script location)
CONFIG_FILE="parsec-benchmark/config/gcc.bldconf"

# Define the relative path to the object file (relative from the config file location)
RELATIVE_PATH="../../../cpu_linux_pthread/build/cpu_linux_pthread.o"

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi

# Check if the target object file exists (using relative path for verification)
TARGET_FILE="../cpu_linux_pthread/build/cpu_linux_pthread.o"
if [ ! -f "$TARGET_FILE" ]; then
    echo "Error: Target object file not found at $TARGET_FILE"
    echo "Please build the cpu_linux_pthread workload first."
    exit 1
fi

# Update the GC_KERNEL export line
sed -i 's|^export GC_KERNEL=.*|export GC_KERNEL="'"$RELATIVE_PATH"'"|' "$CONFIG_FILE"

echo "Successfully updated GC_KERNEL in $CONFIG_FILE"
echo "New value: export GC_KERNEL=\"$RELATIVE_PATH\""

# Show the updated line
echo "Updated line:"
grep "^export GC_KERNEL=" "$CONFIG_FILE" 