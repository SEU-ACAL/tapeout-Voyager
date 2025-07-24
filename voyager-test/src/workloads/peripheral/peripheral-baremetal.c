#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

// base address
#define PERIPHERAL_BASE     0x10050000
// memory map
#define WEIGHT_MEM_LARGE_BASE   0x00000     // 20'h00000~20'h0FFFF
#define CSR_BASE                0x24A00     // 20'h24A00~20'h24A7F
#define CSR_LAST_ADDR           0x24A7F     // the last address of CSR

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
    
    // read the last address of CSR (0x0123456789ABCDEF)
    uint64_t csr_last_value = read64(CSR_LAST_ADDR);
    printf("CSR last register value: 0x%016lX\n", csr_last_value);
    
    // test csr w/r
    printf("\ntest csr write and read...\n");
    for (int i = 0; i < 3; i++) {
        uint32_t addr = CSR_BASE + i * 4;
        uint32_t data = 0xC5000000 + i;
        write32(addr, data);
        printf("CSR 0x%08X: write 0x%08X, read 0x%08X\n", 
               addr, data, read32(addr));
    }
    printf("---------------------------------------------\n\n");
}

int main() {    
    printf("===============================================\n");
    printf("peripheral memory access test\n");
    printf("===============================================\n\n");
    
    // test the weight memory large area
    test_weight_memory_large();
    
    // test the csr
    test_csr();
    
    printf("all tests done!\n");
    printf("===============================================\n");
    
    return 0;
}
