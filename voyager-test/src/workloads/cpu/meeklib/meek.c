#ifndef _GNU_SOURCE
	#define _GNU_SOURCE             /* See feature_test_macros(7) */
#endif

#define NUM_CHECKERS 3
#include "meek.h"
#include <riscv-pk/encoding.h>
#include <stdio.h>
#include <stdlib.h>
#include "rocc.h"
#include "spin_lock.h"
#include "ght.h"
#include "ghe.h"
#include "tasks.h"
size_t total_cycle_s  =0;
size_t total_commit_s =0;
size_t total_issue_s  =0;
size_t Fetch_Bubble_s =0;
size_t Load_commit_s  =0;
size_t Store_commit_s =0;
size_t fp_commit_s    =0;
size_t fp_load_commit_s    =0;
size_t fp_store_commit_s    =0;
size_t fp_div_commit_s    =0;
size_t br_commit_s    =0;
size_t jal_commit_s   =0;
size_t jalr_commit_s  =0;
size_t int_commit_s   =0;
size_t div_commit_s   =0;
size_t mul_commit_s  =0;
size_t cdc_bp         =0;
size_t no_core        =0;
size_t ic_stall       =0;
size_t total_mispred_s=0;
size_t br_mispred_s   =0;
size_t flush_s        =0;
size_t icache_miss_s  =0;
size_t dcache_miss_s  =0;
void perf_start(){
  write_csr(mhpmevent3,0x0200);
  write_csr(mhpmevent4,0x0400);
  write_csr(mhpmevent5,0x0800);
  write_csr(mhpmevent6,0x1000);
  write_csr(mhpmevent7,0x2000);
  write_csr(mhpmevent8,0x4000);
  write_csr(mhpmevent9,0x8000);
  write_csr(mhpmevent10,0x10000);
  write_csr(mhpmevent11,0x20000);
  write_csr(mhpmevent12,0x40000);
  write_csr(mhpmevent13,0x80000);
  write_csr(mhpmevent14,0x100000);
  write_csr(mhpmevent15,0x200000);
  write_csr(mhpmevent16,0x400000);
  write_csr(mhpmevent17,0x800000);

  write_csr(mhpmevent18,0x0101);
  write_csr(mhpmevent19,0x0201);
  write_csr(mhpmevent20,0x0401);

  write_csr(mhpmevent21,0x0102);
  write_csr(mhpmevent22,0x0202);
  write_csr(mhpmevent23,0x1000000);
  write_csr(mhpmevent24,0x2000000);
  write_csr(mhpmevent25,0x4000000);
  total_cycle_s   = read_csr(mcycle);
  total_commit_s  = read_csr(mhpmcounter3);
  total_issue_s   = read_csr(mhpmcounter4);
  Fetch_Bubble_s  = read_csr(mhpmcounter5);
  Load_commit_s   = read_csr(mhpmcounter6); 
  Store_commit_s  = read_csr(mhpmcounter7); 
  fp_commit_s     = read_csr(mhpmcounter8);   
  br_commit_s     = read_csr(mhpmcounter9); 
  jal_commit_s    = read_csr(mhpmcounter10);         
  jalr_commit_s   = read_csr(mhpmcounter11);     
  int_commit_s    = read_csr(mhpmcounter12);
  div_commit_s    = read_csr(mhpmcounter13);     
  mul_commit_s    = read_csr(mhpmcounter14);
  cdc_bp          = read_csr(mhpmcounter15);
  no_core         = read_csr(mhpmcounter16);
  ic_stall        = read_csr(mhpmcounter17);
  total_mispred_s = read_csr(mhpmcounter18);
  br_mispred_s    = read_csr(mhpmcounter19);
  flush_s         = read_csr(mhpmcounter20);
  icache_miss_s   = read_csr(mhpmcounter21);
  dcache_miss_s   = read_csr(mhpmcounter22);
  fp_load_commit_s = read_csr(mhpmcounter23);
  fp_store_commit_s = read_csr(mhpmcounter24);
  fp_div_commit_s = read_csr(mhpmcounter25);
}

