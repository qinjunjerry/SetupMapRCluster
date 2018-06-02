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

        print "ContainerId:%d Epoch:%d Size:%s nameContainer:%s" % (containerInfo["ContainerId"], containerInfo["Epoch"], containerInfo["TotalSizeMB"],containerInfo["NameContainer"]),

        allok = True
        for serverType in ["ActiveServers", "InactiveServers", "UnusedServers"]:

            if 'IP:Port' in containerInfo[serverType]:
                key = 'IP:Port'
                num = len(containerInfo[serverType][key])
            elif 'IP' in containerInfo[serverType]:
                key = 'IP'
                num = len(containerInfo[serverType][key])
            else:
                key = ""
                num = 0

            if (serverType == 'ActiveServers' and num == factor) or \
                (serverType == 'InactiveServers' and num == 0) or \
                (serverType == 'UnusedServers' and num == 0):
                allok = True and allok
            else:
                allok = False
                print "%s:%d" % (serverType, num),

                if key != "":
                    for item in containerInfo[serverType][key]:
                        print item,

        if allok: 
            print 'ALLOK'
        else:
            print

