#include <stdint.h>

#define GHE_FULL 0x02
#define GHE_EMPTY 0x01


static inline uint64_t ghe_status ()
{
  uint64_t status;
  ROCC_INSTRUCTION_D (1, status, 0x00);
  return status; 
  // 0b01: empty; 
  // 0b10: full;
  // 0b00: data buffered;
  // 0b11: error
}

static inline uint64_t ghe_asR ()
{
  ROCC_INSTRUCTION_S (1, 0x01, 0x01);
}



static inline uint64_t ghe_top_func_opcode ()
{
  uint64_t packet = 0x00;
  if (ghe_status() != 0x01) {
    ROCC_INSTRUCTION_D (1, packet, 0x0A);
  }
  return packet;
}

static inline uint64_t ghe_pop_func_opcode ()
{
  uint64_t packet = 0x00;
  if (ghe_status() != 0x01) {
    ROCC_INSTRUCTION_D (1, packet, 0x0B);
  }
  return packet;
}


static inline uint64_t ghe_top_data ()
{
  uint64_t packet = 0x00;
  if (ghe_status() != 0x01) {
    ROCC_INSTRUCTION_D (1, packet, 0x0C);
  }
  return packet;
}


static inline uint64_t ghe_pop_data ()
{
  uint64_t packet = 0x00;
  if (ghe_status() != 0x01) {
    ROCC_INSTRUCTION_D (1, packet, 0x0D);
  }
  return packet;
}


static inline uint64_t ghe_checkght_status ()
{
  uint64_t status;
  ROCC_INSTRUCTION_D (1, status, 0x07);
  return status; 
}


static inline void ghe_complete ()
{
  // uint64_t get_status = 0;
  // uint64_t set_status = 0x01;
  ROCC_INSTRUCTION (1, 0x41);
}

static inline void ghe_release ()
{
  // uint64_t get_status = 0;
  // uint64_t set_status = 0xFF;
  ROCC_INSTRUCTION (1, 0x43);
}

static inline void ghe_go ()
{
  // uint64_t get_status = 0;
  // uint64_t set_status = 0;
  ROCC_INSTRUCTION (1, 0x40);
}

static inline uint64_t ghe_agg_status ()
{
  uint64_t status;
  ROCC_INSTRUCTION_D (1, status, 0x10);
  return status;
  // 0b01: empty; 
  // 0b10: full;
  // 0b00: data buffered;
  // 0b11: error
}

static inline void ghe_agg_push (uint64_t header, uint64_t payload)
{
  ROCC_INSTRUCTION_SS (1, header, payload, 0x11);
}

static inline uint64_t ghe_sch_status ()
{
  uint64_t status;
  ROCC_INSTRUCTION_D (1, status, 0x20);
  return status; 
  // 0b01: empty; 
  // 0b10: full;
  // 0b00: data buffered;
  // 0b11: error
}

static inline void ghe_initailised (uint64_t if_initailised)
{
  if (if_initailised == 0){
    ROCC_INSTRUCTION (1, 0x50);
  }

  if (if_initailised == 1){
    ROCC_INSTRUCTION (1, 0x51);
  }
}

static inline uint64_t ghe_get_bufferdepth ()
{
  uint64_t depth;
  ROCC_INSTRUCTION_D (1, depth, 0x25);
  return depth;
}

/* RSU Features */
static inline uint64_t ghe_rsur_status ()
{
  uint64_t status;
  ROCC_INSTRUCTION_D (1, status, 0x61);
  return status;
	  // 0b00: idle
    // 0b01: snapshot received 
    // 0b11: snapshot and results recieved
    // 0b10: wrong status
}

static inline uint64_t elu_checkstatus ()
{
  uint64_t status;
  ROCC_INSTRUCTION_D (1, status, 0x66);
  return status; 
}


static inline void ghe_perf_ctrl (uint64_t ctrl_code)
{
  ROCC_INSTRUCTION_S (1,ctrl_code, 0x76);
}


static inline uint64_t ghe_perf_read ()
{
  uint64_t perf_val;
  ROCC_INSTRUCTION_D (1, perf_val, 0x77);
  return perf_val;
}

static inline uint64_t ghe_csr_perf_read (int csr_index)
{
  uint64_t perf_val;
  ROCC_INSTRUCTION_DS (1, perf_val, csr_index, 0x55);
  return perf_val;
}