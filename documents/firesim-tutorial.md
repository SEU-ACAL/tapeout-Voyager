## firesim tutorial (U280)

FireSim 是由加州大学伯克利分校 RISC-V 生态中诞生的开源硬件仿真框架，其核心突破在于通过 FPGA 集群实现数据中心级硬件行为的精准复现。FireSim 将真实的 RTL 级芯片设计直接部署到 FPGA 上运行，同时通过定制网络栈连接多个 FPGA 节点，形成可弹性扩展的虚拟硬件集群。相比 verilator 等仿真器仿真速度更块，并且可以进行启动 Linux 的 OS级仿真。


### 初始化和配置 -- 环境配置到``firesim enumeratefpgas``



### RTL代码生成比特流 -- ``firesim buildbitstream``




### 运行workload --``firesim infrasetup`` and ``firesim runworkload``



### 常见问题


