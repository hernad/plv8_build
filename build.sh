#!/bin/bash


function prerequisites {

which $PYTHON
err_exit "$PYTHON not exists \(download active python 2.7 \) -"

if [ ! -f "$SCONS" ]; then
  err_exit "$SCONS not exists \(download and install scons 2.2.0 \) -"
fi

}

prerequisites

function set_ver_params {

  if [ "$1" != "" ]; then
      VER_MAJOR=$1
      shift
  fi
	  
  if [ "$1" != "" ]; then
      VER_MINOR=$2
      shift
  fi
	
}


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

PG_BASEF=postgresql-${VER}
PG_BZ2=${PG_BASEF}.tar.bz2
URL=http://ftp.postgresql.org/pub/source/v$VER/$PG_BZ2

CUR_DIR=`pwd`

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
  
  echo "untar zlib bz2"
  tar xfj zlib-1.2.5.tar.bz2
  cd zlib-1.2.5
  #./configure --prefix=$DIST
  
  make -f win32/Makefile.gcc
  
  
  cp zlib*.h zconf.h $DIST/include
  cp libz*.a $DIST/lib
  cp zlib*.dll $DIST/bin
   
  err_exit "zlib build"

  cd $CUR_DIR
}

function download_postgresql_src {

cd $CUR_DIR

if [ ! -f "$PG_BZ2" ]; then
  echo "not exist: $CUR_DIR/$PG_BZ2 .. going to download"
  wget $URL -O $PG_BZ2
  err_exit "postgresql $PG_BZ2 download not successfull !"
fi

}

function build_postgresql {

cd $CUR_DIR

echo "untar $PG_BZ2"
#tar xfj $PG_BZ2
cd $PG_BASEF


if [[ "$VER_MAJOR" == "9.1" ]]; then
   patch -p1 < ../mingw64_pg_91.patch  
   err_exit "patch $VER_MAJOR"
else
   echo "no patch needed for $VER_MAJOR"
fi

./configure --prefix=$PG_INSTALL/$VER_MAJOR 
#--build=mingw win$PG_ARCH

err_exit "configure postgresql"

make 
make install

cd ..
}


function build_v8 {

cd $CUR_DIR

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

cd ..
}


function build_pv8 {

   cd $CUR_DIR
   cd $PG_BASEF
   
   git clone $PLV8_GIT
   cd plv8
   ./install.sh

   cd ..
}

set_c_env
set_dist

set_ver_params $1 $2

build_zlib

download_postgresql_src
build_postgresql

#build_v8


#build_pv8
