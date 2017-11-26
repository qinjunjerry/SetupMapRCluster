#!/usr/bin/env python

import sys
import subprocess

mep_version = "MEP_VERSION"
os_family   = "OS_FAMILY"

output = subprocess.check_output( [
        "curl", "-s",
        "http://package.mapr.com/releases/MEP/MEP-%s/%s/" % (mep_version, os_family)
    ] )

for line in output.splitlines():
    index1 = line.find('"mapr')
    if index1 < 0: continue

    index2 = line.find('rpm"')
    if index2 < 0: continue

    package_version = line[index1+1:index2+3]
    pvitems = package_version.split('-')

    package = '-'.join( pvitems[0:-2] )

    version = pvitems[-2]
    vitems = []
    for item in version.split("."):
        if len(item) <= 2:
            vitems.append(item)
        else:
            break
    version = ".".join(vitems)

    print "%s=%s" % (package+":version", version)
