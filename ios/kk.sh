#/bin/bash

KK_SDK=10.0

function exitCommand() {
	exit $1
}

function runCommand() {
	echo $CMD
	$CMD
	if [ $? -ne 0 ]; then
		echo -e "[FAIL] $CMD"
		exitCommand 3
	fi 
}

function libsCommand() {

	local KK_NAME
	local KK_VERSION
	local KK_URL
	local PWD
	local KK_SECTION
	local KK_KEY
	local KK_VALUE
	local NAME
	local URL
	local TAG
	local DOMAIN
	local p

	p=`pwd`

	echo "[INFO] libsCommand $p ..."

	if [ ! -d "$HOME/.kk" ]; then
		mkdir $HOME/.kk
	fi

	echo $KK_LIBS

	cd $HOME/.kk

	for LIB in $KK_LIBS
	do
		URL=${LIB%:*}
		TAG=${LIB##*:}
		NAME=${URL##*/}
		DOMAIN=${URL#*://}
		DOMAIN=${DOMAIN%%/*}
		if [ ! -d $DOMAIN ]; then
			mkdir $DOMAIN
		fi
		cd $DOMAIN
		if [ -d $NAME ]; then
			cd $NAME
			CMD="git checkout $TAG"
			runCommand
			CMD="git pull origin $TAG"
			runCommand
		else
			CMD="git clone $URL"
			runCommand
			cd $NAME
			CMD="git checkout $TAG"
			runCommand
		fi
		buildCommand
		cd $HOME/.kk
	done

	cd $p

	echo "[OK] libsCommand $p"

}

function buildCommand() {

	local KK_NAME
	local KK_VERSION
	local KK_LIBS
	local KK_URL
	local PWD
	local KK_SECTION
	local KK_KEY
	local KK_VALUE
	local NAME
	local URL
	local TAG
	local NAME

	PWD=`pwd`

	echo "[INFO] buildCommand $PWD ..."

	if [ ! -f "kk.ini" ]; then
	exitCommand 3
	fi

	if [ $1 ]
	then
	TARGET=$1
	else
	TARGET=Release
	fi

	for LN in `cat kk.ini`
	do
		if [[ $KK_SECTION = "[KK]" ]]; then
			KK_KEY=${LN%=*}
			KK_VALUE=${LN#*=}
			if [[ $KK_KEY = "NAME" ]]; then
				KK_NAME=$KK_VALUE
				continue
			fi
			if [[ $KK_KEY = "VERSION" ]]; then
				KK_VERSION=$KK_VALUE
				continue
			fi
			if [[ $KK_KEY = "LIB" ]]; then
				KK_LIBS=" $KK_VALUE"
				continue
			fi
			if [[ $KK_URL = "URL" ]]; then
				KK_URL=$KK_VALUE
				continue
			fi
			continue
		fi
		if [[ $LN = "[KK]" ]]; then
			KK_SECTION="$LN"
		fi
	done

	libsCommand

	echo $KK_NAME:$KK_VERSION

	if [ ! -d "$HOME/Library/Frameworks" ]; then
		mkdir $HOME/Library/Frameworks
	fi

	pwd
	cd $KK_NAME

	CMD="xcodebuild -configuration $TARGET"
	runCommand

	CMD="xcodebuild -sdk iphonesimulator$KK_SDK -configuration $TARGET"
	runCommand

	CMD="cp -a build/$TARGET-iphoneos build/$TARGET"
	runCommand

	CMD="lipo -create build/$TARGET-iphoneos/$KK_NAME.framework/$KK_NAME build/$TARGET-iphonesimulator/$KK_NAME.framework/$KK_NAME -output build/$TARGET/$KK_NAME.framework/$KK_NAME"
	runCommand

	CMD="rm -rf $HOME/Library/Frameworks/$KK_NAME.framework"
	runCommand

	CMD="cp -r build/$TARGET/$KK_NAME.framework $HOME/Library/Frameworks/$KK_NAME.framework"
	runCommand

	rm -rf build

	cd $PWD

	echo "[OK] buildCommand $PWD"

}

buildCommand $1

