import sys
import  math
def write_to_file(depth : int,width : int ,path : str,model_name : str) :
    A=math.log(width,2)
    depth=int(depth)
    width=int(width)
    A=int(A)
    content=(f"class {model_name} extends BlackBox with HasBlackBoxResource{{"
            "\nval io = IO(new Bundle{ \n"
             "//下面是非测试常规信号\n"
             "\tval CLK  = Input(Clock())\n"
             "\tval CEN  = Input(UInt(1.W))\n"
             "\tval WEN  = Input(UInt(1.W))\n"
            f"\tval A    = Input(UInt({A}.W))\n"
            f"\tval D    = Input(UInt({depth}.W))\n"
             "\tval EMA  = Input(UInt(3.W))\n "
             "\tval EMAW = Input(UInt(2.W))\n"
            f"\tval Q    = Output(UInt({depth}.W))\n"
             "//下面是BIST信号\n"
             "\tval TEN  = Input(UInt(1.W))\n"
             "\tval TCEN = Input(UInt(1.W))\n"
             "\tval TWEN = Input(UInt(1.W))\n"
             "\tval RET1N= Input(UInt(1.W))\n"
             "\tval SE   = Input(UInt(1.W))\n"
             "\tval SI   = Input(UInt(2.W))\n"
             "\tval DFTRAMBYP= Input(UInt(1.W))\n"
             "\tval CENY = Output(UInt(1.W))\n"
             "\tval WENY = Output(UInt(1.W))\n"
            f"\tval TA   = Input(UInt({A}.W))\n"
            f"\tval TD   = Input(UInt({depth}.W))\n"
            f"\tval AY   = Output(UInt({A}.W))\n"
             "\tval SO   = Output(UInt(2.W))\n"
             "})\n"
             f"addResource(\"{path}.v\")"
            "\n"f"}}\n"


            f"class {model_name}_reg extends Module "
            "{\nval io = IO(new Bundle{\n"
            "\tval CLK  = Input(Clock())\n"
            # "\tval RET1N= Wire(UInt(1.W))\n"
            f"\tval A= Input(UInt({A}.W))\n"
            f"\tval D= Input(UInt({depth}.W))\n"
            "\tval CEN= Input(UInt(1.W))\n"
            "\tval WEN= Input(UInt(1.W))\n"
            f"\tval Q= Output(UInt({depth}.W))\n"
            "})\n"

             "//下面是非测试常规信号\n"
            #  "\tval CLK  = Wire(UInt(1.W))\n"
            #  "\tval CEN  = Wire(UInt(1.W))\n"
            #  "\tval WEN  = Wire(UInt(1.W))\n"
            #  f"\tval A    = Wire(UInt({A}.W))\n"
            #  f"\tval D    = Wire(UInt({depth}.W))\n"
             "\tval EMA  = Wire(UInt(3.W))\n "
             "\tval EMAW = Wire(UInt(2.W))\n"
            #  f"\tval Q    = Wire(UInt({depth}.W))\n"
             "//下面是BIST信号\n"
             "\tval TEN  = Wire(UInt(1.W))\n"
             "\tval TCEN = Wire(UInt(1.W))\n"
             "\tval TWEN = Wire(UInt(1.W))\n"
             "\tval RET1N= Wire(UInt(1.W))\n"
             "\tval SE   = Wire(UInt(1.W))\n"
             "\tval SI   = Wire(UInt(2.W))\n"
             "\tval DFTRAMBYP= Wire(UInt(1.W))\n"
             "\tval CENY = Wire(UInt(1.W))\n"
             "\tval WENY = Wire(UInt(1.W))\n"
             f"\tval TA   = Wire(UInt({A}.W))\n"
             f"\tval TD   = Wire(UInt({depth}.W))\n"
             f"\tval AY   = Wire(UInt({A}.W))\n"
             "\tval SO   = Wire(UInt(2.W))\n"
            f"val {model_name}=Module(new {model_name}()) \n"
             "// 信号赋值\n"
             "TEN:=1.U\n"
             "TCEN:=1.U\n"
             "TWEN:=1.U\n"
             "SE:=0.U\n"
             "SI:=1.U\n"
             "DFTRAMBYP:=0.U\n"
             "TA:=1.U\n"
             "TD:=1.U\n"
             "EMA:=0.U\n"
             "EMAW:=0.U\n"
             "RET1N:=1.U\n"


            f"{model_name}.io.CLK :=io.CLK\n"
            f"{model_name}.io.CEN :=io.CEN\n"
            f"{model_name}.io.WEN :=io.WEN\n"
            f"{model_name}.io.A   :=io.A\n"
            f"{model_name}.io.D   :=io.D\n"
            f"{model_name}.io.EMA :=EMA\n"
            f"{model_name}.io.EMAW :=EMAW\n"
            f"io.Q:={model_name}.io.Q\n"
             f"{model_name}.io.TEN :=TEN\n"
             f"{model_name}.io.TCEN :=TCEN\n"
             f"{model_name}.io.TWEN :=TWEN\n"
             f"{model_name}.io.RET1N :=RET1N\n"
             f"{model_name}.io.SE :=SE\n"
             f"{model_name}.io.SI :=SI\n"
             f"{model_name}.io.DFTRAMBYP :=DFTRAMBYP\n"
             f"{model_name}.io.TA :=TA\n"
             f"{model_name}.io.TD :=TD\n"
             f"AY:={model_name}.io.AY\n"
             f"SO:={model_name}.io.SO\n"
             f"CENY:={model_name}.io.CENY\n"
             f"WENY:={model_name}.io.WENY\n"
              "}\n"
              "\n"
             )
    with open('splice_instant.txt', 'a') as file:
        file.write(content)

