// See LICENSE.Sifive for license details.
#include <stdint.h>

#include <platform.h>

#include "common.h"

#define DEBUG
#include "kprintf.h"

// Total payload in B
#define PAYLOAD_SIZE_B (30 << 20) // default: 30MiB
// A sector is 512 bytes, so (1 << 11) * 512B = 1 MiB
#define SECTOR_SIZE_B 512
// Payload size in # of sectors
#define PAYLOAD_SIZE (PAYLOAD_SIZE_B / SECTOR_SIZE_B)

// The sector at which the BBL partition starts
#define BBL_PARTITION_START_SECTOR 34

#ifndef TL_CLK
#error Must define TL_CLK
#endif

#define F_CLK 		(TL_CLK)

// SPI SCLK frequency, in kHz
// We are using the 25MHz High Speed mode. If this speed is not supported by the
// SD card, consider changing to the Default Speed mode (12.5 MHz).
#define SPI_CLK 	25000

// SPI clock divisor value
// @see https://ucb-bar.gitbook.io/baremetal-ide/baremetal-ide/using-peripheral-devices/sifive-ips/serial-peripheral-interface-spi
#define SPI_DIV 	(((F_CLK * 100) / SPI_CLK) / 2 - 1)
// #define SPI_DIV 0

static volatile uint32_t * const spi = (void *)(SPI_CTRL_ADDR);

static inline uint8_t spi_xfer(uint8_t d)
{
	int32_t r;

	REG32(spi, SPI_REG_TXFIFO) = d;
	do{
		r = REG32(spi, SPI_REG_RXFIFO);
	} while (r < 0);
	return r;
}

static inline uint8_t sd_dummy(void)
{
	return spi_xfer(0xFF);
}

static uint8_t sd_cmd(uint8_t cmd, uint32_t arg, uint8_t crc)
{
	unsigned long n;
	uint8_t r;

	REG32(spi, SPI_REG_CSMODE) = SPI_CSMODE_HOLD;
	sd_dummy();
	spi_xfer(cmd);
	spi_xfer(arg >> 24);
	spi_xfer(arg >> 16);
	spi_xfer(arg >> 8);
	spi_xfer(arg);
	spi_xfer(crc);

	n = 1000;
	do {
		r = sd_dummy();
		if (!(r & 0x80)) {
//			dprintf("sd:cmd: %hx\r\n", r);
			goto done;
		}
	} while (--n > 0);
	kputs("sd_cmd: timeout");
done:
	return r;
}

static inline void sd_cmd_end(void)
{
	sd_dummy();
	REG32(spi, SPI_REG_CSMODE) = SPI_CSMODE_AUTO;
}


static void sd_poweron(void)
{
	long i;
	// HACK: frequency change

	REG32(spi, SPI_REG_SCKDIV) = SPI_DIV;
	REG32(spi, SPI_REG_CSMODE) = SPI_CSMODE_OFF;
	for (i = 10; i > 0; i--) {
		sd_dummy();
	}
	REG32(spi, SPI_REG_CSMODE) = SPI_CSMODE_AUTO;
}

static int sd_cmd0(void)
{
	int rc;
	dputs("CMD0");
	rc = (sd_cmd(0x40, 0, 0x95) != 0x01);
	sd_cmd_end();
	return rc;
}

static int sd_cmd8(void)
{
	int rc;
	dputs("CMD8");
	rc = (sd_cmd(0x48, 0x000001AA, 0x87) != 0x01);
	sd_dummy(); /* command version; reserved */
	sd_dummy(); /* reserved */
	rc |= ((sd_dummy() & 0xF) != 0x1); /* voltage */
	rc |= (sd_dummy() != 0xAA); /* check pattern */
	sd_cmd_end();
	return rc;
}

static void sd_cmd55(void)
{
	sd_cmd(0x77, 0, 0x65);
	sd_cmd_end();
}

static int sd_acmd41(void)
{
	uint8_t r;
	dputs("ACMD41");
	do {
		sd_cmd55();
		r = sd_cmd(0x69, 0x40000000, 0x77); /* HCS = 1 */
	} while (r == 0x01);
	return (r != 0x00);
}

static int sd_cmd58(void)
{
	int rc;
	dputs("CMD58");
	rc = (sd_cmd(0x7A, 0, 0xFD) != 0x00);
	rc |= ((sd_dummy() & 0x80) != 0x80); /* Power up status */
	sd_dummy();
	sd_dummy();
	sd_dummy();
	sd_cmd_end();
	return rc;
}

