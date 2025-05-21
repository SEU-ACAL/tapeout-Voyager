#工作流程

#读入json文件

#分析json文件中需要的sram类型

#在指定目录下检索是否包含相应sram db文件或者是sv文件

#如果包含相应sram db文件，则生成相应例化RTL代码

#如果包含相应sv文件，则保持不动

#如果检查不到相应的sram db和sv文件则报错

python ${CYDIR}/voyager-test/scripts/read_json.py $DB_FILE $DESIGN_DIR "/home/hxm123/tapeout-Voyager/sims/verilator/generated-src/chipyard.harness.TestHarness.GemminiRocketConfig/gen-collateral/metadata/seq_mems.json"
包含三个传入参数，按顺序依次为DB目录、Degsign目录以及json目录 可以搭配run-dc.sh使用。

具体使用流程：
1.生成相应DB文件，命名规则如下：
if  #single port
        sram_name=Single_{depth}_{width}.db
    else Dual port :
        sram_name=Dual_{depth}_{width}.db
2.将生成的文件保存到DB目录下
3.如果需要拼接sram，则将使用到的DB全部放到DB目录下，拼接完成的sram放到Design_Dir下
4.执行run-dc脚本