#!/usr/bin/python3

import re
import sys
import json


def separator(s: str) -> bool:
    return s == "-------------------------------------------------------------------\n"

def split(s: str) -> [str, str]:
    key, sep, val = s.rstrip().partition(": ")
    assert sep == ": "
    return key, val

data = sys.stdin.readlines()

header = True
block = {}
blocks = []
for line in data:
    if header:
        if separator(line):
            header = False
        continue
    if separator(line):
       if len(block) != 0:
           blocks.append(block)
       block = {}
       continue
    item, value = split(line)
    block[item] = value

print(json.dumps(blocks))




