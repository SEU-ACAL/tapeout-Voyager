// WM (Weight Memory) defines
`define WM_WIDTH         64
`define WM_Bank_DEPTH_L  1024
`define WM_Bank_DEPTH_S  128
`define WM_Bank_NUM      16
`define WM_DEPTH_L       16384
`define WM_DEPTH_S       2048

// FM (Feature Map) defines
`define FM_WIDTH         64
`define FM_Bank_DEPTH    64
`define FM_Bank_NUM      64
`define FM_DEPTH         4096

// OB (Output Buffer) defines
`define OB_WIDTH         64
`define OB_Bank_DEPTH    64
`define OB_Bank_NUM      32
`define OB_DEPTH         2048

// CSR (Control and Status Register) defines
`define CSR_WIDTH        64
`define CSR_DEPTH        16

// CIM (Compute-In-Memory) defines
`define CIM_WIDTH        64
`define CIM_Bank_DEPTH_L 512
`define CIM_Bank_DEPTH_S 64
`define CIM_Bank_NUM     8
`define CIM_DEPTH_L      4096
`define CIM_DEPTH_S      512

`define offset 			 2048


// `define CSR_ADDR 32'h49000