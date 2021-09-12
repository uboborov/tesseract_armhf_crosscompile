#!/bin/sh

. ./toolchain_path
. ./color

P=$(cat ./toolchain_path)
PP=$(echo $P | sed 's/.*://')
CROSS_COMPILE=$PP/arm-linux-gnueabihf

ROOTDIR=$PWD

cecho y "*** Building zlib ***"

LIB=$PWD/zlib-1.2.11

 

if [ -d $LIB ]; then
  make -C $LIB clean 2> /dev/null
  make -C $LIB distclean 2> /dev/null
else
    wget https://github.com/madler/zlib/archive/refs/tags/v1.2.11.zip
    if [ $? -ne 0 ]; then
        cecho r "!!! Failed to download zlib sources"
        exit 1
    fi
    
    unzip v1.2.11.zip
    if [ $? -ne 0 ]; then
      cecho "!!! Failed to extract zlib sources"
      exit 1
    fi
fi

mkdir -p $ROOTDIR/lib
mkdir -p $ROOTDIR/include/zlib

#cp makefile.lepton $LEPTON/src/makefile
cd $LIB

CHOST=arm-linux-gnueabihf CC=$CROSS_COMPILE-gcc \
AR=$CROSS_COMPILE-ar \
RANLIB=$CROSS_COMPILE-ranlib \
./configure --prefix=$ROOTDIR
            

make CROSS_COMPILE=$CROSS_COMPILE-
if [ $? -ne 0 ]; then
  cecho r "!!! Failed to build zlib"
  exit 1
fi

make install

cecho g "!!! zlib done !!!\n"
