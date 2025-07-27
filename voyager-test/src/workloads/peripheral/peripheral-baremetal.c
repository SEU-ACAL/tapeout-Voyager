#include <stdio.h>
#include <stdint.h>
#include <unistd.h> 
#include <stdlib.h>
#include <stdint.h>


static inline void multicore(int target_hart_id) {
    int hart_id;
    __asm__ volatile("csrr %0, mhartid" : "=r"(hart_id));
    
    if (hart_id != target_hart_id) {
      while (1) {
        __asm__ volatile("wfi");  // Wait for interrupt
      }
    }
    // If hart_id == target_hart_id, continue execution
  }

// base address
#define PERIPHERAL_BASE     0x10050000
// memory map
#define WEIGHT_MEM_LARGE_BASE   (PERIPHERAL_BASE + 0x00000)     // 20'h00000~20'h0FFFF
#define CSR_BASE                (PERIPHERAL_BASE + 0x24A00)     // 20'h24A00~20'h24A7F
#define CSR_LAST_ADDR           (PERIPHERAL_BASE + 0x24A7F)     // the last address of CSR

static inline uint32_t read32(uint32_t addr) {
    return *(volatile uint32_t*)addr;
}

static inline void write32(uint32_t addr, uint32_t value) {
    *(volatile uint32_t*)addr = value;
}

// read the memory
static inline uint64_t read64(uint64_t addr) {
    return *(volatile uint64_t*)addr;
}

static inline void write64(uint64_t addr, uint64_t value) {
    *(volatile uint64_t*)addr = value;
}

// test the weight memory large area
void test_weight_memory_large() {
    printf("test the weight memory large area (Weight Memory Large):\n");
    printf("---------------------------------------------\n");
    
    // write the test data
    uint32_t test_addr = WEIGHT_MEM_LARGE_BASE;
    uint32_t test_data = 0xABCD1234;
    
    printf("write the address 0x%08X: 0x%08X\n", test_addr, test_data);
    write32(test_addr, test_data);
    
    // read and verify
    uint32_t read_data = read32(test_addr);
    printf("address 0x%08X: 0x%08X\n", test_addr, read_data);
    printf("result: %s\n", (read_data == test_data) ? "success" : "failed");
    
    // test multiple address
    printf("\ntest multiple address...\n");
    for (int i = 0; i < 5; i++) {
        uint32_t addr = WEIGHT_MEM_LARGE_BASE + i * 4;
        uint32_t data = 0xA0000000 + i;
        write32(addr, data);
        printf("address 0x%08X: write 0x%08X, read 0x%08X\n", 
               addr, data, read32(addr));
    }
    printf("---------------------------------------------\n\n");
}

// test the csr
void test_csr() {
    printf("CSR:\n");
    printf("---------------------------------------------\n");

    // original
    uint64_t original_val = read64(CSR_LAST_ADDR);
    printf("read64(0x%08X) ---> 0x%016lX\n\n", CSR_LAST_ADDR, original_val);

    // aligned 64-bit 
    uint64_t aligned_addr_64 = CSR_LAST_ADDR - 7; // This is 0x...A78
    uint64_t aligned_val_64 = read64(aligned_addr_64);
    printf("read64(0x%08lX) ---> 0x%016lX\n\n", aligned_addr_64, aligned_val_64);

    // divide
    uint32_t addr_low  = CSR_LAST_ADDR - 7; // 0x...A78
    uint32_t addr_high = CSR_LAST_ADDR - 3; // 0x...A7C

    uint32_t val_low  = read32(addr_low);
    uint32_t val_high = read32(addr_high);

    printf("read32(0x%08X) ---> 0x%08X\n", addr_low, val_low);
    printf("read32(0x%08X) ---> 0x%08X\n", addr_high, val_high);

    // in little-endian system, the high address is the high byte
    uint64_t combined_val = ((uint64_t)val_high << 32) | val_low;
    printf("Combined 32-bit reads ---> 0x%016lX\n", combined_val);
    printf("---------------------------------------------\n\n");
}

int main() {    
    #ifdef MULTICORE 
    multicore(MULTICORE);
    #endif
    printf("===============================================\n");
    printf("peripheral memory access test\n");
    printf("===============================================\n\n");
    
    
    // test the csr
    test_csr();

    // test_weight_memory_large();

    
    printf("all tests done!\n");
    printf("===============================================\n");

    exit(0);

    
}
