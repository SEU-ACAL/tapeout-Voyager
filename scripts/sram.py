import  numpy
import sys
import  math
def write_to_file(depth : int,width : int ,path : str,model_name : str) :
    A=math.log(width,2)
    depth=int(depth)
    width=int(width)
    A=int(A)
    content=(f"class sram{depth}x{width} extends BlackBox with HasBlackBoxResource{{"
            "\nval io = IO(new Bundle{ \n"
             "//下面是非测试常规信号\n"
             "\tval CLK  = Input(UInt(1.W))\n"
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
             f"addResource(\"/{path}.v\")"
            "\n"f"}}\n"
            f"class sram{depth}x{width}_reg extends Module "
            "{\nval io = IO(new Bundle{\n"
            "\tval CLK  = Input(UInt(1.W))\n"
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
            f"val {model_name}=Module(new sram{depth}x{width}()) \n"
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
              "}"
             )
    with open('instant.txt', 'w') as file:
        file.write(content)



if len(sys.argv) <4:
    depth=float(sys.argv[1])
    width=int(sys.argv[2])
    path =str(sys.argv[3])
    model_name=str(sys.argv[4])
    write_to_file(depth, width, path,model_name)
else:
    print("parameters error!")