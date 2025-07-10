// See LICENSE.Sifive for license details.
#include <platform.h>
#include <smp.h>
#include "common.h"

  .section .text.init
  .option norvc
  .globl _prog_start
_prog_start:
  smp_pause(s1, s2)
  li sp, (PAYLOAD_DEST + 0xffff000)

    // Check boot address register at 0x1000
  li t0, 0x1000           // Load address 0x1000
  ld t1, 0(t0)            // Load 64-bit value from 0x1000
  li t2, 0x00000001       // Load expected custom boot address
  bne t1, t2, skip_sd_load // If value != 0x00000001, skip SD loading

  // Normal SD card loading path
  call main
  j continue_boot
  
skip_sd_load:
  // Skip SD card loading, payload should already be at PAYLOAD_DEST
  // For bare metal: ensure clean state for custom boot
  nop
continue_boot:

  smp_resume(s1, s2)
  csrr a0, mhartid // hartid for next level bootloader
  la a1, dtb // dtb address for next level bootloader
  li s1, PAYLOAD_DEST
  jr s1

  .section .dtb
  .align 3
dtb:
