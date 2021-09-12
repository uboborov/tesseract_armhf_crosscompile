#!/bin/sh

. ./toolchain_path
. ./color

P=$(cat ./toolchain_path)
PP=$(echo $P | sed 's/.*://')
CROSS_COMPILE=$PP/arm-linux-gnueabihf-

ROOTDIR=$PWD

cecho y "*** Building libtiff ***"

LIB=$PWD/tiff-4.3.0

if [ -d $LIB ]; then
  make -C $LIB clean 2> /dev/null
  make -C $LIB distclean 2> /dev/null
else
    wget https://download.osgeo.org/libtiff/tiff-4.3.0.tar.gz
    if [ $? -ne 0 ]; then
        cecho r "!!! Failed to download libtiff sources"
        exit 1
    fi
    
    tar -xf tiff-4.3.0.tar.gz
    if [ $? -ne 0 ]; then
      cecho "!!! Failed to extract libtiff sources"
      exit 1
    fi
fi

mkdir -p $ROOTDIR/lib
mkdir -p $ROOTDIR/include/libtiff

#cp makefile.lepton $LEPTON/src/makefile
cd $LIB
#automake
./configure --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf \
        --prefix=$ROOTDIR
        --disable-lzma \
		--disable-ccitt \
		--disable-packbits \
		--disable-lzw \
		--disable-thunder \
		--disable-next \
		--disable-logluv \
		--disable-mdi \
		--disable-zlib \
		--disable-jpeg \
		--disable-old-jpeg \
		--disable-jbig \
		--disable-webp \
		--disable-zstd \
		--without-x
            

make CROSS_COMPILE=$CROSS_COMPILE
if [ $? -ne 0 ]; then
  cecho r "!!! Failed to build libtiff"
  exit 1
fi

make install

cecho g "!!! libtiff done !!!\n"
