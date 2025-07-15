# Voyager流片平台对接文档



### 服务器账号

东南VPN网络下

ssh tyc@10.201.230.232

密码：tyctyc



**登录上后执行chipyard_exec，会启用环境变量并将你传送到流片仓库根目录**





### 工作路径

![image](./image/img1.png)

说明：

- 生成的Verilog代码中``ChipTop`` 为实际流片CPU+NPU的顶层，`` TestHarness `` 为我们进行仿真测试的顶层
- `` device/peripheral-npu`` 中定义了 npu 的顶层和并连接 resources 中具体实现的 verilog

- `` iobinders`` 中定义了 npu 的 pin脚如何拉到`` ChipTop``
- `` harness`` 中定义了 npu  的 pin脚在拉到`` TestHarness``，规定测试时的行为，否则无法构建完整比特流和跑仿真



代码阅读：可以通过搜索PeripheralNPU等字段可以查看如何将外设连到外设总线（pbus）和将pin脚拉到顶层， 具体阅读这三个 trait即可

![image](./image/img2.png)



### 代码生成

完整SOC代码生成，请使用该命令，生成的所有.v文件将存放在`` tapeout/generated-src`` 下

```
chipyard_exec
./voyager-test/scripts/build-verilator.sh --config VoyagerVerilatorConfig --project voyager_tapeout --sub-project voyager_tapeout
```

使用该命令可以通过执行等测试workload仿真，如

```
chipyard_exec
./voyager-test/scripts/run-verilator.sh --config VoyagerVerilatorConfig --debug ctest_acc_matmul_multicore
```

workload书写见`` ./voyager-test/src/workload`` 



实际完全流片的配置需要使用其他命令生成，该命令能跑通之后生成verilog流程正常也能跑通



### 代码更新与提交

记得定时git pull拉取总体仓库代码进行同步