#/bin/bash

#build js

WORKDIR=`pwd`
SHDIR=`dirname $0`

echo $SHDIR

exitCommand() {
	exit $1
}

runCommand() {
	echo $CMD
	$CMD
	if [ $? -ne 0 ]; then
		echo -e "[FAIL] $CMD"
		exitCommand 3
	fi 
}

if [ ! "$STATIC" ]; then
	STATIC="./static"
fi

if [ ! "$VIEW" ]; then
	VIEW="./@app"
fi

echo "STATIC:$STATIC"
echo "VIEW:$VIEW"

if [ -d "$STATIC" ]; then

  	for map in `find $STATIC -name "*.js.map"`; do

		echo "build $map ..."

		dir=${map%/*}

		min=${map%.map}

		echo "" > "$min.tmp"

		for js in `cat $map`; do

			cat "$dir/$js" >> "$min.tmp"
			echo -e "\n" >> "$min.tmp"

		done

		rm "$min"

		if $DEBUG; then
			cp "$min.tmp" "$min"
		else
			CMD="java -jar $SHDIR/yuicompressor.jar --charset utf-8 --type js -o \"$min\" \"$min.tmp\""
			runCommand
		fi

		rm -f "$min.tmp"

		echo "build $map to $min"

	done

fi

#biuld css

if [ -d "$STATIC" ]; then

	for map in `find $STATIC -name "*.css.map"`; do

		echo "build $map ..."

		dir=${map%/*}

		min=${map%.map}

		echo "" > "$min.tmp"

		for js in `cat $map`; do

			cat "$dir/$js" >> "$min.tmp"
			echo -e "\n" >> "$min.tmp"

		done

		rm "$min"

		if $DEBUG; then
			cp "$min.tmp" "$min"
		else
			CMD="java -jar $SHDIR/yuicompressor.jar --charset utf-8 --type css -o \"$min\" \"$min.tmp\""
			runCommand
		fi

		rm -f "$min.tmp"
		
		echo "build $map to $min"
		
	done

fi

#build html

if [ -d "$VIEW" ]; then

	for map in `find $VIEW -name "*.view.html"`; do

		echo "build $map ..."

		rm -f "${map%.view.html}.html"
		
		CMD="$SHDIR/view.py -home $VIEW -o ${map%.view.html}.html -i $map"
		runCommand

		echo "build $map to ${map%.view.html}.html"
		
	done

	for map in `find $VIEW -name "*.view.htm"`; do

		echo "build $map ..."

		rm -f "${map%.view.htm}.htm"
		
		CMD="$SHDIR/view.py -home $VIEW -o ${map%.view.htm}.htm -i $map"
		runCommand

		echo "build $map to ${map%.view.htm}.htm"
		
	done

fi

