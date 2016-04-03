#! /bin/sh -e
# Shuffle photo files based on the "Image timestamp" EXIF value.

usage="$(basename $0) <directory>"

[ "x$1" = "x" ] && echo $usage 1>&2 && exit 1

DIR=$1

#
#	Get list of photo files.
#

find $DIR -type f | grep -Ei '(\.jpg$|\.jpeg$|\.png$|\.tiff$)'

#for f in $(find $DIR -type f | grep -e '(\.jpg$|\.jpeg$)') ; do
#	echo $f
#done
