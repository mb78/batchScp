#!/bin/bash

SSH_OPTIONS="-C -o CompressionLevel=9 -o BatchMode=yes -n -q -T"
LEVEL=10 # 2 and more
MIN_BLOCK_SIZE=102400
HOST=${1/:*/}
FILE=${1/*:/}
LOCAL_FILE=$(basename $FILE)
DEST_DIR=${2:-./}
[ "$HOST" -a "$FILE" ] || { echo "Invalid path '$1'" >&2; exit 1; }

SIZE=$(ssh $HOST stat --printf=%s $FILE)
MD5SUM=$(ssh $HOST md5sum $FILE | cut -d" " -f 1)
[ "$SIZE" -a "$MD5SUM" ] || { echo "File '$FILE' is missing or could not use stat/md5sum" >&2; exit 1; }

echo "Downloading $FILE long $SIZE bytes ($[$SIZE/1024/1024] MB) from $HOST in $LEVEL ssh connections, destination dir is $DEST_DIR"

[ -e "$LOCAL_FILE" -o -e "$LOCAL_FILE.0.tmp" ] && { echo "File $LOCAL_FILE or $LOCAL_FILE.0.tmp already exist, exiting" >&2; exit 1; }

BLOCK_SIZE=$[$SIZE / $[$LEVEL-1]]
[ $BLOCK_SIZE -le $MIN_BLOCK_SIZE ] && BLOCK_SIZE=$MIN_BLOCK_SIZE

OUT="$(ssh $SSH_OPTIONS $HOST echo -n)"
[ -z "$OUT" ] || { echo "Error: 'ssh $SSH_OPTIONS $HOST' returns enriched output, should be empty" >&2; exit 1; }

ITER=0
while [ $[$BLOCK_SIZE * $ITER] -lt $SIZE ]; do
	ssh $SSH_OPTIONS $HOST bash -c "'dd if=$FILE bs=$BLOCK_SIZE count=1 skip=$ITER 2>/dev/null'" >$LOCAL_FILE.$ITER.tmp &
	let ITER++
done
wait

cat $LOCAL_FILE.*.tmp >$LOCAL_FILE
rm -f $LOCAL_FILE.*.tmp
[ "$(md5sum $LOCAL_FILE | cut -d" " -f 1)" = $MD5SUM ] || { echo "Downloaded file does not match expected md5sum" >&2; exit 1; }