static int sd_cmd16(void)
{
	int rc;
	dputs("CMD16");
	rc = (sd_cmd(0x50, 0x200, 0x15) != 0x00);
	sd_cmd_end();
	return rc;
}

static uint16_t crc16_round(uint16_t crc, uint8_t data) {
	crc = (uint8_t)(crc >> 8) | (crc << 8);
	crc ^= data;
	crc ^= (uint8_t)(crc >> 4) & 0xf;
	crc ^= crc << 12;
	crc ^= (crc & 0xff) << 5;
	return crc;
}

#define SPIN_SHIFT	6
#define SPIN_UPDATE(i)	(!((i) & ((1 << SPIN_SHIFT)-1)))
#define SPIN_INDEX(i)	(((i) >> SPIN_SHIFT) & 0x3)

// static const char spinner[] = { '-', '/', '|', '\\' };


static int sd_write_multi_block(uint32_t start_sector, const uint8_t *data, uint32_t num_sectors)
{
    int rc = 0;
    uint32_t sector = start_sector;
    uint32_t n;
    uint16_t crc;

    if (sd_cmd(0x57, num_sectors, 0x01) != 0x00) { // CMD23
        sd_cmd_end();
        kputs("sd_set_block_count: cmd23 fail\r\n");
        return 1;
    }
    sd_cmd_end();

    // CMD25: 多块写
    if (sd_cmd(0x59, sector, 0x01) != 0x00) { // CMD25
        sd_cmd_end();
        kputs("sd_write_multi_block: cmd25 fail\r\n");
        return 1;
    }

    for (n = 0; n < num_sectors; ++n) {
        // 发送多块写起始令牌
        spi_xfer(0xFC);
        crc = 0;
        for (int i = 0; i < SECTOR_SIZE_B; ++i) {
            spi_xfer(data[n * SECTOR_SIZE_B + i]);
            crc = crc16_round(crc, data[n * SECTOR_SIZE_B + i]);
        }
        // 发送CRC
        spi_xfer(crc >> 8);
        spi_xfer(crc & 0xFF);
        // 检查数据响应
        uint8_t resp = sd_dummy();
        if ((resp & 0x1F) != 0x05) {
            kputs("sd_write_multi_block: data reject\r\n");
            rc = 2;
            break;
        }
        // 等待写完成
        while (sd_dummy() == 0) ;
    }
    // 发送多块写结束令牌
    spi_xfer(0xFD);
    sd_cmd_end();
    return rc;
}

static int write_ddr_to_sd_fast(void)
{
    volatile uint8_t *src = (void *)(PAYLOAD_DEST + 0x10000000);
    uint32_t sector = BBL_PARTITION_START_SECTOR;
    int rc = 0;

	if (sd_write_multi_block(sector, (uint8_t *)(src), PAYLOAD_SIZE)) {
		kprintf("Write failed at sector %u\r\n", sector);
		rc = 1;
	}
    return rc;
}


// --- SD卡单块写测试 ---
// static int sd_write_block(uint32_t sector, const uint8_t *data)
// {
//     int rc = 0;
//     uint16_t crc = 0;
//     int i;
//     // CMD24: 写单块
//     if (sd_cmd(0x58, sector, 0x01) != 0x00) {
//         sd_cmd_end();
//         kputs("sd_write_block: cmd24 fail\r\n");
//         return 1;
//     }
//     // 发送数据起始令牌
//     spi_xfer(0xFE);
//     // 发送数据
//     crc = 0;
//     for (i = 0; i < SECTOR_SIZE_B; ++i) {
//         spi_xfer(data[i]);
//         crc = crc16_round(crc, data[i]);
//     }
//     // 发送CRC
//     spi_xfer(crc >> 8);
//     spi_xfer(crc & 0xFF);
//     // 检查数据响应
//     uint8_t resp = sd_dummy();
//     if ((resp & 0x1F) != 0x05) {
//         kputs("sd_write_block: data reject\r\n");
//         rc = 2;
//     }
//     // 等待写完成
//     while (sd_dummy() == 0) ;
//     sd_cmd_end();
// 	kprintf("write sector %d\r\n", sector);
//     return rc;
// }

// static int write_ddr_to_sd(void)
// {
//     volatile uint8_t *src = (void *)(PAYLOAD_DEST + 0x10000000);
//     long sectors = PAYLOAD_SIZE; // 总扇区数
//     uint32_t sector = BBL_PARTITION_START_SECTOR;
//     int rc = 0;

//     kprintf("Writing %ld sectors from DDR to SD card...\r\n", sectors);

