#! /bin/sh -e
# Find photos files that are duplicates

usage="$(basename $0) <directory>"
[ "x$1" = "x" ] && echo "$usage" 1>&2 && exit 1

#
#	Make sure TMPDIR is defined.
#

[ "x$TMPDIR" = "x" ] && echo "TMPDIR not defined." 1>&2 && exit 1

#
#	Strip exif completely from each file.
#	(Without touching original.)
#	Calculate SHA1 sum for the stripped version
#	and associate with the original file name.
#

sumf=$(mktemp $TMPDIR/psums.XXXXXX)
rm -f $sumf
for f in $(find . -type f | grep -Ei '(\.jpg$|\.jpeg$)') ; do
	tmpf=$TMPDIR/$(basename $f)

	#
	#	Don't touch original file.
	#

	[ "$f" = "$tmpf" ] && echo "Invalid TMPDIR" 1>&2 && exit 1

	#
	#	Copy, strip and sha1.
	#

	cp $f $tmpf
	exiv2 rm $tmpf
	SHA1=$(sha1sum $f | awk '{print $1}')

	#
	#	Output tab-delimited (SHA1, filename) tuple.
	#

	printf "%s\t%s\n" $SHA1 $f >> $sumf

done

#
#	Sort sum file.
#

tmpf=$(mktemp $TMPDIR/psums.XXXXXX)
sort $sumf > $tmpf
mv $tmpf $sumf

#
#	Scan and output and rows with the same SHA1 sum.
#

LASTSHA1=""
LASTNAME=""
while read SHA1 NAME ; do
	[ "x$LASTSHA1" = "x" ] && LASTSHA1=SHA1 && LASTNAME=NAME && continue
	if [ "$LAST" = "$SHA1" ] ; then
		printf "%s\t%s\n" LASTSHA1 LASTNAME
		printf "%s\t%s\n" SHA1 NAME
	fi
done < $sumf
