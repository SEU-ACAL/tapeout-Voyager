// Enhanced kprintf implementation with width and zero-padding support
#include <stdarg.h>
#include <stdint.h>
#include <stdbool.h>

#include "kprintf.h"

static inline void _kputs(const char *s)
{
	char c;
	for (; (c = *s) != '\0'; s++)
		kputc(c);
}

void kputs(const char *s)
{
	_kputs(s);
	kputc('\r');
	kputc('\n');
}

// 支持宽度和填充的数字转换函数
static void _putnum_padded(unsigned long num, int base, bool uppercase, int width, bool zero_pad)
{
	char buf[32];
	const char *digits = uppercase ? "0123456789ABCDEF" : "0123456789abcdef";
	int pos = 0;
	
	if (num == 0) {
		buf[pos++] = '0';
	} else {
		while (num > 0) {
			buf[pos++] = digits[num % base];
			num /= base;
		}
	}
	
	// 计算需要的填充
	int pad_count = width - pos;
	if (pad_count < 0) pad_count = 0;
	
	// 输出填充字符
	char pad_char = zero_pad ? '0' : ' ';
	for (int i = 0; i < pad_count; i++) {
		kputc(pad_char);
	}
	
	// 倒序输出数字
	for (int i = pos - 1; i >= 0; i--) {
		kputc(buf[i]);
	}
}

// 有符号数字输出（支持宽度）
static void _putsigned_padded(long num, int width, bool zero_pad)
{
	if (num < 0) {
		kputc('-');
		if (width > 0) width--;  // 减去负号占用的宽度
		num = -num;
	}
	_putnum_padded(num, 10, false, width, zero_pad);
}

static bool flag = false;

void kprintf(const char *fmt, ...)
{
	// 初始化 UART
	if (!flag) {
		REG32(uart, UART_REG_TXCTRL) = UART_TXEN;
		flag = true;
	}
	
	va_list vl;
	va_start(vl, fmt);
	
	char c;
	while ((c = *fmt++) != '\0') {
		if (c != '%') {
			kputc(c);
			continue;
		}
		
		// 解析格式修饰符
		bool zero_pad = false;
		int width = 0;
		
		// 检查零填充标志
		c = *fmt;
		if (c == '0') {
			zero_pad = true;
			fmt++;
		}
		
		// 解析宽度
		while ((c = *fmt) >= '0' && c <= '9') {
			width = width * 10 + (c - '0');
			fmt++;
		}
		
		// 获取格式说明符
		c = *fmt++;
		
		switch (c) {
		case 'd':
		case 'i': {
			int num = va_arg(vl, int);
			_putsigned_padded(num, width, zero_pad);
			break;
		}
		case 'u': {
			unsigned int num = va_arg(vl, unsigned int);
			_putnum_padded(num, 10, false, width, zero_pad);
			break;
		}
		case 'x': {
			unsigned int num = va_arg(vl, unsigned int);
			_putnum_padded(num, 16, false, width, zero_pad);
			break;
		}
		case 'X': {
			unsigned int num = va_arg(vl, unsigned int);
			_putnum_padded(num, 16, true, width, zero_pad);
			break;
		}
		case 'o': {
			unsigned int num = va_arg(vl, unsigned int);
			_putnum_padded(num, 8, false, width, zero_pad);
			break;
		}
		case 'p': {
			void *ptr = va_arg(vl, void *);
			_kputs("0x");
			_putnum_padded((unsigned long)ptr, 16, false, sizeof(void*)*2, true);
			break;
		}
		case 's': {
			const char *str = va_arg(vl, const char *);
			if (!str) str = "(null)";
			
			// 简单的字符串宽度处理
			int len = 0;
			const char *p = str;
			while (*p++) len++;  // 计算字符串长度
			
			// 右对齐填充
			for (int i = len; i < width; i++) {
				kputc(' ');
			}
			_kputs(str);
			break;
		}
		case 'c': {
			char ch = va_arg(vl, int);
			// 字符宽度处理
			for (int i = 1; i < width; i++) {
				kputc(' ');
			}
			kputc(ch);
			break;
		}
		case '%':
			kputc('%');
			break;
		case 'b': {
			// 二进制输出 (扩展)
			unsigned int num = va_arg(vl, unsigned int);
			_putnum_padded(num, 2, false, width, zero_pad);
			break;
		}
		default:
			// 未知格式说明符
			kputc('%');
			kputc(c);
			break;
		}
	}
	
	va_end(vl);
}

// printf 包装函数
int __wrap_printf(const char *fmt, ...)
{
	// 初始化 UART
	if (!flag) {
		REG32(uart, UART_REG_TXCTRL) = UART_TXEN;
		flag = true;
	}
	
	va_list vl;
	va_start(vl, fmt);
	
	char c;
	while ((c = *fmt++) != '\0') {
		if (c != '%') {
			kputc(c);
			continue;
		}
		
		// 解析格式修饰符
		bool zero_pad = false;
		int width = 0;
		
		// 检查零填充标志
		c = *fmt;
		if (c == '0') {
			zero_pad = true;
			fmt++;
		}
		
		// 解析宽度
		while ((c = *fmt) >= '0' && c <= '9') {
			width = width * 10 + (c - '0');
			fmt++;
		}
		
		// 获取格式说明符
		c = *fmt++;
		
		switch (c) {
		case 'd':
		case 'i': {
			int num = va_arg(vl, int);
			_putsigned_padded(num, width, zero_pad);
			break;
		}
		case 'u': {
			unsigned int num = va_arg(vl, unsigned int);
			_putnum_padded(num, 10, false, width, zero_pad);
			break;
		}
		case 'x': {
			unsigned int num = va_arg(vl, unsigned int);
			_putnum_padded(num, 16, false, width, zero_pad);
			break;
		}
		case 'X': {
			unsigned int num = va_arg(vl, unsigned int);
			_putnum_padded(num, 16, true, width, zero_pad);
			break;
		}
		case 'o': {
			unsigned int num = va_arg(vl, unsigned int);
			_putnum_padded(num, 8, false, width, zero_pad);
			break;
		}
		case 'p': {
			void *ptr = va_arg(vl, void *);
			_kputs("0x");
			_putnum_padded((unsigned long)ptr, 16, false, sizeof(void*)*2, true);
			break;
		}
		case 's': {
			const char *str = va_arg(vl, const char *);
			if (!str) str = "(null)";
			
			// 简单的字符串宽度处理
			int len = 0;
			const char *p = str;
			while (*p++) len++;  // 计算字符串长度
			
			// 右对齐填充
			for (int i = len; i < width; i++) {
				kputc(' ');
			}
			_kputs(str);
			break;
		}
		case 'c': {
			char ch = va_arg(vl, int);
			// 字符宽度处理
			for (int i = 1; i < width; i++) {
				kputc(' ');
			}
			kputc(ch);
			break;
		}
		case '%':
			kputc('%');
			break;
		case 'b': {
			// 二进制输出 (扩展)
			unsigned int num = va_arg(vl, unsigned int);
			_putnum_padded(num, 2, false, width, zero_pad);
			break;
		}
		default:
			// 未知格式说明符
			kputc('%');
			kputc(c);
			break;
		}
	}
	
	va_end(vl);
	return 0;
} 