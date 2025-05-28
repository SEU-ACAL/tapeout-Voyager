ifndef RISCV
$(error RISCV is unset)
else
$(info Running with RISCV=$(RISCV))
endif

PREFIX ?= $RISCV/

default: libbuckyball.so

libbuckyball.so: buckyball.cc buckyball_intrOp.cc	
	g++ -L $(RISCV)/lib -Wl,-rpath,$(RISCV)/lib -shared -o $@ -std=c++17 -I $(RISCV)/include -fPIC -O3 $^

.PHONY: install
install: libbuckyball.so
	cp libbuckyball.so $(RISCV)/lib

clean:
	rm -rf *.o *.so
