#include "perf.h"
#include <stdio.h>
#include <stdlib.h>
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
size_t gh_bp         =0;
size_t no_core        =0;
size_t ic_stall       =0;
size_t total_mispred_s=0;
size_t br_mispred_s   =0;
size_t flush_s        =0;
/*
perf_ctrl 
0:清零
1:开始计数
2:停止计数
other:具体要读哪个性能计数器
需要加入 WithPERF config(目前暂时不能通过cospike仿真)
*/
void perf_start(){
  printf("perf start\n");
  perf_ctrl(0x00);
  perf_ctrl(0x01);
}

void perf_end(){
  perf_ctrl(0x02);

  perf_ctrl(3);
  total_commit_s  = perf_read();
  perf_ctrl(4);
  total_issue_s   = perf_read();
  perf_ctrl(5);
  Fetch_Bubble_s  = perf_read();
  perf_ctrl(6);
  Load_commit_s   = perf_read();
  perf_ctrl(7);
  Store_commit_s  = perf_read();
  perf_ctrl(8);
  fp_commit_s     = perf_read();
  perf_ctrl(9);
  br_commit_s     = perf_read();
  perf_ctrl(10);
  jal_commit_s    = perf_read();
  perf_ctrl(11);
  jalr_commit_s   = perf_read();
  perf_ctrl(12);
  int_commit_s    = perf_read();
  perf_ctrl(13);
  div_commit_s    = perf_read();
  perf_ctrl(14);
  mul_commit_s   = perf_read();
  perf_ctrl(15);
  total_mispred_s   = perf_read();
  perf_ctrl(16);
  br_mispred_s    = perf_read();
  perf_ctrl(17);
  total_cycle_s     = perf_read();
  printf("perf end\n");
  size_t retire          = (total_commit_s*100)/(total_cycle_s*3);
  size_t fetch_bound     = (Fetch_Bubble_s*100)/(total_cycle_s*3);
  size_t bad_speculation = (100*((total_issue_s-total_commit_s)+30*(total_mispred_s+flush_s)))/(total_cycle_s*3);
  size_t backend_bound   = 100-retire-fetch_bound-bad_speculation;

	
  
  printf("total cycle %lu\n \
      total commit %lu\n \
      total_issue %lu\n \
      Fetch_Bubble %lu\n \
      Load_commit %lu \n \
      Store_commit %lu \n \
      fp_commit   %lu \n \
      br_commit %lu \n \
      jal_commit  %lu \n \
      jalr_commit %lu \n \
      int_commit %lu \n \
      div_commit %lu \n \
      mul_commit %lu \n \
      total_mispred %lu \n \
      br_mispred %lu \n \
      ",total_cycle_s,
      total_commit_s ,
      total_issue_s  ,
      Fetch_Bubble_s ,
      Load_commit_s  ,
      Store_commit_s ,
      fp_commit_s    ,
      br_commit_s    ,
      jal_commit_s   ,
      jalr_commit_s  ,
      int_commit_s   ,
      div_commit_s   ,
      mul_commit_s ,
      total_mispred_s,
      br_mispred_s   
   
    );
  //top down level 1
  printf("retire %lu front bound %lu bad speculation: %lu backend bound %lu\n",retire,fetch_bound,bad_speculation,backend_bound);

}