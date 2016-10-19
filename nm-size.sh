#/bin/sh

CSV=${1%%\.*}.csv

echo "FILENAME,SIZE,ARCH" > $CSV

echo -e "FILENAME\tSIZE\tARCH"

IFS=$'\n'

for LN in `nm -U -n -t d $1`
do
	LIBNAME=${LN%%\(*}
	if [[ "$LIBNAME" = "$1" ]]; then
		if [[ $NAME ]]; then
			echo "$NAME,$SIZE,$ARCH" >> $CSV
			echo -e "$NAME\t$SIZE\t$ARCH"
		fi
		NAME=${LN#*\(}
		NAME=${NAME%%\)*}
		ARCH=${LN##*\(}
		ARCH=${LN##*\ }
		ARCH=${ARCH%%\)*}
	else
		SIZE=${LN%%\ *}
		SIZE=${SIZE#0}
	fi
done
