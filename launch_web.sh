#!/usr/bin/env bash
set -euo pipefail

dir="web"
if [ ! -d "$dir" ]; then
  echo "Error: 'web/' directory not found. Run this script from the project root." >&2
  exit 1
fi

env_file="$dir/.env"
if [ -f "$env_file" ]; then
  read -p "A .env file already exists. Do you want to keep the current configuration? [y/N]: " keep
  keep=${keep,,}
  if [[ "$keep" == "y" || "$keep" == "yes" ]]; then
    echo "Keeping existing .env."
    overwrite=false
  else
    overwrite=true
  fi
else
  overwrite=true
fi

after_config_action=""
if [ "$overwrite" = true ]; then
  read -p "ONION_URL (e.g., abc123.onion): " ONION_URL
  read -p "AUTH_TOKEN (e.g., test): " AUTH_TOKEN
  read -s -p "TOR_PASSWORD (ControlPort password): " TOR_PASSWORD
  echo
  echo "Writing new configuration to $env_file"
  cat > "$env_file" <<EOF
ONION_URL=${ONION_URL}
AUTH_TOKEN=${AUTH_TOKEN}
TOR_PASSWORD=${TOR_PASSWORD}
EOF
else
  echo "Using existing .env."
fi

cd "$dir"

echo "Starting server..."
python3 server.py