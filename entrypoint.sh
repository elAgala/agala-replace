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

if [ -z "$ENV_FILE_LOCATION" ]; then
  echo "Error: ENV_FILE_LOCATION is required" >&2
  exit 1
fi

ENV_FILE_PATH=$ENV_FILE_LOCATION/.env

if [ -f "$ENV_FILE_PATH" ]; then
  echo "✅ .env file exists at $ENV_FILE_LOCATION"
else
  echo "❌ .env file is missing!"
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

  if grep -q "{{$secret_var}}" "$ENV_FILE_PATH"; then
    sed -i "s~{{$secret_var}}~$secret_value~g" "$ENV_FILE_PATH"
    echo "✓ Secret [ $secret_var ] replaced successfully" >&2
  else
    echo "Warning: Placeholder {{$secret_var}} not found in .env file" >&2
  fi

  unset secret_value
  unset secret_var
done

# If we're just fetching secrets, exit after clearing sensitive environment variables
if [ $# -eq 0 ]; then
  # Clear sensitive connection information
  unset OP_CONNECT_TOKEN
  unset OP_CONNECT_HOST
  exit 0
fi
