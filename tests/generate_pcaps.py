#!/usr/bin/env python3
"""
Generate test pcaps for the detection pipeline.

We commit the generator (readable, reviewable, diffable) rather than only the
binary pcaps, so anyone can see exactly what traffic each fixture represents.
Running this script (re)creates the pcaps under tests/pcaps/.

Each pcap contains a minimal but complete TCP session (SYN, SYN-ACK, ACK, data)
so that Suricata treats the flow as 'established', which our rule requires.
"""
from scapy.all import Ether, IP, TCP, Raw, wrpcap

CLIENT = "10.0.0.10"
SERVER = "203.0.113.50"
SPORT = 44321
DPORT = 80


def session(payload: str):
    """Return a list of packets forming one established TCP session carrying payload."""
    # 3-way handshake
    syn     = Ether()/IP(src=CLIENT, dst=SERVER)/TCP(sport=SPORT, dport=DPORT, flags="S",  seq=1000)
    synack  = Ether()/IP(src=SERVER, dst=CLIENT)/TCP(sport=DPORT, dport=SPORT, flags="SA", seq=5000, ack=1001)
    ack     = Ether()/IP(src=CLIENT, dst=SERVER)/TCP(sport=SPORT, dport=DPORT, flags="A",  seq=1001, ack=5001)
    # data from client -> server
    data    = Ether()/IP(src=CLIENT, dst=SERVER)/TCP(sport=SPORT, dport=DPORT, flags="PA", seq=1001, ack=5001)/Raw(load=payload)
    return [syn, synack, ack, data]


# Malicious: payload contains the marker our rule looks for -> SHOULD alert.
wrpcap("tests/pcaps/malicious.pcap",
       session("GET /login HTTP/1.1\r\nHost: example.com\r\nX-Data: EVILMARKER\r\n\r\n"))

# Benign: normal-looking traffic, no marker -> SHOULD NOT alert.
wrpcap("tests/pcaps/benign.pcap",
       session("GET /index.html HTTP/1.1\r\nHost: example.com\r\nUser-Agent: Mozilla/5.0\r\n\r\n"))

print("wrote tests/pcaps/malicious.pcap and tests/pcaps/benign.pcap")
