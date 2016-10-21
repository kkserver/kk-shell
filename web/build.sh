#/bin/sh

#build js

PWD=`pwd`
HOME=`dirname $0`

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
			java -jar $HOME/yuicompressor.jar --charset utf-8 --type js -o "$min" "$min.tmp"
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
			java -jar $HOME/yuicompressor.jar --charset utf-8 --type css -o "$min" "$min.tmp"
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
		
		CMD="$HOME/view.py -home $VIEW -o ${map%.view.html}.html -i $map"
		runCommand

		echo "build $map to ${map%.view.html}.html"
		
	done

fi

