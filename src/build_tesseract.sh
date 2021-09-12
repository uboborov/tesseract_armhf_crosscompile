#!/bin/sh

. ./toolchain_path
. ./color

P=$(cat ./toolchain_path)
PP=$(echo $P | sed 's/.*://')
CROSS_COMPILE=$PP/arm-linux-gnueabihf

ROOTDIR=$PWD

cecho y "*** Building tesseract ***"

LIB=$PWD/tesseract-4.1.1

if [ -d $LIB ]; then
  make -C $LIB clean 2> /dev/null
  make -C $LIB distclean 2> /dev/null
else
    wget https://github.com/tesseract-ocr/tesseract/archive/refs/tags/4.1.1.zip
    if [ $? -ne 0 ]; then
        cecho r "!!! Failed to download leptonlib sources"
        exit 1
    fi
    
    unzip 4.1.1.zip
    if [ $? -ne 0 ]; then
      cecho "!!! Failed to extract leptonlib sources"
      exit 1
    fi
fi

mkdir -p $ROOTDIR/lib
mkdir -p $ROOTDIR/include/tesseract

cp $ROOTDIR/configure.ac $LIB

cd $LIB

export API=23
export TOOLCHAIN=$PP
export ABI_CONFIGURE_HOST=arm-linux-gnueabihf
export AR=$CROSS_COMPILE-ar
export CC=$CROSS_COMPILE-gcc
export CXX=$CROSS_COMPILE-g++
export AS=$CC
export LD=$CROSS_COMPILE-ld
export RANLIB=$CROSS_COMPILE-ranlib
export STRIP=$CROSS_COMPILE-strip

export LEPTONICA_LIBS="-L$ROOTDIR/lib -llept"
export LEPTONICA_CFLAGS="-I$ROOTDIR/include -I$ROOTDIR/include/leptonlib"
export PKG_CONFIG_PATH="$ROOTDIR/lib/pkgconfig"
export CFLAGS="-I$ROOTDIR/include"

export LIBS="-L$ROOTDIR/lib"


make clean
./autogen.sh
./configure \
    --host=arm-linux-gnueabihf \
    --target=arm-linux-gnueabihf \
    --build=x86_64 \
    --disable-openmp \
    --prefix=$ROOTDIR \
    --includedir=$ROOTDIR/include \
     CPPFLAGS="-mfpu=neon -mfloat-abi=hard" \
     CFLAGS="-I$ROOTDIR/include"
#automake
#./configure --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --enable-shared=no --disable-programs \
#            --without-zlib --without-libpng --without-jpeg \
#            --without-giflib --without-libtiff
            

make CROSS_COMPILE=$CROSS_COMPILE
if [ $? -ne 0 ]; then
  cecho r "!!! Failed to build tesseract"
  exit 1
fi

make install

cecho g "!!! tesseract done !!!\n"
