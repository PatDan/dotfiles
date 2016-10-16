#!/bin/python

import sys
import json

l=sys.argv
del l[0]
l = str(l)[4:-4]
l = l.split("},{")


for s in l:
    JSON = json.loads("{" + s + "}")
#   print("$ " + str(json.loads(s)["focused"]))
    if str(JSON["focused"]) == "True":
        print("")
    else:
        print("")

#print('Argument List:', str(sys.argv))
