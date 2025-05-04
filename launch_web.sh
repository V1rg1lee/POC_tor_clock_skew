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

echo "Starting server in background (logs at server.log) ..."
python3 server.py > server.log 2>&1 &
SERVER_PID=$!

echo
read -p "Do you want to run the client now? [y/N]: " run_client
run_client=${run_client,,}
if [[ "$run_client" == "y" || "$run_client" == "yes" ]]; then
  echo "Running client..."
  python3 client.py
else
  echo "Client not started. To run it later, use: python3 client.py"
fi

cleanup() {
  echo
  echo "Stopping server (PID $SERVER_PID)..."
  kill "$SERVER_PID" 2>/dev/null || true
  exit
}
trap cleanup SIGINT SIGTERM EXIT

echo
echo "Server is running with PID $SERVER_PID. Press Ctrl+C to stop."
wait "$SERVER_PID"