def splice(mode=None,model_name1=None,model_name2=None,A1=None,A2=None,D1=None,D2=None):
    D1=int(D1)
    A1=int(A1)
    D2=int(D2)
    A2=int(A2)
    if mode==1:#位宽拼接 地址不变 只改变输出q和写入d
        A=int(math.log(A1,2))
        D=int(D1+D2)
        Q=D
        content=(
            "class final_name extends Module{ \n"
            "val io = IO(new Bundle{ \n"
            f"val A = Input(UInt({A}.W))\n"
            "val CEN = Input(UInt(1.W))\n"
            "val WEN = Input(UInt(1.W))\n"
            f"val D = Input(UInt({D}.W))\n"
            f"val Q = Output(UInt({D}.W))\n"
            "})\n"
            f"val {model_name1}_1=Module(new {model_name1}_reg)\n"
            f"val {model_name2}_2=Module(new {model_name2}_reg)\n"
            f"{model_name1}_1.io.CLK:=clock\n"
            f"{model_name2}_2.io.CLK:=clock\n"

            f"{model_name1}_1.io.CEN:=io.CEN\n"
            f"{model_name2}_2.io.CEN:=io.CEN\n"

            f"{model_name1}_1.io.WEN:=io.WEN\n"
            f"{model_name2}_2.io.WEN:=io.WEN\n"

            f"{model_name1}_1.io.A:=io.A\n"
            f"{model_name2}_2.io.A:=io.A\n"

            f"{model_name1}_1.io.D:=io.D({D1-1},0)\n"
            f"{model_name2}_2.io.D:=io.D({D-1},{D1})\n"

            f"io.Q:=Cat({model_name1}_1.io.Q,{model_name2}_2.io.Q)\n"
            "}\n"
    )
        
    else : #地址拼接
        A1=int(math.log(A1,2))
        A2=int(math.log(A2,2))
        A=max(A1,A2)+1
        D=int(D1)
        Q=D
        content=(
            "class final_name extends Module{ \n"
            "val io = IO(new Bundle{ \n"
            f"val A = Input(UInt({A}.W))\n"
            "val CEN = Input(UInt(1.W))\n"
            "val WEN = Input(UInt(1.W))\n"
            f"val D = Input(UInt({D}.W))\n"
            f"val Q = Output(UInt({D}.W))\n"
            "})\n"
            f"val {model_name1}_1=Module(new {model_name1}_reg)\n"
            f"val {model_name2}_2=Module(new {model_name2}_reg)\n"
            f"{model_name1}_1.io.CLK:=clock\n"
            f"{model_name2}_2.io.CLK:=clock\n"

            f"{model_name1}_1.io.WEN:=io.WEN\n"
            f"{model_name2}_2.io.WEN:=io.WEN\n"

            f"when (io.A({A-1}) === 0.U) "
            "{ \n"
            
            f"io.Q:={model_name1}_1.io.Q \n"
            f"{model_name1}_1.io.CEN:=io.CEN\n"
            f"{model_name2}_2.io.CEN:=1.U\n"
            "}.otherwise{ \n"
            f"{model_name2}_2.io.CEN:=io.CEN\n"
            f"{model_name1}_1.io.CEN:=1.U\n"
             f"io.Q:={model_name2}_2.io.Q \n"
            "}\n"

            f"{model_name1}_1.io.A:=io.A({A-2},0)\n"
            f"{model_name2}_2.io.A:=io.A({A-2},0)\n"
            f"{model_name1}_1.io.D:=io.D\n"
            f"{model_name2}_2.io.D:=io.D\n"

            "}\n"
    )


    with open('splice_instant.txt', 'a') as file:
        file.write(content)
        


if __name__ == "__main__":
    if len(sys.argv) >1:
        mode=int(sys.argv[1])
        width1 = int(sys.argv[2])
        depth1=float(sys.argv[3])

        path1 =str(sys.argv[4])
        model_name1=str(sys.argv[5])
        width2 = int(sys.argv[6])
        depth2=float(sys.argv[7])

        path2 =str(sys.argv[8])
        model_name2=str(sys.argv[9])
        if model_name1==model_name2 :
            write_to_file(depth1, width1, path1,model_name1)
        else :
            write_to_file(depth1, width1, path1,model_name1)
            write_to_file(depth2, width2, path2,model_name2)
        splice(mode=mode,model_name1=model_name1,model_name2=model_name2,A1=depth1,A2=depth2,D1=width1,D2=width2)

    else:
        print("parameters error!")