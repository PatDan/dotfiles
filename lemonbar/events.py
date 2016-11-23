#!/usr/bin/env python3

import time
import i3ipc
from os import environ

def write_fifo(msg):
    fifo = open('/tmp/panel_fifo','w')
    fifo.write("{:s}\n".format(msg))
    fifo.close()

def on_mode_event(i3, e):
    write_fifo("MODE\t{:s}".format(e.change))

def update_workspaces(i3):
    out = {'mainbar': "Workspaces "}
    """
    WSP id,visible,focus,urgent
    """

    i = 0
    for wp in i3.get_workspaces():
        for x in range(0, wp.num-i-1):
            out['mainbar'] += ("%{F#888888}%{F#FFFFFF} ")
        i = wp.num
        if(wp.urgent == 1 ):
            out['mainbar'] += "%{F#da866d}%{F#FFFFFF} "
            continue
        if(wp.visible == 1 ):
            out['mainbar'] += " "
            continue
        out['mainbar'] += " "

    write_fifo(out['mainbar'])


def on_workspace_focus(i3, e):
    update_workspaces(i3)

def on_workspace_init(i3, e):
    update_workspaces(i3)

def on_workspace_urgent(i3, e):
    update_workspaces(i3)

time.sleep(1)
i3 = i3ipc.Connection()
i3.on('mode', on_mode_event)
i3.on('workspace::focus', on_workspace_focus)
i3.on('workspace::init', on_workspace_init)
i3.on('workspace::urgent', on_workspace_urgent)
i3.main()
