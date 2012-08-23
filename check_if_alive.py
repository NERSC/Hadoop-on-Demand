#! /usr/bin/env python
# -*- coding: utf-8 -*-

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Written (W) 2012 Seung-Jin Sul
# Copyright (C) 2012 NERSC, LBL

"""


"""

import os
import sys
import time


def _VmB(VmKey, pid):
    """
    get various mem usage properties of process with id pid in MB
    """

    _proc_status = '/proc/%d/status' % pid

    _scale = {'kB': 1.0/1024.0, 'mB': 1.0,
              'KB': 1.0/1024.0, 'MB': 1.0}

     # get pseudo file  /proc/<pid>/status
    try:
        t = open(_proc_status)
        v = t.read()
        t.close()
    except:
        return 0.0  # non-Linux?
     # get VmKey line e.g. 'VmRSS:  9999  kB\n ...'
    i = v.index(VmKey)
    v = v[i:].split(None, 3)  # whitespace
    if len(v) < 3:
        return 0.0  # invalid format?
     # convert Vm value to bytes
    return float(v[1]) * _scale[v[2]]


def get_memory_usage(pid):
    """
    return memory usage in Mb.
    """

    return _VmB('VmSize:', pid)


def get_cpu_load(pid):
    """
    return cpu usage of process
    """

    command = "ps h -o pcpu -p %d" % (pid)

    try:
        ps_pseudofile = os.popen(command)
        info = ps_pseudofile.read()
        ps_pseudofile.close()

        cpu_load = float(info.strip())
    except Exception, detail:
        #print "getting cpu info failed:", detail
        cpu_load = float(0) 
        #cpu_load = "non-linux?"

    return cpu_load


def get_runtime(pid):
    """
    get the total runtime in sec with pid.
    """

    _proc_stat = '/proc/%d/stat' % pid

    try:
        _proc_stat_f = os.popen('grep btime /proc/stat | cut -d " " -f 2')
        boottime = _proc_stat_f.read()
        _proc_stat_f.close()
        boottime = int(boottime.strip())

        _sec_since_boot_f = os.popen('cat /proc/%d/stat | cut -d " " -f 22' % (pid))
        sec_since_boot = _sec_since_boot_f.read()
        _sec_since_boot_f.close()
        sec_since_boot = int(sec_since_boot.strip())
        p_seconds_since_boot = sec_since_boot / 100

        p_starttime = boottime + p_seconds_since_boot
        now = time.time()

        p_runtime = int(now - p_starttime) # unit in seconds will be enough

    except Exception, detail:
        print "getting runtime failed: ", detail
        boottime = "non-linux?"

    return p_runtime


def main(argv):
    cpu_thresh = float(argv[2])
    cpu_load = 0.0
    cpu_load = get_cpu_load(int(argv[1]))
    print cpu_load
    if (cpu_load > cpu_thresh):
        print "alive"
        return 1 
    else:
        print "seems like dead. check again"
        time.sleep(300)
        cpu_load = get_cpu_load(int(argv[1]))
        if (cpu_load < cpu_thresh):
            print "dead confirmed"
            return 0 

if __name__ == "__main__":
    main(sys.argv)


