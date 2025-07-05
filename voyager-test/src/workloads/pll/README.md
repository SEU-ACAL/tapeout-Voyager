# PLL 测试程序

本目录包含用于测试PLL的C语言程序。

> 建议将pll切换写入bootrom程序

## 🔧 外设寄存器映射

pll实例包含3个地址空间，分别对应divider，selecter ，以及pll控制寄存器：

具体的地址在示例代码中有

## 注意

AbstractConfig.scala

```
  new chipyard.clocking.WithPLLSelectorDividerClockGenerator(enable=false)
```

如果想在RTL仿真，必须修改enable为false，并且修改TLClockDivider，TLClockSelector，直接把enable对应的else注释给去掉
