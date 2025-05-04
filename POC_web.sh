#!/usr/bin/env bash
set -euo pipefail

read -p "ONION (e.g., abc123.onion): " ONION
read -p "AUTH_TOKEN (e.g., test): " AUTH_TOKEN

echo "1) Testing direct HTTP access to localhost:8443 (no Tor)..."
code=$(curl --silent --connect-timeout 5 \
      --output /dev/null --write-out "%{http_code}" http://127.0.0.1:8443/admin/data) || echo 000

case "$code" in
  000|401|403)
    echo "✓ direct HTTP blocked or unauthorized (code $code)"
    ;;
  200)
    echo "✗ direct HTTP returned 200; it should not be reachable without Tor"
    ;;
  *)
    echo "⚠ unexpected response code: '$raw' normalized to '$code'"
    ;;
esac

echo "2) Testing raw DNS/TCP to .onion without Tor (should fail)..."
if curl --connect-timeout 5 -s -o /dev/null http://$ONION/admin/data; then
  echo "✗ .onion responded without Tor!"
else
  echo "✓ no response without Tor"
fi

echo
echo "3) Testing .onion via Tor **without** Authorization header (should 401)..."
if curl --socks5-hostname 127.0.0.1:9050 -s -o /dev/null -w "%{http_code}" http://$ONION/admin/data | grep -q '^401$'; then
  echo "✓ 401 Unauthorized as expected"
else
  echo "✗ expected 401, got $(curl --socks5-hostname 127.0.0.1:9050 -s -o /dev/null -w '%{http_code}' http://$ONION/admin/data)"
fi

echo
echo "4) Testing .onion via Tor **with** correct token (should 200)..."
if curl --socks5-hostname 127.0.0.1:9050 \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -s -o /dev/null -w "%{http_code}" \
        http://$ONION/admin/data | grep -q '^200$'; then
  echo "✓ 200 OK"
else
  echo "✗ expected 200, got $(curl --socks5-hostname 127.0.0.1:9050 -s -o /dev/null -w '%{http_code}' http://$ONION/admin/data)"
fi

echo
echo "5) Port-scan localhost:8443 from this host (should show closed to external)..."
if nmap -p 8443 127.0.0.1 | grep -q '8443/tcp open'; then
  echo "✗ port 8443 is open locally"
else
  echo "✓ port 8443 not open to the network"
fi

echo
echo "All tests executed. Interpret their pass/fail results in the context above."
