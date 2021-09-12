#!/bin/sh

. ./toolchain_path
. ./color

P=$(cat ./toolchain_path)
PP=$(echo $P | sed 's/.*://')
CROSS_COMPILE=$PP/arm-linux-gnueabihf-

ROOTDIR=$PWD

cecho y "*** Building libpng ***"

LIB=$PWD/libpng-1.6.37

if [ -d $LIB ]; then
  make -C $LIB clean 2> /dev/null
  make -C $LIB distclean 2> /dev/null
else
    wget https://github.com/glennrp/libpng/archive/refs/tags/v1.6.37.zip
    if [ $? -ne 0 ]; then
        cecho r "!!! Failed to download libpng sources"
        exit 1
    fi
    
    unzip v1.6.37.zip
    if [ $? -ne 0 ]; then
      cecho "!!! Failed to extract libpng sources"
      exit 1
    fi
fi

mkdir -p $ROOTDIR/lib
mkdir -p $ROOTDIR/include/libpng

#cp makefile.lepton $LEPTON/src/makefile
cd $LIB
#automake
./configure --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf \
        --prefix=$ROOTDIR \
        CPPFLAGS="-mfpu=neon -I$ROOTDIR/include" LDFLAGS="-L$ROOTDIR/lib"
            

make CROSS_COMPILE=$CROSS_COMPILE
if [ $? -ne 0 ]; then
  cecho r "!!! Failed to build libpng"
  exit 1
fi

make install

cecho g "!!! libpng done !!!\n"
