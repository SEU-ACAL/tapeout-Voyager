CC = riscv64-unknown-linux-gnu-gcc
CPP = riscv64-unknown-linux-gnu-g++

OFLAGS := -O3 -DRISCV -march=rv64imafd -DUSE_PUBLIC_MALLOC_WRAPPERS
CFLAGS:= -O3 -DRISCV -march=rv64imafd

all: cpu_linux_pthread

#CC = gcc
#CFLAGS := -O3 -std=gnu99
cpu_linux_pthread: cpu_linux_pthread.c
	${CC} ${CFLAGS} -c cpu_linux_pthread.c -lpthread

clean:
	rm -f *.o *.riscv *.so