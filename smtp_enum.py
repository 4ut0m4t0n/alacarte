#!/usr/bin/python

import socket
import sys

targetIP = sys.argv[1]
f = sys.argv[2]

sock=socket.socket(socket.AF_INET, socket.SOCK_STREAM)

connect=sock.connect((targetIP,25))

banner = sock.recv(1024)
print "Server Banner:"
print banner

#check if user exists on SMTP server
f = open(f, 'r')
for line in f:
	print "VRFY " + line,
	sock.send('VRFY ' + line.strip() + '\r\n')
	result=sock.recv(1024)
	print result

f.close()
sock.close()
