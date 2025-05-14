#!/usr/bin/env bash

# exit script if any command fails
set -e
set -o pipefail

CYDIR=$(git rev-parse --show-toplevel)

cd ${CYDIR}
source ${CYDIR}/env.sh

pip install pre-commit
pre-commit install
git update-index --skip-worktree scripts/permission-check.sh

# do this when you see this error:
# error: Your local changes to the following files would be overwritten by merge:
#         scripts/permission-check.sh
# Please commit your changes or stash them before you merge. 

# git update-index --no-skip-worktree scripts/permission-check.sh
