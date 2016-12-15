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
	VIEW=".web"
fi

echo "STATIC:$STATIC"
echo "VIEW:$VIEW"

if [ -d "$STATIC" ]; then

  	for map in `find $STATIC -name "*.js.map"`; do

		echo "build $map ..."

		DIR=${map%/*}

		min=${map%.map}

		echo "" > "$min.tmp"
		
		for js in `cat $map`; do

			cat "$DIR/$js" >> "$min.tmp"
			echo -e "\n" >> "$min.tmp"

		done

		rm -f "$min"

		if [ "$DEBUG" = "1" ]; then
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

		DIR=${map%/*}

		min=${map%.map}

		echo "" > "$min.tmp"

		for js in `cat $map`; do

			cat "$DIR/$js" >> "$min.tmp"
			echo -e "\n" >> "$min.tmp"

		done

		rm -f "$min"

		if [ "$DEBUG" = "1" ]; then
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

	for map in `find $VIEW -name "*.view.lhtml"`; do

		echo "build $map ..."

		rm -f "${map%.view.lhtml}.lhtml"
		
		CMD="$SHDIR/view.py -home $VIEW -o ${map%.view.lhtml}.lhtml -i $map"
		runCommand

		echo "build $map to ${map%.view.lhtml}.lhtml"
		
	done

	for map in `find $VIEW -name "*.view.html"`; do

		echo "build $map ..."

		rm -f "${map%.view.html}.html"
		
		CMD="$SHDIR/view.py -home $VIEW -o ${map%.view.html}.html -i $map"
		runCommand

		echo "build $map to ${map%.view.html}.html"
		
	done

fi

