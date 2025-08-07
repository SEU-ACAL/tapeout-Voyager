# Flash Test Makefile
# Compiles a simple jump instruction program that links to 0x200000 (flash address)

# Toolchain
CC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
OBJDUMP = riscv64-unknown-elf-objdump

# Compiler flags
CFLAGS = -march=rv64gc -mabi=lp64d -nostartfiles -nostdlib -static
LDFLAGS = -T flash_test.lds

# Target files
TARGET = flash_test-baremetal
BIN_FILE = flash_test.bin
DUMP_FILE = flash_test.dump

# Source files
SOURCES = flash_test.S

# Default target
all: $(TARGET) $(BIN_FILE) $(DUMP_FILE)

# Build the ELF file
$(TARGET): $(SOURCES) flash_test.lds
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SOURCES)

# Generate binary file for flash programming
$(BIN_FILE): $(TARGET)
	$(OBJCOPY) -O binary $< $@

# Generate disassembly for debugging
$(DUMP_FILE): $(TARGET)
	$(OBJDUMP) -d $< > $@

# Clean build artifacts
clean:
	rm -f $(TARGET) $(BIN_FILE) $(DUMP_FILE)

# Show help
help:
	@echo "Available targets:"
	@echo "  all      - Build ELF, binary, and disassembly files"
	@echo "  $(TARGET) - Build ELF file only"
	@echo "  $(BIN_FILE) - Generate binary file for flash"
	@echo "  $(DUMP_FILE) - Generate disassembly"
	@echo "  clean    - Remove build artifacts"
	@echo "  help     - Show this help"

.PHONY: all clean help
