ifndef RISCV
$(error RISCV is unset)
else
$(info Running with RISCV=$(RISCV))
endif

PREFIX ?= $RISCV/

default: libbuckyball.so

BIN_DIR = $(PWD)/build/bin

libbuckyball.so: buckyball.cc buckyball_intrOp.cc	
	g++ -L $(RISCV)/lib -Wl,-rpath,$(RISCV)/lib -shared -o $@ -std=c++17 
			-I $(RISCV)/include \
			-I ./include \
			-fPIC -O3 $^

.PHONY: install
install: libbuckyball.so
	cp libbuckyball.so $(RISCV)/lib

test-vecModel-run:
	g++ -std=c++17 \
		-I./include \
		-I $(RISCV)/include \
		-DELEM_T=int8_t -DACC_T=int32_t \
		./example/modelTest/test_vecModel.cc \
		-o $(BIN_DIR)/test_vecModel
	$(BIN_DIR)/test_vecModel

test-memModel-run:
	g++ -std=c++17 \
		-I./include \
		-I $(RISCV)/include \
		-DELEM_T=int8_t -DACC_T=int32_t \
		./example/modelTest/test_memModel.cc \
		-o $(BIN_DIR)/test_memModel
	$(BIN_DIR)/test_memModel

clean:
	rm -rf *.o *.so
