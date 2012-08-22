#! /usr/bin/env python
# -*- coding: utf-8 -*-

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Written (W) 2012 Seung-Jin Sul
# Copyright (C) 2012 NERSC, LBL


import zmq
import socket
from pythongrid import zloads

context = zmq.Context()
zsocket = context.socket(zmq.REP)

host_name = socket.gethostname()
ip_address = socket.gethostbyname(host_name)
interface = "tcp://%s" % (ip_address)


#port = 5002
port = zsocket.bind_to_random_port(interface)
home_address = "%s:%i" % (interface, port)
print "setting up connection on", home_address

#zsocket.bind(home_address)

print "server is running on:", home_address

while True:
    msg_str = zsocket.recv()
    msg = zloads(msg_str)
    print "Got msg:", msg
    zsocket.send("OK")

