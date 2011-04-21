#! /bin/bash

. ./tapper-autoreport --import-utils

SUITENAME="Operation-TAP-Point"
SUITEVERSION="2.001"
OSNAME="Knoppix NG 0.5"
CHANGESET="98765"
HOSTNAME="J-F-Sebastian"
NOSEND=0

uname -a | grep -q Linux  # example for ok exit code

. ./tapper-autoreport ok $? /var/run/ntpd.pid "/tmp/foo bar"
