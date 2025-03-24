
CYDIR=$(git rev-parse --show-toplevel)

PROOF_FILE="$CYDIR/.pre-commit-proof"
# if [ ! -f "$PROOF_FILE" ]; then
#   echo "Error: pre-commit proof file not found!"
#   exit 1
# fi
# COMMIT_HASH=$(git rev-parse HEAD)
# ACTUAL_CONTENT_HASH=$(git show $COMMIT_HASH --pretty=format:%b | grep -v "diff --git a/.pre-commit-proof" | sha256sum | cut -d ' ' -f1)
# EXPECTED_CONTENT_HASH=$(cat $PROOF_FILE)
# if [ "$ACTUAL_CONTENT_HASH" != "$EXPECTED_CONTENT_HASH" ]; then
#   echo "ACTUAL_CONTENT_HASH: $ACTUAL_CONTENT_HASH"
#   echo "EXPECTED_CONTENT_HASH: $EXPECTED_CONTENT_HASH"
#   echo "Error: file content hash mismatch, maybe local pre-commit not run or content modified!"
#   exit 1
# fi
if [ ! -f "$PROOF_FILE" ]; then
  echo "Error: pre-commit proof file not found!"
  exit 1
fi

current_sha=$(git rev-parse HEAD)
stored_sha=$(cat $PROOF_FILE)

if [ "$current_sha" != "$stored_sha" ]; then
  echo "::error::SHA mismatch (sha1: $current_sha, sha2: $stored_sha)"
  exit 1
fi

# CURRENT_COMMIT_HASH=$(git rev-parse HEAD)
# CURRENT_FILE_HASH=$(git diff HEAD^ HEAD | sha256sum | cut -d ' ' -f1)
# echo "CURRENT_COMMIT_HASH: $CURRENT_COMMIT_HASH"
# echo "ACTUAL_CONTENT_HASH: $CURRENT_FILE_HASH"
# STORED_HASH=$(cat $PROOF_FILE)
# STORED_COMMIT_HASH=$(echo $STORED_HASH | cut -d ':' -f1)
# STORED_FILE_HASH=$(echo $STORED_HASH | cut -d ':' -f2)
# echo "STORED_HASH: $STORED_HASH"
# echo "STORED_COMMIT_HASH: $STORED_COMMIT_HASH"
# echo "STORED_FILE_HASH: $STORED_FILE_HASH"
# if [ "$CURRENT_COMMIT_HASH" != "$STORED_COMMIT_HASH" ] || [ "$CURRENT_FILE_HASH" != "$STORED_FILE_HASH" ]; then
#   echo "Error: pre-commit SHA-256 hash mismatch!"
#   exit 1
# fi