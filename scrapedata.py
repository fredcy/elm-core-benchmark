#!/usr/bin/env python2.7

import re
import sys

def scrape(input):
    print "\t".join(["size", "name", "opspersec", "elmtspersec"])
    
    for line in input:
        m = re.search(r'Starting size (\d+) suite', line)
        if m:
            #print "suite", m.group(1)
            size = int(m.group(1))

        m = re.search(r'([a-z][a-z ]*) x ([\d,.]+) ops/sec', line)
        if m:
            name = m.group(1)
            opspersecString = m.group(2)
            #print "data", name, opspersecString
            opspersec = float(opspersecString.replace(',', ''))
            elmtspersec = opspersec * size
            print "\t".join([str(f) for f in[size, name, opspersec, elmtspersec]])


if __name__ == "__main__":
    scrape(sys.stdin)
    
