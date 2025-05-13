sram.py 将单个sram compiler生成的chisel Module 时序  该脚本输入参数width(数据宽度) depth（数据量）path(mc生成Verilog文件的位置 建议在脚本生成之后再检查一遍) model_name（mc生成sram的名字 确保正确） 
sram_splice.py 将两个sram拼接为一个支持两种拼接方式 ：1.位宽拼接，地址不变 2.地址拼接，位宽不变 输入参数：mode(选择模式 1为位宽拼接 2为地址拼接) 第一个sram的宽度 width  第一个sram的深度depth 第一个sramVerilog文件的路径  第一个sram的名字 第二个sram宽度 width 第二个sram的深度 depth 第二个sramVerilog文件的路径 第二个sram的名字。
以上所有脚本生成的代码都会在一个txt文件中，可以粘贴直接使用。
