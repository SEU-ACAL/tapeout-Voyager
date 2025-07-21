//`define PLL6GS28_FAST_MODE   //use to shorten the time of pll lock, the time is PLL_LOCK_FAST_COUNT*I_PLL_REFDIV*T(I_PLL_CKREF)
`define PLL_LOCK_FAST_COUNT	100	//only in fast mode, this signal is used to set the lock tim
`define PLL6GS28_PG_PIN //use to define the power and ground pins in rtl, else the power and ground pin are conntect to 1 or 0 by internal.

