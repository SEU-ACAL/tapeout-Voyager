package freechips.rocketchip.guardiancouncil

//修改GH_WIDITH_PACKETS会牵一发动全身
object GH_GlobalParams {
  val GH_NUM_CORES = 5;
  val GH_DEBUG = 1;
  val GH_WIDITH_PERF = 64;
  val GH_TOTAL_PACKETS = 2;
  val GH_TOTAL_INSTS = 3970;

  //一次128bit数据+8bit状态
  val GH_WIDITH_PACKETS = 2*GH_WIDITH_PERF+8;
  val IF_CHECK_OPEN = true;
}

