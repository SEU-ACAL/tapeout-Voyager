#!/bin/bash

# exit script if any command fails
set -e
set -o pipefail

CYDIR=$(git rev-parse --show-toplevel)

src_dir="${CYDIR}/scripts/replacement"
dest_dir="${CYDIR}"

rsync -a --relative "$src_dir/./" "$dest_dir"