//     while (sectors-- > 0) {
//         if (sd_write_block(sector++, (uint8_t *)(src))) {
//             kprintf("Write failed at sector %u\r\n", sector-1);
//             rc = 1;
//             break;
//         }
//         src += SECTOR_SIZE_B;
//     }
//     if (rc == 0) kputs("DDR to SD write: PASS\r\n");
//     else kputs("DDR to SD write: FAIL\r\n");
//     return rc;
// }

// --- SD卡单块读测试 ---
// static int sd_read_block(uint32_t sector, uint8_t *data)
// {
//     int rc = 0;
//     uint16_t crc, crc_exp;
//     int i;
//     if (sd_cmd(0x51, sector, 0x01) != 0x00) { // CMD17: 读单块
//         sd_cmd_end();
//         kputs("sd_read_block: cmd17 fail\r\n");
//         return 1;
//     }
//     while (sd_dummy() != 0xFE);
//     crc = 0;
//     for (i = 0; i < SECTOR_SIZE_B; ++i) {
//         uint8_t x = sd_dummy();
//         data[i] = x;
//         crc = crc16_round(crc, x);
//     }
//     crc_exp = ((uint16_t)sd_dummy() << 8);
//     crc_exp |= sd_dummy();
//     if (crc != crc_exp) {
//         kputs("sd_read_block: CRC mismatch\r\n");
//         rc = 2;
//     }
//     sd_cmd_end();
//     return rc;
// }

// // --- SD卡读写测试 ---
// static int sd_test_rw(uint32_t sector)
// {
//     uint8_t wbuf[SECTOR_SIZE_B];
//     uint8_t rbuf[SECTOR_SIZE_B];
//     int i, rc = 0;
//     // 填充写入数据
//     for (i = 0; i < SECTOR_SIZE_B; ++i) wbuf[i] = (uint8_t)(i ^ 0xA5);
//     // 写
//     if (sd_write_block(sector, wbuf)) {
//         kputs("sd_test_rw: write fail\r\n");
//         return 1;
//     }
//     // 读
//     if (sd_read_block(sector, rbuf)) {
//         kputs("sd_test_rw: read fail\r\n");
//         return 2;
//     }
//     // 校验
//     for (i = 0; i < SECTOR_SIZE_B; ++i) {
//         if (wbuf[i] != rbuf[i]) {
//             kprintf("sd_test_rw: mismatch at %d: %x != %x\r\n", i, wbuf[i], rbuf[i]);
//             rc = 3;
//             break;
//         }
// 		else {
// 			kprintf("sd_test_rw: match  %x == %x\r\n", wbuf[i], rbuf[i]);
// 		}
//     }
//     if (rc == 0) kputs("sd_test_rw: PASS\r\n");
//     else kputs("sd_test_rw: FAIL\r\n");
//     return rc;
// }

// --- 读取SD卡CID寄存器 ---
static int sd_read_cid(void)
{
    uint8_t cid[16];
    int i, rc = 0;
    if (sd_cmd(0x4A, 0, 0x01) != 0x00) { // CMD10: 读CID
        sd_cmd_end();
        kputs("sd_read_cid: cmd10 fail\r\n");
        return 1;
    }
    while (sd_dummy() != 0xFE);
    for (i = 0; i < 16; ++i) {
        cid[i] = sd_dummy();
    }
    // 读CRC
    sd_dummy();
    sd_dummy();
    sd_cmd_end();
    kputs("SD CID: ");
    for (i = 0; i < 16; ++i) {
        kprintf("%x", cid[i]);
        if (i == 7) kputc(' ');
    }
    kputs("\r\n");
    return rc;
}

void print_ddr_data(void) {
    volatile uint8_t *src = (void *)(PAYLOAD_DEST + 0x10000000);
    kputs("First 64 bytes of DDR at 0x10000000 + PAYLOAD_DEST:\r\n");
    for (int i = 0; i < 64; ++i) {
        kprintf("%x ", src[i]);
        if ((i & 0xF) == 0xF) kputs("\r\n");
    }
    kputs("\r\n");
}

int main(void)
{
	REG32(uart, UART_REG_TXCTRL) = UART_TXEN;

	kputs("INIT");
	sd_poweron();
	if (sd_cmd0() ||
	    sd_cmd8() ||
	    sd_acmd41() ||
	    sd_cmd58() ||
	    sd_cmd16()) {
		kputs("ERROR");
		return 1;
	}
	print_ddr_data();

	// --- 读取CID ---
	sd_read_cid();
	// --- 调用SD卡读写测试 ---
	// write_ddr_to_sd_fast();
	// 继续原有copy流程

	kputs("BOOT");

	__asm__ __volatile__ ("fence.i" : : : "memory");

	return 0;
}
