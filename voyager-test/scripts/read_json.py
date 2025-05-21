import json
import sys
import os
import math

def log2_ceil(n):
    if n <= 0:
        raise ValueError("n must be a positive integer")
    return math.ceil(math.log2(n))
# 获取 JSON 文件路径



# 示例：打印每个模块的名称
# for module in modules:
    



def create_sv_file_in_directory(directory, filename, content):
    """
    在指定目录下创建一个 .sv 文件并写入内容。
    
    :param directory: 目标目录路径
    :param filename: 文件名（不包含路径）
    :param content: 要写入文件的内容
    """
    try:
        # 确保文件扩展名为 .sv
        if not filename.endswith('.sv'):
            filename += '.sv'
        
        # 创建完整的文件路径（包括目录和文件名）
        file_path = os.path.join(directory, filename)
        
        # 确保目录存在
        os.makedirs(directory, exist_ok=True)
        
        # 以写入模式打开文件并写入内容
        with open(file_path, 'w') as f:
            f.write(content)
        print(f"文件 '{file_path}' 已成功创建并写入内容。")
        
    except Exception as e:
        print(f"发生错误: {e}")



if len(sys.argv) > 2:
    dbfile_path = sys.argv[1]
    svfile_path = sys.argv[2]
    json_file=sys.argv[3]
else:
    print("请指定一个目录路径作为参数运行脚本。")
    sys.exit(1)

try:
    # 打开并读取 JSON 文件
    with open(json_file, 'r') as f:
        modules = json.load(f)
    # 打印成功消息和模块数量
    print(f"JSON 文件加载成功。模块数量: {len(modules)}")

except FileNotFoundError:
    print(f"错误: 未找到文件 '{json_file}'")
except json.JSONDecodeError:
    print(f"错误: 文件 '{json_file}' 中的 JSON 格式无效")
except Exception as e:
    print(f"发生未知错误: {e}")

print('Please make sure include the follwing .db files')

for module in modules:
    print(f"Module name :{module['module_name']}")
    print(f"SRAM Depth :{module['depth']}")
    print(f"SRAM Width :{module['width']}")
    print(f"{module['read']+module['write']+module['readwrite']} port")
    filename = module['module_name']
    depth=int(module['depth'])
    width=int(module['width'])
    if module['read']+module['write']+module['readwrite']==1: #single port
        sram_name=f'Single_{depth}_{width}.db'
    else :
        sram_name=f'Dual_{depth}_{width}.db'
    # print(sram_name)
    db_path = os.path.join(dbfile_path, sram_name)
    sv_path = os.path.join(svfile_path,f'{filename}.sv')
    # print(db_path)
    if os.path.isfile(db_path):
        print(f'{filename}找到相应的db文件')
        if module['read']+module['write']+module['readwrite']==1 :
            content = f'''module {filename} (
                    input  [{log2_ceil(depth)}:0] RW0_addr,
                    input         RW0_en,
                    input         RW0_clk,
                    input         RW0_wmode,
                    input  [{width}:0] RW0_wdata,
                    output [{width}:0] RW0_rdata
                );

                Single_{depth}_{width} u0 (
                    .CLK(RW0_clk),
                    .CEN(RW0_en),
                    .WEN(RW0_wmode),
                    .A(RW0_addr),
                    .D(RW0_wdata),
                    .Q(RW0_rdata)
                );

                endmodule
                '''
            create_sv_file_in_directory(svfile_path,filename, content)
        else :
            content = f'''module {filename} (
                    input  [{log2_ceil(depth)}:0] R0_addr,
                    input  [{log2_ceil(depth)}:0] W0_addr,
                    input         R0_en,
                    input         W0_en,
                    input         RW0_clk,
                    input         R0_clk,
                    input         W0_clk,
                    input  [{width}:0] R0_wdata,
                    output [{width}:0] W0_rdata
                );
                {sram_name} u0 (
                    .CLKA(R0_clk),
                    .CLKA(W0_clk),
                    .CENA(R0_en),
                    .CENA(W0_en),
                    .WENA(1'b1),
                    .WENB(1'b0),
                    .AA(R0_addr),
                    .AB(W0_addr),
                    .DB(W0_wdata),
                    .QA(R0_rdata)
                );
                endmodule
                '''
        create_sv_file_in_directory(svfile_path,filename, content)
    elif os.path.isfile(sv_path) :
        print(f'{filename}找到相应的sv文件')
    else :
        raise Exception(f"未找到{filename}.sv或db文件，请确保命名符号要求")

   
   