## 一些小工具的使用文档

### 1. disasm-read.sh 反汇编及可视化工具

```bash
./scripts/disasm-read.sh 可执行文件
```

最后会在output/disasm目录下生成三个文件：

- original.txt: 原始反汇编文件
- decoded.txt: 自定义指令替换后的反汇编文件
- visualization.html: 可视化网页

### 2. soc_vis.py soc连线可视化工具
```bash
cd Voyager
mkdir -p ./voyager-test/scripts/vistool/web/public  
python ./voyager-test/scripts/vistool/soc_vis.py sims/verilator/generated-src/chipyard.harness.TestHarness.OurHeterSoCConfig/gen-collateral/filelist.f ./voyager-test/scripts/vistool/web/public/index.html
```