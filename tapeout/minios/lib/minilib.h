#ifndef MINILIB_H
#define MINILIB_H

#include "types.h"
#include <stddef.h>
#include <stdarg.h>

int printf(const char *s, ...);
void panic(char *s);

#endif /* MINILIB_H */
