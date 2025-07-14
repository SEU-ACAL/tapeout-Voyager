#!/bin/bash

CYDIR=$(git rev-parse --show-toplevel)

cd ${CYDIR}
source ${CYDIR}/env.sh

# git submodule update --init voyager-test/src/workloads/embench/embench-iot

# bash ./scripts/init-voyager-test.sh

git submodule update --init voyager-test/src/workloads/parsecv3/parsec-benchmark
