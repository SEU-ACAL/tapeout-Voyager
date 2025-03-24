
CYDIR=$(git rev-parse --show-toplevel)

# PROOF_FILE="$CYDIR/.pre-commit-proof"
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
CURRENT_COMMIT_HASH=$(git rev-parse HEAD)
CURRENT_FILE_HASH=$(git diff HEAD^ HEAD | sha256sum | cut -d ' ' -f1)
STORED_HASH=$(cat $PROOF_FILE)
STORED_COMMIT_HASH=$(echo $STORED_HASH | cut -d ':' -f1)
STORED_FILE_HASH=$(echo $STORED_HASH | cut -d ':' -f2)
if [ "$CURRENT_COMMIT_HASH" != "$STORED_COMMIT_HASH" ] || [ "$CURRENT_FILE_HASH" != "$STORED_FILE_HASH" ]; then
  echo "ACTUAL_CONTENT_HASH: $CURRENT_FILE_HASH"
  echo "EXPECTED_CONTENT_HASH: $STORED_FILE_HASH"
  echo "Error: pre-commit SHA-256 hash mismatch!"
  exit 1
fi