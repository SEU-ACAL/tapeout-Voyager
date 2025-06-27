//===- ThreadConfigurations.scala - Thread连接和操作配置示例 ---===//
package buckyball.exec.bfp

import dialect.vector.SupportedFuncUnits

object ThreadConfigurations {
  object SingleOps {
    val mulOp = ThreadOpsConfig(mul = true)           // 乘法操作
    val addOp = ThreadOpsConfig(add = true)           // 加法操作  
    val subOp = ThreadOpsConfig(sub = true)           // 减法操作
    val divOp = ThreadOpsConfig(div = true)           // 除法操作
    val squareOp = ThreadOpsConfig(square = true)     // 平方操作
    val maxOp = ThreadOpsConfig(max = true)           // 最大值操作
    val popOp = ThreadOpsConfig(pop = true)           // 弹出操作
    val vmulOp = ThreadOpsConfig(vmul = true)         // 向量乘法操作
    val bfpOp = ThreadOpsConfig(bfpReduce = true)     // BFP规约操作
    val cituOp = ThreadOpsConfig(citu = true)         // CITU矩阵乘法操作
  }
  
  // def customExConfig(): (ThreadConfig, ClusterConnection) = {
  //   val config = ThreadConfig(numThreads = 5, lane = 16, dataFormat = "FP16")
  //   val connection = ClusterConnection(Seq(
  //     ThreadRoute("input_splitter", Seq("external"), 
  //                 Seq("mul_thread", "add_thread", "square_thread"), 
  //                 SingleOps.popOp),
      
  //     ThreadRoute("mul_thread", Seq("input_splitter"), Seq("output_merger"), 
  //                 SingleOps.mulOp),
  //     ThreadRoute("add_thread", Seq("input_splitter"), Seq("output_merger"), 
  //                 SingleOps.addOp),
  //     ThreadRoute("square_thread", Seq("input_splitter"), Seq("output_merger"), 
  //                 SingleOps.squareOp),
      
  //     ThreadRoute("output_merger", Seq("mul_thread", "add_thread", "square_thread"), 
  //                 Seq("external"), SingleOps.bfpOp)
  //   ))
  //   (config, connection)
  // }
  
  // 默认执行配置 - 复杂多链路设计 + 双CITU
  def customExConfig(): (ThreadConfig, ClusterConnection) = {
    val config = ThreadConfig(
      numThreads = 14,  // 保持14个threads以匹配路由配置
      lane = 16,
      // dataFormat = "INT8"
      dataFormat = "FP16"
    )
    
    val connection = ClusterConnection(Seq(
      // Chain1 threads
      ThreadRoute("vmul1", Seq("input_port1"), Seq("reduce1"), ThreadOpsConfig(vmul = true)),
      ThreadRoute("reduce1", Seq("vmul1", "input_port1"), Seq("adder1", "citu1"), ThreadOpsConfig(bfpReduce = true)),
      ThreadRoute("adder1", Seq("reduce1"), Seq("adder2"), ThreadOpsConfig(add = true)),
      ThreadRoute("reduce2", Seq("input_port2", "adder2"), Seq("citu1", "citu2"), ThreadOpsConfig(bfpReduce = true)),
      ThreadRoute("citu1", Seq("reduce2", "sub1", "reduce1"), Seq("mul_chain1", "reduce3", "mul_chain3"), ThreadOpsConfig(mul = true, add = true, citu = true)),  // CITU替换adder3
      ThreadRoute("mul_chain1", Seq("citu1"), Seq("output_port1"), ThreadOpsConfig(mul = true)),
      
      // Chain2 threads  
      ThreadRoute("sub1", Seq("input_port1"), Seq("citu1"), ThreadOpsConfig(sub = true)),
      ThreadRoute("reduce3", Seq("citu1"), Seq("adder2", "output_port1"), ThreadOpsConfig(bfpReduce = true)),
      ThreadRoute("sub2", Seq("input_port2"), Seq("citu2"), ThreadOpsConfig(sub = true)),
      ThreadRoute("div1", Seq("citu2", "adder2"), Seq("output_port2"), ThreadOpsConfig(div = true)),
      
      // Chain3 threads (共享citu1和mul)
      ThreadRoute("mul_chain3", Seq("citu1"), Seq("output_port2"), ThreadOpsConfig(mul = true)),
      
      // Chain4 threads
      ThreadRoute("citu2", Seq("reduce2", "sub2"), Seq("div1", "reduce4"), ThreadOpsConfig(mul = true, add = true, citu = true)),  // CITU替换adder4
      ThreadRoute("reduce4", Seq("citu2"), Seq("output_port2"), ThreadOpsConfig(bfpReduce = true)),
      
      // Shared threads
      ThreadRoute("adder2", Seq("adder1", "reduce3"), Seq("reduce2", "div1"), ThreadOpsConfig(add = true))
    ))
    
    (config, connection)
  }
  
  // 便捷访问方法
  def getConfiguration(name: String): (ThreadConfig, ClusterConnection) = {
    name match {
      case "custom_ex" => customExConfig()
      case _ => customExConfig() // 默认配置
    }
  }
  
  // 打印配置信息
  def printConfiguration(name: String): Unit = {
    val (config, connection) = getConfiguration(name)
    println(s"=== $name Configuration ===")
    println(s"Threads: ${config.numThreads}, Lane: ${config.lane}")
    println("Thread Routes:")
    connection.routes.foreach { route =>
      println(s"  ${route.threadId}:")
      println(s"    Inputs: ${route.inputSources.mkString(", ")}")
      println(s"    Outputs: ${route.outputTargets.mkString(", ")}")
      val ops = Seq(
        if(route.operations.mul) "mul" else "",
        if(route.operations.add) "add" else "",
        if(route.operations.sub) "sub" else "",
        if(route.operations.div) "div" else "",
        if(route.operations.square) "square" else "",
        if(route.operations.max) "max" else "",
        if(route.operations.pop) "pop" else "",
        if(route.operations.vmul) "vmul" else "",
        if(route.operations.bfpReduce) "bfpReduce" else "",
        if(route.operations.citu) "citu" else ""
      ).filter(_.nonEmpty)
      println(s"    Operations: ${ops.mkString(", ")}")
    }
    println()
  }
}
