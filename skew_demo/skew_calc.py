#!/usr/bin/env python3

# To protect against TCP timestamp attacks, you can disable TCP timestamps:
# sudo sysctl -w net.ipv4.tcp_timestamps=0
# To enable TCP timestamps, you can use:
# sudo sysctl -w net.ipv4.tcp_timestamps=1


import dpkt, sys, numpy as np, scipy.stats as st

def skew_ppm(pcap):
    xs, ys = [], []
    for ts, buf in dpkt.pcap.Reader(open(pcap, 'rb')):
        ip = dpkt.ethernet.Ethernet(buf).data
        if not isinstance(ip, dpkt.ip.IP) or ip.p != 6:
            continue
        for k, data in dpkt.tcp.parse_opts(ip.data.opts):
            if k == 8:                        # TCP Timestamp option
                ys.append(int.from_bytes(data[:4], 'big'))
                xs.append(ts)
                break
    if len(xs) < 50:
        return None, None
    m, _, r, _, _ = st.linregress(xs, ys)
    return m * 1e6 / 2**32, r**2            # skew in ppm, R²

for pcap in sys.argv[1:]:
    skew, r2 = skew_ppm(pcap)
    if skew is None:
        print(f"{pcap}: too few TCP timestamps")
    else:
        print(f"{pcap:16} skew = {skew:8.3f} ppm   R² = {r2:.4f}")
