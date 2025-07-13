#!/usr/bin/env bash

# exit script if any command fails
set -e
set -o pipefail

CYDIR=$(git rev-parse --show-toplevel)

source ${CYDIR}/env.sh

cd ${CYDIR}
git submodule update --init voyager-test/src/workloads/embench/embench-iot

cd ${CYDIR}/voyager-test/src/workloads/embench/embench-iot
git apply --ignore-whitespace ../embench.patch
cd ..
./build.sh


cd ${CYDIR}/voyager-test
mkdir -p build && cd build 
cmake ..
make

# install requirements for sardine
pip install -r ${CYDIR}/voyager-test/scripts/sardine/requirements.txt
sudo npm install -g allure-commandline # may need sudo, this is not suitable for all users, need be fixed later

