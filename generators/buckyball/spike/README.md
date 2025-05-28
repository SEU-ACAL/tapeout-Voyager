Buckyball Spike ISA Functional Model Extensions
=============================================

This repository builds libbuckyball.so, which can be dynamically linked into Spike to support executing custom Buckyball instructions.

To use this, first install a recent version of [spike](https://github.com/riscv-software-src/riscv-isa-sim), and set the `$RISCV` environment variable to the install location.

Usage:
```
make
make install

cd Voyager/toolchains/riscv-tools/riscv-isa-sim/build
make 
make install

spike --extension=buckyball <custom_buckyball_program>
```
