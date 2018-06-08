#!/usr/bin/env python

import os
import sys
import json
import subprocess

if len(sys.argv) < 2:
    print "Usage: %s volumename | volumeinfo_file " % sys.argv[0]
    sys.exit(1)

volumeinfo = sys.argv[1]

if not os.path.exists(volumeinfo):

    volumename = sys.argv[1]
    output = subprocess.check_output( [
            "maprcli", "dump", "volumeinfo", "-volumename", volumename, '-json'
        ] )
    jsonout = json.loads(output)
else:
    with open(volumeinfo) as json_data:
        jsonout = json.load(json_data)

if 'data' not in jsonout:
    print volumeinfo, jsonout['status']

else:

    print "VolumeName: %s, Replication: %s, Min: %s, NameSpaceReplication: %s, Min: %s" % \
        ( jsonout['data'][0]['VolumeName'],
          jsonout['data'][0]['VolumeReplication'],
          jsonout['data'][0]['VolumeMinReplication'],
          jsonout['data'][0]['NameSpaceReplication'],
          jsonout['data'][0]['NameSpaceMinReplication'],
        )

    factor = jsonout['data'][0]['VolumeReplication']

    for containerInfo in jsonout['data'][1:]:

        if containerInfo["NameContainer"] == 'true':
            factor = jsonout['data'][0]['NameSpaceReplication']

        print "ContainerId:%-6d Epoch:%-3d Size:%-9s nameContainer:%5s" % (containerInfo["ContainerId"], \
            containerInfo["Epoch"], containerInfo["TotalSizeMB"],containerInfo["NameContainer"]),

        allok = True
        for serverType in ["ActiveServers", "InactiveServers", "UnusedServers"]:

            key = ""
            num = 0

            if 'IP:Port' in containerInfo[serverType]:
                key = 'IP:Port'
            elif 'IP' in containerInfo[serverType]:
                key = 'IP'

            if key == "": 
                print "%s:%d" % (serverType, 0),
                continue

            ipports = containerInfo[serverType][key]
            if not isinstance(containerInfo[serverType][key], list):
                # ipports is a string when replication factor is 1, or when there is only one ip-port
                # here we change make sure ipports is a list
                ipports = [ ipports ]

            num = len(ipports)
            print "%s:%d" % (serverType, num),

            if (serverType == 'ActiveServers' and num == factor) or \
                (serverType == 'InactiveServers' and num == 0) or \
                (serverType == 'UnusedServers' and num == 0):
                allok = True and allok
            else:
                allok = False
                for item in ipports:
                    print item,

        if allok: 
            print 'ALLOK'
        else:
            print

