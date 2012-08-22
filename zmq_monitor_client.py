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
First open a shell and execute the server:

    python zmq_serv.py

It will show the connection info like:

    tcp://128.55.54.38:55072

Then open another shell and shoo

    python zmq_test.py -s <server_host_name> -p <port> -d <interval> -i <pid>

Example job script) 

#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l debug.c
#$ -l h_rt=00:10:00
#$ -l ram.c=1G
##$ -pe pe_slots 1
#$ -w e
#$ -P system.p
#$ -t 1-4

module load zeromq

/jgi/tools/bin/blastall -b 100 -v 100 -K 100 -p blastn -S 3 -d /global/scratch/sd/sulsj/eugene/BLASTDB/hs.m51.D4.diplotigs+fullDepthIsotigs.fa -e 1e-10 -F F -W 41 -i /global/scratch/sd/sulsj/eugene/makeflow-test-w-pe-slots/short.fna -m 8 -o test.bout &
PID2=$!

python ./zmq_test.py -s genepool04.nersc.gov -p 55072 -d 1 -i $PID2 &
PID=$!
 
wait $PID2 && # wait for blast job completion
kill -9 $PID  # kill msg sender

# EOF


"""

import zmq
import socket
import os
import sys
import zlib
import getopt
import cPickle
import time

def zdumps(obj):
    """
    dumps pickleable object into zlib compressed string
    """
    return zlib.compress(cPickle.dumps(obj,cPickle.HIGHEST_PROTOCOL),9)


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

        cpu_load = info.strip()
    except Exception, detail:
        print "getting cpu info failed:", detail
        cpu_load = "non-linux?"

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


def send_info(servName, servPort, sendInterval, pid):
    """
    send info to the server 
    """

    context = zmq.Context()
    zsocket = context.socket(zmq.REQ)

    port = int(servPort)
    host_name = str(servName).strip()
    ip_address = socket.gethostbyname(host_name)
    interface = "tcp://%s" % (ip_address)
    home_address = "%s:%i" % (interface, port)
    
    print "Try to connect to %s" % (home_address)
    zsocket.connect(home_address)

    while 1:
        msg_container = {}
        #msg_container["job_id"] = pid
        #msg_container["host_name"] = host_name
        #msg_container["ip_address"] = ip_address
        #msg_container["command"] = "test"
        #msg_container["data"] = None
        msg_container["client_host"] = os.uname()[1]
        msg_container["pid"] = pid
        msg_container["cpu"] = get_cpu_load(int(pid))
        msg_container["mem"] = get_memory_usage(int(pid))
        msg_container["run_time"] = get_runtime(int(pid))

        msg_string = zdumps(msg_container)

        zsocket.send(msg_string)
        ret_msg = zsocket.recv()
        print "server replied:", ret_msg

        time.sleep(int(sendInterval))


def usage():
    print "Usage: zmq_test.py -s <server> -p <port> -i <pid> -d <interval>"


def main(argv):
    """
    Parse the command line inputs and call send_info 

    @param argv: list of arguments
    @type argv: list of strings
    """

    servname = ''
    servport = ''
    pid = ''
    interval = ''

    try:
        opts, args = getopt.getopt(argv[1:],"hs:p:i:d:",["server=","port=","pid=","interval="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            usage()
            sys.exit()
        elif opt in ("-s", "--server"):
            servname = arg
        elif opt in ("-p", "--port"):
            servport = arg
        elif opt in ("-i", "--pid"):
            pid = arg
        elif opt in ("-d", "--interval"):
            interval = arg
        else:
            usage()
            sys.exit()

    send_info(servname, servport, interval, pid)


if __name__ == "__main__":
    main(sys.argv)

