## 一些小工具的使用文档

### 1. disasm-read.sh 反汇编及可视化工具

```bash
./scripts/disasm-read.sh 可执行文件
```

最后会在output/disasm目录下生成三个文件：

- original.txt: 原始反汇编文件
- decoded.txt: 自定义指令替换后的反汇编文件
- visualization.html: 可视化网页
