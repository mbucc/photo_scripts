#! /bin/sh -e
# Extract date from jpg's exif data.  Filename on stdin.
#
#	/exifdate.sh t.jpg
#
TAGS="
DateTime
DateTimeOriginal
"

[ "x$1" = "x" ] && echo "usage: $(basename $0) <file.jpg>" >&2 && exit 1

f=$1

DT=""
for t in $TAGS; do
	if exif -m -t "$t" $f 1>/dev/null 2>/dev/null ; then
		DT=$(exif -m -t "$t" $f)
		break
	fi
done
if [ "x$DT" = "x" ] ; then 
	echo "$(basename $0): no exif date found in $f" >&2
	exit 1
else
	echo "$DT"
fi