void perf_end(){
  size_t total_cycle_e   = read_csr(mcycle)-total_cycle_s;
  size_t total_commit_e  = read_csr(mhpmcounter3) -total_commit_s  ;
  size_t total_issue_e   = read_csr(mhpmcounter4) -total_issue_s   ;
  size_t Fetch_Bubble_e  = read_csr(mhpmcounter5) -Fetch_Bubble_s  ;
  size_t Load_commit_e   = read_csr(mhpmcounter6) -Load_commit_s   ; 
  size_t Store_commit_e  = read_csr(mhpmcounter7) -Store_commit_s  ; 
  size_t fp_commit_e     = read_csr(mhpmcounter8) -fp_commit_s     ;   
  size_t br_commit_e     = read_csr(mhpmcounter9) -br_commit_s     ; 
  size_t jal_commit_e    = read_csr(mhpmcounter10)-jal_commit_s    ;         
  size_t jalr_commit_e   = read_csr(mhpmcounter11)-jalr_commit_s   ;     
  size_t int_commit_e    = read_csr(mhpmcounter12)-int_commit_s    ;
  size_t div_commit_e    = read_csr(mhpmcounter13)-div_commit_s    ;     
  size_t mul_commit_e   = read_csr(mhpmcounter14)-mul_commit_s   ; 
  size_t cdc_bp_e        = read_csr(mhpmcounter15)-cdc_bp        ;
  size_t no_core_e       = read_csr(mhpmcounter16)-no_core       ;
  size_t ic_stall_e      = read_csr(mhpmcounter17)-ic_stall      ;

  size_t total_mispred_e = read_csr(mhpmcounter18)-total_mispred_s ;
  size_t br_mispred_e    = read_csr(mhpmcounter19)-br_mispred_s    ;
  size_t flush_e         = read_csr(mhpmcounter20)-flush_s ;

  size_t icache_miss_e   = read_csr(mhpmcounter21)-icache_miss_s   ;
  size_t dcache_miss_e   = read_csr(mhpmcounter22)-dcache_miss_s   ;
  size_t fp_load_commit_e = read_csr(mhpmcounter23)-fp_load_commit_s;
  size_t fp_store_commit_e = read_csr(mhpmcounter24)-fp_store_commit_s;
  size_t fp_div_commit_e = read_csr(mhpmcounter25)-fp_div_commit_s;

  size_t retire          = (total_commit_e*100)/(total_cycle_e*3);
  size_t fetch_bound     = (Fetch_Bubble_e*100)/(total_cycle_e*3);
  size_t bad_speculation = (100*((total_issue_e-total_commit_e)+30*(total_mispred_e+flush_e)))/(total_cycle_e*3);
  size_t backend_bound   = 100-retire-fetch_bound-bad_speculation;
  //cache miss
  lock_acquire(&uart_lock);
	
  
  printf("total cycle %lu\n \
      total commit %lu\n \
      total_issue %lu\n \
      Fetch_Bubble %lu\n \
      Load_commit %lu \n \
      Store_commit %lu \n \
      fp_commit   %lu \n \
      fp_load_commit %lu \n \
      fp_store_commit %lu \n \
      fp_div_commit %lu \n \
      br_commit %lu \n \
      jal_commit  %lu \n \
      jalr_commit %lu \n \
      int_commit %lu \n \
      div_commit %lu \n \
      mul_commit %lu \n \
      total_mispred %lu \n \
      br_mispred %lu \n \
      flsuh %lu \n \
      icache_miss %lu \n \
      dcache_miss %lu\n \
      cdc_bp %lu \n \
      no_core %lu \n \
      ic_stall %lu \n \
      ",total_cycle_e,
      total_commit_e ,
      total_issue_e  ,
      Fetch_Bubble_e ,
      Load_commit_e  ,
      Store_commit_e ,
      fp_commit_e    ,
      fp_load_commit_e,
      fp_store_commit_e,
      fp_div_commit_e ,
      br_commit_e    ,
      jal_commit_e   ,
      jalr_commit_e  ,
      int_commit_e   ,
      div_commit_e   ,
      mul_commit_e ,
      total_mispred_e,
      br_mispred_e   ,
      flush_e,
      icache_miss_e  ,
      dcache_miss_e  ,
      cdc_bp_e       ,
      no_core_e      ,
      ic_stall_e     
    );
  //top down level 1
  printf("retire %lu front bound %lu bad speculation: %lu backend bound %lu\n",retire,fetch_bound,bad_speculation,backend_bound);
  lock_release(&uart_lock);
}
int checker (int hart_id)
{

  //================== Initialisation ==================//
  ghe_asR();
  ght_set_satp_priv();
  ghe_go();
  ghe_initailised(1);

  ghe_perf_ctrl(0x01);
  ghe_perf_ctrl(0x00);


  //===================== Execution =====================//
  ROCC_INSTRUCTION (1, 0x75); // Record context
  ROCC_INSTRUCTION (1, 0x73); // Store context from main core
  ROCC_INSTRUCTION (1, 0x64); // Record PC
  for (int sel_elu = 0; sel_elu < 2; sel_elu ++){
    ROCC_INSTRUCTION_S (1, sel_elu, 0x65);

    while (elu_checkstatus() != 0){
      printf("C%x: Error detected for ELU %x.\r\n", hart_id, sel_elu);
      ROCC_INSTRUCTION_S (1, sel_elu, 0x63);
    }
  }
  
  while (ghe_checkght_status() != 0x02){
    if ((ghe_rsur_status() & 0x18) == 0x08){//这个是不是有漏洞>
      ROCC_INSTRUCTION (1, 0x60);
      R_INSTRUCTION_JLR (3, 0x00);
    }
  }


  ROCC_INSTRUCTION (1, 0x72); // Store context from checker core
  ROCC_INSTRUCTION (1, 0x60);

  __asm__ volatile("nop");
  __asm__ volatile("nop");
  __asm__ volatile("nop");
  __asm__ volatile("nop");
  __asm__ volatile("nop");






  
  while (ghe_checkght_status() != 0x02){
  }

  // ghe_initailised(0);
  ghe_release();
  ght_unset_satp_priv();
  if(1){
    lock_acquire(&uart_lock);
    uint64_t perf_val = 0;
    printf("Perf[%d]\r\n", hart_id);
    // ghe_perf_ctrl(0x07<<1);
    // perf_val = ghe_perf_read();
    // printf("Perf: N.CP = %d \r\n", perf_val);

    // ghe_perf_ctrl(0x01<<1);
    // perf_val = ghe_perf_read();
    // printf("Perf: N.ID EX HARZ = %d \r\n", perf_val);

    // ghe_perf_ctrl(0x02<<1);
    // perf_val = ghe_perf_read();
    // printf("Perf: N.ID MEM = %d \r\n", perf_val);

    ghe_perf_ctrl(0x06<<1);
    perf_val = ghe_perf_read();
    printf("Perf: LSL Block = %d \r\n", perf_val);
    ghe_perf_ctrl(0x08<<1);
    perf_val = ghe_perf_read();
    printf("Perf:Total FP BLOCK = %d \r\n", perf_val);
    ghe_perf_ctrl(0x09<<1);
    perf_val = ghe_perf_read();
    printf("Perf:Total BP Inst = %d \r\n", perf_val);
    ghe_perf_ctrl(0x0a<<1);
    perf_val = ghe_perf_read();
    printf("Perf:Total BP Mispred = %d \r\n", perf_val);
    ghe_perf_ctrl(0x0b<<1);
    perf_val = ghe_perf_read();
    printf("Perf:Total ICache Miss = %d \r\n", perf_val);
    ghe_perf_ctrl(0x0c<<1);
    perf_val = ghe_perf_read();
    printf("Perf: DIV blocking = %d \r\n", perf_val);
    ghe_perf_ctrl(0x0d<<1);
    perf_val = ghe_perf_read();
    printf("Perf: Total Cycle = %d \r\n", perf_val);
    ghe_perf_ctrl(0x0e<<1);
    perf_val = ghe_perf_read();
    printf("Perf: Total inst = %d \r\n", perf_val);
    lock_release(&uart_lock);
  }
  ghe_initailised(0);
  while(1){

  }

  return 0;
}
int uart_lock;
void rStartup (void) {
  // printf("")
  // barrier();
  printf("start Checking...\n");
  // barrier();
    //================== Initialisation ==================//
	ght_set_numberofcheckers(NUM_CHECKERS);

	ROCC_INSTRUCTION (1, 0x34);
	while (ght_get_initialisation() == 0){
 	}

	ght_set_satp_priv();
	// printf("[Boom-%x]: Test is now started: \r\n", BOOM_ID);

	//======================= Perf ========================//
	ghe_perf_ctrl(0x01);
  ghe_perf_ctrl(0x00); 

    // ROCC_INSTRUCTION_S (1, 0x3, 0x69);
	
   	ROCC_INSTRUCTION (1, 0x31); // start monitoring
   	ROCC_INSTRUCTION_S (1, 0x01, 0x70); // ISAX_Go
    //===================== Execution =====================//

}


