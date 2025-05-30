#!/usr/bin/env bash
set -euo pipefail

mkdir -p pcaps

sudo tcpdump -i lo -w pcaps/onion_raw.pcap -s0 'tcp port 9050' &
PID_ONION=$!

NUMBER_OF_REQUESTS=30

for i in $(seq 1 $NUMBER_OF_REQUESTS); do
  curl --http1.0 -s --socks5-hostname 127.0.0.1:9050 \
    http://4ajnxbwjhmynemxrd2md76wsx6zsowrsql7ywbko2msry64pjp5slzqd.onion/ >/dev/null
  echo -ne "\rRequest $i/$NUMBER_OF_REQUESTS sent"
  sleep 2
done

sudo kill -INT $PID_ONION
tcpdump -r pcaps/onion_raw.pcap -w pcaps/onion.pcap 'tcp[tcpflags] & tcp-syn != 0'
