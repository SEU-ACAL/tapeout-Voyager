#!/bin/bash
set -eo pipefail

CYDIR=$(git rev-parse --show-toplevel)
FIRESIM_PATH=${CYDIR}/../firesim

while [[ $# -gt 0 ]]; do
    case "$1" in
        --firesim)
            [[ -z $2 ]] && { echo "Error: --firesim requires a path"; exit 1; }
            FIRESIM_PATH=$(realpath "$2")
            shift 2
            ;;
        *) 
            echo "Invalid option: $1" >&2
            exit 1
            ;;
    esac
done

SOURCE_DIR="${CYDIR}/generators"
DEST_ROOT="${FIRESIM_PATH}/target-design/chipyard/generators"

[[ -d "$SOURCE_DIR" ]] || { echo "源目录不存在: $SOURCE_DIR"; exit 1; }
mkdir -p "$DEST_ROOT"

echo "正在扫描.scala文件..."
cd "$SOURCE_DIR"

# 计算文件总数
total_files=$(find . -type f -name '*.scala' -printf '.' | wc -c)
echo "发现 ${total_files} 个.scala文件需要同步"

echo "开始同步到 $DEST_ROOT ..."

# 使用rsync结合进度条
find . -type f -name '*.scala' -print0 |
pv -0 -l -s "$total_files" -N "同步进度" |
rsync -av0 --files-from=- --from0 . "$DEST_ROOT/" 

echo "同步完成！目标目录：$DEST_ROOT"

###############################
SOURCE_DIR="${CYDIR}/sims/firesim/"
DEST_ROOT="${FIRESIM_PATH}/"

[[ -d "$SOURCE_DIR" ]] || { echo "源目录不存在: $SOURCE_DIR"; exit 1; }
mkdir -p "$DEST_ROOT"

echo "正在扫描.scala文件..."
cd "$SOURCE_DIR"

# 预计算文件总数
total_files=$(find . -type f -name '*.scala' -printf '.' | wc -c)
echo "发现 ${total_files} 个.scala文件需要同步"

echo "开始同步到 $DEST_ROOT ..."

# 使用rsync结合进度条
find . -type f -name '*.scala' -print0 |
pv -0 -l -s "$total_files" -N "同步进度" |
rsync -av0 --files-from=- --from0 . "$DEST_ROOT/" 

echo "同步完成！目标目录：$DEST_ROOT"




#!/bin/bash
# set -eo pipefail

# CYDIR=$(git rev-parse --show-toplevel)
# FIRESIM_PATH=${CYDIR}/../firesim

# declare -A DIR_MAP=(
#     # ["${CYDIR}/generators/boom"]="${FIRESIM_PATH}/target-design/chipyard/generators/boom"
#     # ["${CYDIR}/generators/gemmini"]="${FIRESIM_PATH}/target-design/chipyard/generators/gemmini"
#     ["${CYDIR}/generators/rocket-chip"]="${FIRESIM_PATH}/target-design/chipyard/generators/rocket-chip"
#     # ["${CYDIR}/generators/firechip"]="${FIRESIM_PATH}/target-design/chipyard/generators/firechip"
#     ["${CYDIR}/generators/chipyard"]="${FIRESIM_PATH}/target-design/chipyard/generators/chipyard"
#     # ["${CYDIR}/sims/firesim/sim/firesim-lib"]="${FIRESIM_PATH}/sim/firesim-lib"
# )

# while [[ $# -gt 0 ]]; do
#     case "$1" in
#         --firesim)
#             [[ -z $2 ]] && { echo "Error: --firesim requires a path"; exit 1; }
#             FIRESIM_PATH=$(realpath "$2")
#             # 更新目录映射
#             DIR_MAP=(
#                 ["${CYDIR}/generators/boom"]="${FIRESIM_PATH}/target-design/chipyard/generators/boom"
#                 ["${CYDIR}/generators/gemmini"]="${FIRESIM_PATH}/target-design/chipyard/generators/gemmini"
#                 ["${CYDIR}/generators/rocket-chip"]="${FIRESIM_PATH}/target-design/chipyard/generators/rocket-chip"
#                 ["${CYDIR}/generators/firechip"]="${FIRESIM_PATH}/target-design/chipyard/generators/firechip"
#                 ["${CYDIR}/generators/chipyard"]="${FIRESIM_PATH}/target-design/chipyard/generators/chipyard"
#                 ["${CYDIR}/sims/firesim/sim/firesim-lib"]="${FIRESIM_PATH}/sim/firesim-lib"
#             )
#             shift 2
#             ;;
#         *) 
#             echo "Invalid option: $1" >&2
#             exit 1
#             ;;
#     esac
# done

# # 遍历所有目录映射
# for source_dir in "${!DIR_MAP[@]}"; do
#     dest_dir="${DIR_MAP[$source_dir]}"
    
#     echo "Processing directory pair:"
#     echo "  Source: $source_dir"
#     echo "  Target: $dest_dir"

#     [[ -d "$source_dir" ]] || { echo "Source directory missing: $source_dir"; exit 1; }
#     mkdir -p "$dest_dir"

#     # Phase 1: Clean existing scala files
#     echo "Cleaning existing .scala files in target..."
#     find "$dest_dir" -type f -name '*.scala' -print0 | 
#     pv -0 -l -N "Deletion progress" |
#     xargs -0 -I {} rm -v "{}"

#     # Phase 2: Sync new files
#     echo "Scanning .scala files in source..."
#     cd "$source_dir"

#     total_files=$(find . -type f -name '*.scala' -printf '.' | wc -c)
#     echo "Found ${total_files} .scala files to sync"

#     echo "Starting sync to $dest_dir ..."
#     find . -type f -name '*.scala' -print0 |
#     pv -0 -l -s "$total_files" -N "Sync progress" |
#     rsync -av0 --files-from=- --from0 . "$dest_dir/"

#     echo "Sync completed for: $source_dir -> $dest_dir"
#     echo "--------------------------------------------------"
# done

# echo "All directory pairs processed successfully!"
