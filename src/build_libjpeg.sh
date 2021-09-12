#!/bin/sh

. ./toolchain_path
. ./color

P=$(cat ./toolchain_path)
PP=$(echo $P | sed 's/.*://')
CROSS_COMPILE=$PP/arm-linux-gnueabihf

ROOTDIR=$PWD

cecho y "*** Building libjpeg-turbo ***"

LIB=$PWD/libjpeg-turbo-2.1.0

if [ -d $LIB ]; then
  make -C $LIB clean 2> /dev/null
  make -C $LIB distclean 2> /dev/null
else
    wget https://github.com/libjpeg-turbo/libjpeg-turbo/archive/refs/tags/2.1.0.zip
    if [ $? -ne 0 ]; then
        cecho r "!!! Failed to download libjpeg-turbo sources"
        exit 1
    fi
    
    unzip 2.1.0.zip
    if [ $? -ne 0 ]; then
      cecho "!!! Failed to extract libjpeg-turbo sources"
      exit 1
    fi
fi

mkdir -p $ROOTDIR/lib
mkdir -p $ROOTDIR/include/libjpeg

#cp makefile.lepton $LEPTON/src/makefile
cd $LIB

cat <<EOF >linux-arm-toolchain.cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_C_FLAGS "-mfloat-abi=hard -march=armv7-a -mfpu=neon -mthumb")
set(CMAKE_C_COMPILER $CROSS_COMPILE-gcc)
set(CMAKE_LIBRARY_PATH $ROOTDIR/lib)
set(CMAKE_INCLUDE_PATH $ROOTDIR/include)
set(CMAKE_INSTALL_PREFIX $ROOTDIR)
EOF

cmake -G"Unix Makefiles" -DCMAKE_TOOLCHAIN_FILE=linux-arm-toolchain.cmake \
	-DREQUIRE_SIMD=1 . ${1+"$@"}
            

#make CROSS_COMPILE=$CROSS_COMPILE
if [ $? -ne 0 ]; then
  cecho r "!!! Failed to build libjpeg-turbo"
  exit 1
fi

make install

cecho g "!!! libpng done !!!\n"
