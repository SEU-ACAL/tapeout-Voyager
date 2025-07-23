  .global _start

  .text

_start:
  la      sp, _stack_end  # set stack pointer to the end of SRAM

  # load data section from flash to RAM
  la      a0, _data_lma
  la      a1, _data_vma
  la      a2, _data_end
  bgeu    a1, a2, 2f  # if a1 >= a2, data section is empty
1:
  lw      t0, (a0)
  sw      t0, (a1)
  addi    a0, a0, 4
  addi    a1, a1, 4
  bltu    a1, a2, 1b  # loop until a1 >= a2
2:
  # clear bss section
  la      a0, _bss_start
  la      a1, _bss_end
  bgeu    a0, a1, 2f  # if a0 >= a1, bss section is empty
1:
  sw      zero, (a0)
  addi    a0, a0, 4
  bltu    a0, a1, 1b  # loop until a0 >= a1
2:
  j       start_kernel  # jump to start_kernel

  .end
