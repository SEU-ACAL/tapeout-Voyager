#!/usr/bin/env bash

changed_files=$(git diff --cached --name-only --diff-filter=ACM)

allowed_dirs=( \
    # "generators/boom/src" \
    # "generators/gemmini/src" \
    # "generators/rocket-chip/src/main/scala/npu" \ 
    # "generators/rocket-chip/src/main/scala/rocket" \ 
    "generators/chipyard/src" \
    "software" \
    "documents" \
    "scripts")


allowed_alone_file=( \
    ".pre-commit-config.yaml" \
)

has_error=0

for file in $changed_files
do
    allowed=0
    for dir in "${allowed_dirs[@]}"
    do
        if [[ "$file" == "$dir"/* ]]; then
            allowed=1
            break
        fi
    done

    for alone_file in "${allowed_alone_file[@]}"
    do
        if [[ "$file" == "$alone_file" ]]; then
            allowed=1
            break
        fi
    done

    if [[ $allowed -eq 0 ]]; then
        echo "[ERROR] Commit a change in unallowed directory '$file'"
        echo "You can only change these directories: {${allowed_dirs[*]}}"
        has_error=1
    fi
done

if [[ $has_error -ne 0 ]]; then
    exit 1
fi

exit 0

#!/bin/bash

# if [ "$PRE_COMMIT_ALREADY_RUN" = "true" ]; then
#     exit 0
# fi


# # 不允许修改的目录
# PROTECTED_DIRS=( \
#     "generators/boom/src" \
#     "generators/gemmini/src" \
#     "generators/rocket-chip/src/main/scala/npu" \ 
#     "generators/rocket-chip/src/main/scala/rocket" \ 
#     # "generators/chipyard/src" \
#     # "software" \
#     # "documents" \
#     # "scripts" \
#     "generators/testchipip" \ 
#     "generators/firechip" \ 
# )

# # 获取将要提交的修改文件
# CHANGED_FILES=$(git diff --cached --name-only)

# echo "将要提交的文件:"
# echo "$CHANGED_FILES"

# echo "[修改权限检查]==========================="

# PROTECTED_MODIFIED=false
# # 检查每个修改的文件是否在受保护的目录中
# for FILE in $CHANGED_FILES; do
#     for DIR in "${PROTECTED_DIRS[@]}"; do
#         if [[ "$FILE" == $DIR/* ]]; then
#             echo "ERROR: 不允许修改目录 $DIR 中的文件。ERROR文件：$FILE。"
#             PROTECTED_MODIFIED=true
#         fi
#     done
# done

# if [[ "$PROTECTED_MODIFIED" = "true" ]]; then
#     echo "[检查修改权限未通过]====================="
#     exit 1
# fi

# echo "[检查修改权限通过]====================="
# exit 0
