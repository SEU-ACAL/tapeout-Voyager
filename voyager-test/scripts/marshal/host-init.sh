#!/bin/bash

# This script will run on the host from the workload directory
# (e.g. workloads/example-fed) every time the workload is built.
# It is recommended to call into something like a makefile because
# this script may be called multiple times.

CYDIR=$(git rev-parse --show-toplevel)

cd $CYDIR && source env.sh

echo "Building marshal workload"
cd $CYDIR/voyager-test/build
make #-j256

cd $CYDIR/voyager-test/output
mkdir -p ./marshal/overlay/root/
cp -r ./workloads/* ./marshal/overlay/root/
