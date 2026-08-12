#!/usr/bin/env python3
"""XOR-encode a string for Alamofire AppConfiguration / APIConfig fragments."""
import sys
_K = [0xA7, 0x3E, 0x91, 0x5C, 0xD2]

def encode(s: str):
    return [b ^ _K[i % len(_K)] for i, b in enumerate(s.encode())]

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("usage: encode-string.py <plaintext>", file=sys.stderr)
        sys.exit(1)
    arr = encode(sys.argv[1])
    print("[" + ", ".join(str(x) for x in arr) + "]")
