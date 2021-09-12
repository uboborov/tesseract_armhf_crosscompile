#!/bin/sh

. ./toolchain_path
. ./color

P=$(cat ./toolchain_path)
PP=$(echo $P | sed 's/.*://')
CROSS_COMPILE=$PP/arm-linux-gnueabihf

ROOTDIR=$PWD

cecho y "*** Building leptonlib ***"

LIB=$PWD/leptonica-1.81.1

if [ -d $LIB ]; then
  make -C $LIB clean 2> /dev/null
  make -C $LIB distclean 2> /dev/null
else
    wget https://github.com/DanBloomberg/leptonica/archive/refs/tags/1.81.1.zip
    if [ $? -ne 0 ]; then
        cecho r "!!! Failed to download leptonlib sources"
        exit 1
    fi
    
    unzip 1.81.1.zip
    if [ $? -ne 0 ]; then
      cecho "!!! Failed to extract leptonlib sources"
      exit 1
    fi
fi

mkdir -p $ROOTDIR/lib
mkdir -p $ROOTDIR/include/leptonlib

cp makefile.lepton $LIB/src/makefile
cd $LIB

./autogen.sh

export CFLAGS="-isysroot $ROOTDIR -I$ROOTDIR/include/"

CC=$CROSS_COMPILE-gcc \
AR=$CROSS_COMPILE-ar \
RANLIB=$CROSS_COMPILE-ranlib \
CXX=$CROSS_COMPILE-g++ \
LD=$CROSS_COMPILE-ld \
AS=$CROSS_COMPILE-as \
LDFLAGS="-L$ROOTDIR/lib/" \
./configure \
    --host=arm-linux-gnueabihf \
    --disable-programs \
    --without-giflib \
    --without-libwebp \
    --without-zlib \
    --without-libopenjpeg \
    --prefix $ROOTDIR        

make CROSS_COMPILE=$CROSS_COMPILE- SHARED=yes
if [ $? -ne 0 ]; then
  cecho r "!!! Failed to build leptonlib"
  exit 1
fi

cd $ROOTDIR
cp $LEPTON/lib/nodebug/*.a $ROOTDIR/lib
cp $LEPTON/lib/shared/*.so* $ROOTDIR/lib
cp $LIB/src/*.h $ROOTDIR/include/leptonlib

cecho g "!!! leptonlib done !!!\n"
