#!/bin/bash

# 定义程序名称列表
# PROGRAMS=(x264)
# PROGRAMS=(freqmine swaptions x264)
# PROGRAMS=(fluidanimate)
PROGRAMS=(blackscholes bodytrack ferret fluidanimate streamcluster  swaptions x264)
# PROGRAMS=(blackscholes fluidanimate)
echo "Starting execution of programs..."
# 遍历程序列表并运行
for program in "${PROGRAMS[@]}"; do
    # 构建程序路径
    # program_path="$PROGRAM_DIR/$program"
    cd /root/benchmarks/$program
    echo "$program Start!!!"
    chmod 777 $program.sh
    ./$program.sh
    echo "$program Done!!!"
done

echo "All programs executed!"
poweroff