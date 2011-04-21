# tapper-autoreport

## ABOUT

This is the `tapper-autoreport` bash utility -- a bash include file
that you include ("source") at the end of your own bash script.

It then magically turns your bash script into a Tapper test suite.

It collects meta information from system, reports test results via
network and uploads files.

It also allows your bash script to be used with the `prove` command,
a tool to run test scripts that produce TAP output (Test Anything
Protocol).

## SYNOPSIS

### most simple usage

* script:

```bash
#! /bin/bash
# your own stuff here ...
. /tapper-autoreport
```

* explanation:

    * TAP
    * filename gets name
    * run itself is already a success
    * meta information
    * report grouping heuristics
    * self-report to Tapper
    * upload files
    * print out Tapper report URL

### using environment variables and params

* script:

```bash
#! /bin/bash
append_tap "ok - affe loewe tiger"
append_tap "ok - some other description"
append_tap "not ok - yet another test description"
append_tapdata "timecpb: 12.345"
append_tapdata "timenocpb: 23.456"
SUITENAME="CPUID-ON"
SUITEVERSION="2.007"
OSNAME="Gentoo 10.1"
CHANGESET="98765"
HOSTNAME="J-F-Sebastian"
TICKETURL='https://osrc.amd.com/bugs/show_bug.cgi?id=901'
WIKIURL=https://osrc.amd.com/wiki/Pharaoh_hound_c-state_boost_evaluation
PLANNINGID=osrc.hv.xen.multicore
TAPPER_REPORT_SERVER="tapper-devel"
NOSEND=1
uname -a | grep -q Linux  # example for exit code
. /tapper-autoreport nok /tmp/results.log $?
```

* explanation:

    * define additional TAP lines
    * define additional YAML data lines
    * overwrite suite name
    * overwrite suite version
    * overwrite OS name
    * overwrite changeset, usually kernel
    * overwrite hostname
    * specify relevant URL in used ticket system (like Bugzilla, RT, ...)
    * specify relevant URL in used wiki
    * specify relevant task planning id (like MS Project, TaskJuggler, ...)
    * use different report server (e.g. "tapper-devel" for experiments)
    * set NOSEND=1 to suppress sending to reports server completely
    * param "nok" say "something was not ok"
    * param of filename /tmp/my_ow_results.txt means upload the file
    * param of integer ($? is last exit code, 0 means ok, else not ok)

### use with prove

* cmd line and output:

```bash
$ prove ./trivial-example-1.sh
./trivial-example-1.sh .. ok
All tests successful.
Files=1, Tests=5, 20 wallclock secs
Result: PASS
```

* explanation:

    * "prove" is an existing standard tool
    * it prints success statistics
    * no report sending happens
    * is meant for manual developing/testing

### use without prove

* cmd line and output:

```bash
$ ./trivial-example-1.sh
# http://perlformance.net/tapper/reports/id/1
# - upload ./trivial-example-1.sh ...
# - upload /boot/config-2.6.32-22-generic ...
# - upload /proc/cpuinfo ...
# - upload /proc/devices ...
# - upload /proc/version ...
```

* explanation:

    * execute script
    * report output to Tapper server
    * upload files
    * prints out Tapper report URL
    * is meant for final reporting


## INFLUENCING BEHAVIOUR

* use environment variables to provide more content
* define hooks (functions) to be called
* provide params that "Do What I Mean"
* call script with "prove" utility to test directly without upload


### Environment Variables

* `TAP[*]`                - Array of TAP lines
* `TAPDATA[*]`            - Array of YAML lines that contain data in TAP
* `HEADERS[*]`            - Array of Tapper headers
* `OUTPUT[*]`             - Array of additional output lines
* `SUITENAME`             - alternative suite name instead of $0
* `SUITEVERSION`          - alternative suite version
* `KEYWORDS`              - space separated keywords to influence suite name
* `OSNAME`                - alternative OS description
* `CHANGESET`             - alternative changeset
* `HOSTNAME`              - alternative hostname
* `TAPPER_REPORT_SERVER`  - alternative report server
* `TICKETURL`             - relevant URL in used ticket system (Bugzilla)
* `WIKIURL`               - relevant URL in used wiki
* `PLANNINGID`            - relevant task planning id (MS Project, TaskJuggler)
* `NOSEND`                - if "1" no sending to Tapper happens
* `NOUPLOAD`              - if "1" no uploading of default files happens


### Utility functions

Import utility functions at the beginning of the script via

```bash
. ./tapper-autoreport --import-utils
```

Then you have the following functions available

* `require_cpufeature "cpb"`

Checks that the string "cpb" in /proc/cpuinfo and exits in a TAP
conform way otherwise.

* `require_program "bc"`

Checks that the program "bc" is available and exits in a TAP conform
way otherwise.

* `require_root`

Checks that the user executing the script is root (UID 0).

* `ok ARG1 "some description"`

Evaluates the first argument with Shell boolean semantics (0 is true)
and appends a corresponding TAP line.

* `negate_ok ARG1 "some description"`

Evaluates the first argument with Shell inverse boolean semantics (0
is false) and appends a corresponding TAP line.

* `append_tap "ok - some description"`

Appends a complete TAP line where you have taken care for the
"`ok`"/"`not ok`" at the beginning.

* `append_tapdata "key: value"`

Appends a key:value line at the tapdata YAML block. The key must start
with letter and consist of only alphanum an underscore.

### Command Line Arguments

* --version               - print version number and exit
* nok                     - declare something was not ok
* [integer]               - exit code of a program, 0 == ok, else not (Hint: use '$?' to refer to last program)
* [filename]              - upload the file


### Function Hooks

* `main_after_hook()`

    * optional shell function to be executed at the end of autoreport's main()
    * all stdout will be part of the report


## RESULT URLS

They look like this: http://tapper/tapper/reports/id/129218

## WHAT IT REPORTS

### Tapper information

* report group
* testrun
* suite name
* suite version
* machine name
* reporter name (owner)

### System information

* uname
* OS name
* kernel version
* changeset
* kernel flags
* cpuinfo
* ram
* execution time
* bogomips

### File uploads

* itself
* /proc/cpuinfo
* /proc/devices
* /proc/version


