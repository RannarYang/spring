#! /bin/bash

# Quit on error.
set -e

if [ ! -e installer ]; then
	echo "Error: This script needs to be run from the root directory of the archive"
	exit 1
fi
WGET="wget -N --cache=off"

TAG=$(git describe --abbrev=7 --tags|tr -d '\n')

if [ "$TAG" = "" ]; then
	echo "Error running git describe"
	exit 1
fi
NSISDEFINES="-DVERSION_TAG="$TAG""

# Evaluate the engines version
if ! git describe --abbrev=7 --candidate=0 --tags 2>/dev/null; then
	NSISDEFINES="$NSISDEFINES -DTEST_BUILD"
	echo "Creating test installer for revision $TAG"
fi

mkdir -p installer/downloads
cd installer/downloads

if [ ! -s spring_testing_minimal-portable.7z ]; then
	echo "Warning: spring_testing_minimal-portable.7z didn't exist, downloading..." >&2
	$WGET https://springrts.com/dl/buildbot/default/master/spring_testing_minimal-portable.7z
fi

cd ../..

#create uninstall.nsh
installer/make_uninstall_nsh.py installer/downloads/spring_testing_minimal-portable.7z >installer/downloads/uninstall.nsh


makensis -V3 $NSISDEFINES $@ -DNSI_UNINSTALL_FILES=downloads/uninstall.nsh \
-DMIN_PORTABLE_ARCHIVE=downloads/spring_testing_minimal-portable.7z \
 installer/spring.nsi

