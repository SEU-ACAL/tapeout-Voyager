#!/bin/bash

input_type=simmedium
arch=amd64-linux # Revist: currently is the arch of the host machine


BENCHMARKS=(blackscholes bodytrack dedup facesim ferret fluidanimate freqmine streamcluster swaptions x264)
LIBS=(glib gsl hooks libjpeg libxml2 mesa parmacs ssl tbblib uptcpip zlib)

# Get the directory where this script is located
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base_dir=${script_dir}/build

cd ${base_dir}/apps
rm -rf raytrace 
rm -rf vips

cd ${base_dir}/kernels
rm -rf canneal 


for benchmark in ${BENCHMARKS[@]}; do
    sub_dir=apps
    if [ $benchmark == "dedup" ]; then 
        sub_dir=kernels
    fi

    if [ $benchmark == "streamcluster" ]; then 
        sub_dir=kernels
    fi

    bin_dir=${base_dir}/${sub_dir}/${benchmark}/inst/${arch}.gcc/bin
    run_dir=${base_dir}/${sub_dir}/${benchmark}/run/
    command_dir=${base_dir}/commands/${input_type}
    
    cd ${base_dir}/${sub_dir}/${benchmark}

    echo "[======= Benchmark: ${benchmark} =======]"
    cmd="rm -rf inputs"
    eval ${cmd}
    echo "${cmd}"

    cmd="rm -rf obj"
    eval ${cmd}
    echo "${cmd}"

    cmd="rm -rf parsec"
    eval ${cmd}
    echo "${cmd}"

    cmd="rm -rf src"
    eval ${cmd}
    echo "${cmd}"

    cmd="rm -rf version"
    eval ${cmd}
    echo "${cmd}"
done


cd ${base_dir}/
rm -rf libs
rm -rf netapps
rm -rf tools

echo ""
echo "*** ParsecV3 is Simplified for Execution Only! ***"