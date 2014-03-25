batchScp
========
download file from a remote host using more connections

Usage: ./batchScp.sh remote-host:really-big-file-or-slow-link

* it'll start 10 ssh sessions (change it within the script), each downloading own part of stream
* ensure you have twice more free space as is the file size
* MD5 checks ensures you're warned when anything goes bad
