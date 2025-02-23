CC=riscv64-unknown-elf-gcc
# CC=gcc



CYDIR=$(shell git rev-parse --show-toplevel)
CPU_WORKLOAD_DIR=$(CYDIR)/software/src/npu
# $(info CPU_WORKLOAD_DIR = $(CPU_WORKLOAD_DIR))

# PWD_DIR=$(PWD)
BUILD_DIR=$(abspath ./build)
# CSR_PATH=$(abspath ./)
INC_PATH=$(abspath ./include)

CFLAGS=-std=c11 -g -fno-common -O2 -static -fno-builtin-printf -specs=htif_nano.specs
LDFLAGS=

INCFLAGS=$(addprefix -I, $(INC_PATH))
CFLAGS+=$(INCFLAGS)


$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

all: hello-bin spmm-bin

hello-bin: $(BUILD_DIR)
	$(CC) -o $(BUILD_DIR)/$@ ./hello/hello.c $(CFLAGS) $(LDFLAGS)

spmm-bin: $(BUILD_DIR)
	$(CC) -o $(BUILD_DIR)/$@ ./spmm/spmm.c $(CFLAGS) $(LDFLAGS)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all hello-bin spmm-bin clean

