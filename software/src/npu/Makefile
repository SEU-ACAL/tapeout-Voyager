# CC=riscv64-unknown-elf-gcc
CC=gcc


# CDIR为chipyard的路径
CDIR=$(git rev-parse --show-toplevel)

NPU_WORKLOAD_DIR=${CDIR}/software/src/npu
BUILD_DIR=$(abspath ./build)
# CSR_PATH=$(abspath ./)
INC_PATH=$(abspath ./include)

CFLAGS=-std=c11 -g -fno-common -O2 -static -fno-builtin-printf #-specs=htif_nano.specs
LDFLAGS=

INCFLAGS=$(addprefix -I, $(INC_PATH))
CFLAGS+=$(INCFLAGS)


$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

all: template-bin

template-bin: $(BUILD_DIR)
	$(CC) -o $(BUILD_DIR)/$@ ${NPU_WORKLOAD_DIR}/buddy-test/template.c $(CFLAGS) $(LDFLAGS)

native-bin: $(BUILD_DIR)
	make -C ${NPU_WORKLOAD_DIR}/native-test/libgemmini install
	cd ${NPU_WORKLOAD_DIR}/native-test && ./build.sh

clean:
	rm -rf $(BUILD_DIR)

.PHONY: template-bin all clean

