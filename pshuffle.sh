#! /bin/sh -e
# Read filename(s) on stdin and rename to use exif date.
#
# For example, if t.jpg was taken on August 22, 2016,
#
#	echo t.jpg | ./pshuffle.sh
#
# would end up moving t.jpg to 2016-08/20160822-t.jpg
#
# Usage: pshuffle [-n]
#
#	-n		dry run; echo file moves that would occur
#
#    Copyright (c) 2016, Mark Bucciarelli <mkbucc@gmail.com>
#
#    Permission to use, copy, modify, and/or distribute this software
#    for any purpose with or without fee is hereby granted, provided
#    that the above copyright notice and this permission notice appear
#    in all copies.
#
#    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
#    WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
#    WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
#    AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
#    DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
#    OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
#    TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
#    PERFORMANCE OF THIS
#    SOFTWARE.

DRYRUN=0
if [ "x$1" != "x" ]; then
	if [ "$1" = "-n" ] ; then
		DRYRUN=1
	else
		echo "usage: $(basename $0) [-n]" >&2 && exit 1
	fi
fi

while read f ; do

	# Fails if no date found.
	DT=$(./exifdate.sh $f)

	# exif dates are in the format "1980:01:01 00:00:11"
	Y=$(echo $DT | cut -d : -f 1)
	M=$(echo $DT | cut -d : -f 2)
	D=$(echo $DT | cut -d ' ' -f 1 | cut -d : -f 3)

	newf=$(printf "./%s_%s/%s%s%s-%s" $Y $M $Y $M $D $f)
	dirnm=$(dirname $newf)

	if [ "$f" != "$newf" ] ; then
		if [ $DRYRUN -eq 0 ] ; then
			[ ! -d $dirnm ] && mkdir -p $dirnm
			mv -i $f $newf
		else
			[ ! -d $dirnm ] && echo mkdir -p $dirnm
			echo mv -i $f $newf
		fi
	fi
done
