#!/bin/python

import sys
import json

l = sys.argv
del l[0]
l = str(l)[4:-4]
l = l.split("},{")


i = 0
for s in l:
    JSON = json.loads("{" + s + "}")
#   print("$ " + str(json.loads(s)["focused"]))
    new = int(str(JSON["name"]))
    for x in range(0, new-i-1):
        print("%{F#888888}%{F#FFFFFF}")
    i = new
    if str(JSON["focused"]) == "True":
        print("")
    else:
        print("")

# print('Argument List:', str(sys.argv))
