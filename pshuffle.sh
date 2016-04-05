#! /bin/sh -e
# Shuffle photo files based on the "Image timestamp" EXIF value.

usage="$(basename $0) <directory>"

[ "x$1" = "x" ] && echo $usage 1>&2 && exit 1

DIR=$1

#
#	Process photos under directory one-by-one.
#

n=0
printf "reshuffling photos based on Exif date "
for f in $(find . -type f | grep -Ei '(\.jpg$|\.jpeg$)') ; do
	printf "."
	n=$((n + 1))

	#
	#	Follow exiv2's lead: try Exif.Photo.DateTimeOriginal
	#	and if not found, try Exif.Image.DateTime.
	#

	set +e
	LINE=$(exiv2 -P E $f | grep "^Exif.Photo.DateTimeOriginal")
	[ "x$LINE" = "x" ] && LINE=$(exiv2 -P E $f | grep "^Exif.Image.DateTime")
	set -e

	#
	#	If neither Exif tag is found, put in no_exif_date folder.
	#

	if [ "x$LINE" = "x" ]  ; then
		newf=$DIR/no_exif_date/$(basename $f)
		dirnm=$(dirname $newf)
		if [ "$f" != "$newf" ] ; then
			[ ! -d $DIR/no_exif_date ] && mkdir $DIR/no_exif_date
			printf "\n"
			echo mv -v $f $newf
		fi
		continue
	fi

	#
	#	Guess at original file name.
	#

	if echo $(basename $f) | grep -E "(0[1-9]|1[0-9]|2[0-9]|3[01])-[^\.]+.jpe?g" >/dev/null
	then
		origf=$(echo $(basename $f) | cut -d '-' -f 2)
	else
		origf=$(basename $f)
	fi

	#
	#	Parse datetime.  Format is "1980:01:01 00:00:11"
	#

	DT=$(echo "$LINE" | awk '{print $4, $5}')
	Y=$(echo $DT | cut -d : -f 1)
	M=$(echo $DT | cut -d : -f 2)
	D=$(echo $DT | cut -d ' ' -f 1 | cut -d : -f 3)

	newf=$(printf "%s/%s_%s/%s-%s" $DIR $Y $M $D $origf)
	dirnm=$(dirname $newf)

	if [ "$f" != "$newf" ] ; then
		[ ! -d $dirnm ] && mkdir -p $dirnm
		printf "\n"
		mv -v $f $newf
	fi
done
printf " processed $n photos\n"

