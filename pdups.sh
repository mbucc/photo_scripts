#! /bin/sh -e
# Find duplicate photos.

usage="$(basename $0) <directory>"
[ "x$1" = "x" ] && echo "$usage" 1>&2 && exit 1

#
#	Make sure TMPDIR is defined.
#

[ "x$TMPDIR" = "x" ] && echo "TMPDIR not defined." 1>&2 && exit 1

#
#	Strip exif completely from each file.
#	(Without touching original.)
#	Calculate hash for the stripped version
#	and associate with the original file name.
#

sumf=$(mktemp $TMPDIR/psums.XXXXXX)
rm -f $sumf
n=0
printf "hashing photos ..."
for f in $(find . -type f | grep -Ei '(\.jpg$|\.jpeg$)') ; do
	n=$((n + 1))
	printf "."
	tmpf=$TMPDIR/$(basename $f)

	#
	#	Don't touch original file.
	#

	[ "$f" = "$tmpf" ] && echo "Invalid TMPDIR" 1>&2 && exit 1

	#
	#	Copy, strip EXIF and hash.
	#	I tried md5 to see if it was faster and there was no big win.
	#

	cp $f $tmpf
	exiv2 rm $tmpf
	hash=$(sha1sum $f | cut -c -40)
	rm $tmpf

	#
	#	Output tab-delimited (hash, filename) tuple.
	#

	printf "%s\t%s\n" $hash $f >> $sumf

done
printf " %d hashed.\n" $n

#
#	Sort sum file.
#

tmpf=$(mktemp $TMPDIR/psums.XXXXXX)
sort $sumf > $tmpf
mv $tmpf $sumf

#
#	Output and rows with the same hash.
#

cat $sumf | awk '{print $1}' | sort | uniq -c | grep -v '^ \+1 ' |
while read count hash; do
	grep "^$hash	" $sumf
	printf "\n"
done

rm $sumf
