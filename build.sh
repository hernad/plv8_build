#!/bin/bash

VER_MAJOR=9.1
VER_MINOR=7

DIST=c:/dist
PG_INSTALL=/c/opt/postgres

GIT_V8=git://github.com/hernad/v8.git
GIT_PLV8=git://github.com/hernad/pl_v8.git

PYTHON=/c/Python27
SCONS=$PYTHOM/Scripts/scons.py


# 32bit
PG_ARCH=32

VER=${VER_MAJOR}.${VER_MINOR}

BASEF=postgresql-${VER}
BZ2=${BASEF}.tar.bz2
BZ2=postgresql-$VER.tar.bz2
URL=http://ftp.postgresql.org/pub/source/v$VER/$BZ2


function err_exit {

if [ $? != 0 ]; then
   echo "$1 unsuccessfull !"
   exit 1
fi

}

function set_c_env {

export CFLAGS="-m$PG_ARCH -DWIN$PG_ARCH"
export CXXFLAGS=$CFLAGS
export CPPFLAGS=$CFLAGS
export CCFLAGS=$CFLAGS
export LDFLAGS=-m$PG_ARCH


export INCLUDES="-I$DIST/include"

echo "setup mingw64 environment architecture: $PG_ARCH bit"

echo "CFLAGS=$CFLAGS \(the same: CXXFLAGS, CPPFLAGS, CCFLAGS\)"

echo "LDFLAGS=$LDFLAGS"

echo "INCLUDES=$INCLUDES"

}

function set_dist {

  mkdir -p $DIST
  mkdir -p $DIST/bin
  mkdir -p $DIST/include
  mkdir -p $DIST/lib

  echo "shared libs destination, dist=$DIST /bin, /include, /lib"
}


function build_zlib {

  echo "building zlib"
  
  tar xvfj zlib-1.2.5.tar.bz2
  cd zlib-1.2.5
  #./configure --prefix=$DIST
  
  make -f win32/Makefile.gcc
  
  
  cp zlib*.h zconf.h $DIST/include
  cp libz*.a $DIST/lib
  cp zlib*.dll $DIST/bin
   
  err_exit "zlib build"

}

function download_postgresql_src {

if [ ! -f $BZ2 ]; then
  wget $URL -O $BZ2
fi

tar xvfj $BZ2
cd $BASEF

}
function build_postgresql {

if [ "$VER_MAJOR" == "9.1" ]; then
   patch -p1 < mingw64_pg_91.patch 
fi

./configure --prefix=$PG_INSTALL/$VER_MAJOR --build=win$PG_ARCH

make 
make install

}




function build_v8 {

git clone $GIT_V8
cd v8

export PATH=$PYTHON:$PATH

if [ "$PG_ARCH"  == "32" ]; then
   arch=ia32
else
   arch=x64
fi

$SCONS mode=release arch=$arch toolchain=gcc importenv=PATH library=shared I_know_I_should_build_with_GYP=yes 

err_exit "v8 build"


cp -v include/*.h $DIST/include
cp -v v8*.dll $DIST/bin
cp -v libv8*.a $DIST/lib

}


function build_pv8 {

   git clone $PLV8_GIT
   cd plv8
   ./install.sh

}

set_c_env
set_dist

build_zlib

download_postgresql_src
build_postgresql

#build_v8

download_postgresql_src
build_postgresql

#build_pv8
