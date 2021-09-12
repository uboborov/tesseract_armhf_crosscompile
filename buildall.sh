#!/bin/sh

VMODULE=$1

ROOTDIR=$PWD

BUILDDIR=$ROOTDIR/build
SRCDIR=$ROOTDIR/src
OUTPUT=$ROOTDIR/output
TOOLCHAIN=gcc-linaro-5.5.0-2017.10-i686_arm-linux-gnueabihf

. $SRCDIR/color

# check cmake
cecho y "Checking CMake..."
cmake --version
if [ $? -ne 0 ]; then
  cecho r "!!! Can't find CMake. You have to install CMake first"
  exit 1
fi
cecho g "CMake OK"

# check cmake
cecho y "Checking git..."
git --version
if [ $? -ne 0 ]; then
  cecho r "!!! Can't find git. You have to install git first"
  exit 1
fi
cecho g "git OK"

cecho y "Checking wget..."
wget --version
if [ $? -ne 0 ]; then
  cecho r "!!! Can't find wget. You have to install wget first"
  exit 1
fi
cecho g "wget OK"

if [ -d $BUILDDIR ]; then
  cp -n -r $SRCDIR/* $BUILDDIR
else
  mkdir -p $BUILDDIR
  cp -r $SRCDIR/* $BUILDDIR
fi

if [ ! -d $OUTPUT ]; then
  mkdir -p $OUTPUT
fi

if [ ! -d $BUILDDIR/toolchain ]; then
    cecho y "Installing toolchain: $TOOLCHAIN"
    mkdir -p $BUILDDIR/toolchain
    tar -C $BUILDDIR/toolchain -xf $ROOTDIR/toolchain/$TOOLCHAIN.tar.xz
fi

echo "PATH=\$PATH:$BUILDDIR/toolchain/$TOOLCHAIN/bin" > $BUILDDIR/toolchain_path

# check toolchain
. $BUILDDIR/toolchain_path

cecho y "Checking ARM toolchain..."
arm-linux-gnueabihf-gcc --version
if [ $? -ne 0 ]; then
  cecho r "!!! Can't find arm-linux-gnueabihf toolchain. You have to install arm-linux-gnueabihf toolchain first"
  exit 1
fi
cecho g "ARM toolchain OK"

if [ ! -d $INITDIR ]; then
  mkdir -p $INITDIR
fi

cd $BUILDDIR

FILES="build_zlib.sh build_libtiff.sh build_libpng.sh build_libjpeg.sh build_lepton.sh build_tesseract.sh"

for F in $FILES
do
	cecho y "Processing $F"
	"$PWD/$F"
	if [ $? -ne 0 ]; then
	  cecho r "!!! Failed on processing $F"
	  exit
	fi
done


cecho g "Build done"


