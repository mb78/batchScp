batchScp
========
download file on a remote host in more connections

Usage: ./batchScp.sh remote-host:really-big-file-or-slow-link

* it'll start 10 ssh sessions, each downloading own part of stream
* MD5 checks ensures you're warned when anything goes bad
