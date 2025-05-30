#!/usr/bin/env bash
set -euo pipefail

mkdir -p pcaps

sudo tcpdump -i lo -w pcaps/direct_raw.pcap -s0 'tcp port 8080' &
PID_DIR=$!

NUMBER_OF_REQUESTS=30

for i in $(seq 1 $NUMBER_OF_REQUESTS); do
  curl --http1.0 -s http://127.0.0.1:8080/ > /dev/null
  echo -ne "\rRequest $i/$NUMBER_OF_REQUESTS sent"
  sleep 2
done

sudo kill -INT $PID_DIR
tcpdump -r pcaps/direct_raw.pcap -w pcaps/direct.pcap 'tcp[tcpflags] & tcp-syn != 0'
