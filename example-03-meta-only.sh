#! /bin/bash

# Simply prints out meta info embedded in manual TAP

. ./tapper-autoreport --import-utils

echo "1..1"
echo "ok - metainfo"
tapper_suite_meta
tapper_section_meta

# no source tapper-autoreport here -- we already printed TAP above
