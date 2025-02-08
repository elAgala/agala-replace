#!/bin/sh
set -e

# Disable command logging
set +x

# Verify required environment variables
if [ -z "$OP_CONNECT_TOKEN" ]; then
  echo "Error: OP_CONNECT_TOKEN is required" >&2
  exit 1
fi

if [ -z "$OP_CONNECT_HOST" ]; then
  echo "Error: OP_CONNECT_HOST is required" >&2
  exit 1
fi

# Process each environment variable starting with OP_SECRET_
for secret_var in $(printenv | grep '^OP_SECRET_' | cut -d= -f1); do
  op_path="$(printenv "$secret_var")"

  echo "Fetching secret from 1Password..." >&2

  # Fetch the secret value from 1Password (suppress output)
  if ! secret_value=$(op read -n "op://$op_path" 2>/dev/null); then
    echo "Failed to fetch secret from path: $op_path" >&2
    exit 1
  fi

  # Store the secret value (without logging)
  export "$secret_var"="$secret_value"

  # Clear the variable containing the secret
  unset secret_value

  echo "✓ Secret [ $secret_var ] stored successfully" >&2
done

# If we're just fetching secrets, exit after clearing sensitive environment variables
if [ $# -eq 0 ]; then
  # Clear sensitive connection information
  unset OP_CONNECT_TOKEN
  unset OP_CONNECT_HOST
  exit 0
fi

# Execute the passed command with cleaned environment
exec "$@"