void rCleanup (void){
	//=================== Post execution ===================//
	ROCC_INSTRUCTION (1, 0x32); // stop monitoring
	ROCC_INSTRUCTION_S (1, 0X02, 0x70); // ISAX_Stop
	// printf("End Checking...\n");
	__asm__ volatile("nop");
	__asm__ volatile("nop");
	__asm__ volatile("nop");
	__asm__ volatile("nop");
	

	ghe_perf_ctrl(0x07<<1);
	uint64_t perf_val_CC = ghe_perf_read();
	ghe_perf_ctrl(0x01<<1);
	uint64_t perf_val_SB = ghe_perf_read();
	ghe_perf_ctrl(0x02<<1);
	uint64_t perf_val_SS = ghe_perf_read();
	ghe_perf_ctrl(0x03<<1);
	uint64_t perf_val_CS = ghe_perf_read();
	ghe_perf_ctrl(0x04<<1);
	uint64_t perf_val_SS_OT = ghe_perf_read();
	ghe_perf_ctrl(0x05<<1);
	uint64_t perf_val_SS_AB = ghe_perf_read();
	ghe_perf_ctrl(0x06<<1);
	uint64_t perf_val_OT = ghe_perf_read();

	uint64_t bp_checker  = debug_bp_checker();
  uint64_t bp_cdc = debug_bp_cdc();
  uint64_t bp_filter = debug_bp_filter();

	
	uint64_t status;
	while (ght_get_initialisation() != 0){
 	}




  lock_acquire(&uart_lock);
	printf("[Boom]: Test is now completed: \r\n");
  lock_release(&uart_lock);
	
	ght_unset_satp_priv();
	ROCC_INSTRUCTION (1, 0x30); // reset monitoring

}
int __main(void)
{
  uint64_t Hart_id = 0;
  asm volatile ("csrr %0, mhartid"  : "=r"(Hart_id));
  
  switch (Hart_id){
      case 0x01:
      checker(Hart_id);
        printf("hart id %d\n", Hart_id);
      break;

      case 0x02:
        checker(Hart_id);
        printf("hart id %d\n", Hart_id);
      break;

      case 0x03:
        checker(Hart_id);
        printf("hart id %d\n", Hart_id);
      break;

      case 0x04:
        checker(Hart_id);
        printf("hart id %d\n", Hart_id);
      break;

      case 0x05:
        checker(Hart_id);
        printf("hart id %d\n", Hart_id);
      break;
      case 0x06:
        checker(Hart_id);
        printf("hart id %d\n", Hart_id);
      break;
      default:
      break;
  }
  
  idle();
  return 0;
}