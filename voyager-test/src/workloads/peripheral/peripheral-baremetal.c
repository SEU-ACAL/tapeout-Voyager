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
#define CSR_LAST_ADDR           (PERIPHERAL_BASE + 0x24BF8)     // the last address of CSR

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
    printf("---------------------------------------------\n\n");


    uint64_t original_val = read64(CSR_LAST_ADDR);
    printf("read64(0x%08X) ---> 0x%016lX\n\n", CSR_LAST_ADDR, original_val);

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
