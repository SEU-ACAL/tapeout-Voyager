
CYDIR=$(git rev-parse --show-toplevel)

PROOF_FILE="$CYDIR/.pre-commit-proof"

if [ ! -f "$PROOF_FILE" ]; then
  echo "Error: pre-commit proof file not found!"
  exit 1
fi

current_sha=$(git rev-parse HEAD~1)
stored_sha=$(cat $PROOF_FILE)

if [ "$current_sha" != "$stored_sha" ]; then
  echo "::error::SHA mismatch (sha1: $current_sha, sha2: $stored_sha)"
  exit 1
fi
