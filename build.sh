#!/bin/bash

VER_MAJOR=9.2
VER_MINOR=2

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

wget $URL -O $BZ2

tar xvfj $BZ2
cd $BASEF

function set_c_env {

export CFLAGS="-m32 -DWIN32"
export CXXFLAGS=$CFLAGS
export CPPFLAGS=$CFLAGS
export LDFLAGS=-m32

export INCLUDES="-I$DIST/include"

}

function set_dist {

  mkdir -p $DIST
  mkdir -p $DIST/bin
  mkdir -p $DIST/include
  mkdir -p $DIST/lib

}

set_c_env
set_dist

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

if [ $? != 0 ]; then
   echo "v8 build unsuccessfull"
   exit 1
fi

cp -v include/*.h $DIST/include
cp -v v8*.dll $DIST/bin
cp -v libv8*.a $DIST/lib

}

function build_pv8 {

   git clone $PLV8_GIT
   cd plv8
   ./install.sh

}

build_v8
build_postgresql


build_pv8
