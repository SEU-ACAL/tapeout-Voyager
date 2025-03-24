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
    ".github/workflows/github_actions.yml" \
    ".pre-commit-proof" \
    ".pre-commit-config.yaml" \
    "README.md" \
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

# 生成校验凭证
if [[ $has_error -eq 0 ]]; then
    current_sha=$(git rev-parse --verify HEAD 2>/dev/null || echo "unstaged")
    echo "$current_sha" > .pre-commit-proof
    git add .pre-commit-proof
fi

if [[ $has_error -ne 0 ]]; then
    exit 1
fi

exit 0
