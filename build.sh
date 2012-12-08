#!/bin/bash

PG_DEPLOY_DIR=/c/PostgreSQL
PG_VER_MAJOR=9.1
PG_VER_MINOR=7

DIST=c:/dist
PG_INSTALL=/c/opt/postgres
MINGW=/mingw

GIT_EXE=C:/Program\ Files/git/bin/git.exe

GIT_V8=git://github.com/hernad/v8.git
GIT_PLV8=git://github.com/hernad/plv8.git

PYTHON=/c/Python27
SCONS=$PYTHON/Scripts/scons.py

export PGPASSWORD=postgres
PG_PORT=5432

echo "postgres user password: $PG_PASSWORD, postgres server port: $PG_PORT"


# 32bit
PG_ARCH=32

VER=${PG_VER_MAJOR}.${PG_VER_MINOR}

PG_BASEF=postgresql-${VER}
PG_BZ2=${PG_BASEF}.tar.bz2
URL=http://ftp.postgresql.org/pub/source/v$VER/$PG_BZ2

CUR_DIR=`pwd`


# ----- start common --------
function err_exit {

if [ $? != 0 ]; then
   echo "$1 unsuccessfull !"
   exit 1
fi

}

function git_clone_or_pull {
 
URL=$1
DIR=$2

if [ ! -d $DIR ]; then
     "$GIT_EXE" clone $URL
	 err_exit "git $URL clone $DIR"
else
     cd $DIR
     "$GIT_EXE" pull
	 cd ..
fi 

}

# ---- end common ---

function prerequisites {

echo "Checking python/scons/mingw-64 prerequisites ..."

if [ ! -d  $PYTHON ]; then
   test 1 -eq 0
   err_exit "directory $PYTHON not exists (download active python 2.7 ) -"
fi

if [ ! -f $SCONS ]; then
  test 1 -eq 0
  err_exit "$SCONS not exists (download and install scons 2.2.0 ) -"
fi


if [ ! -f "$GIT_EXE" ]; then
  test 1 -eq 0
  err_exit "$GIT_EXE not exists (download and install scons 2.2.0 ) -"
fi

`gcc --version | grep -q mingw-w64`
err_exit "gcc mora bit mingw-w64"
  
if [ ! -d  "${PG_DEPLOY_DIR}/${PG_VER_MAJOR}" ]; then
   test 1 -eq 0
   err_exit "directory $PG_DEPLOY_DIR/$PG_VER_MAJOR not exists (install EnterpriseDB on that location) -"
fi

}

function set_ver_params {

  if [ "$1" != "" ]; then
      PG_VER_MAJOR=$1
      shift
  fi
	  
  if [ "$1" != "" ]; then
      PG_VER_MINOR=$2
      shift
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

echo "CFLAGS=$CFLAGS (the same: CXXFLAGS, CPPFLAGS, CCFLAGS)"

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


if [[ "$PG_VER_MAJOR" == "9.1" ]]; then

   patch -N -p1 < ../mingw64_pg_91.patch  

   if [ $? != 0 ]; then
       
	   while true; do
		   read -p "Continue anyway ? " yn
		   case $yn in
			  [YyDd]* ) break;;
			  [Nn]* ) exit 1;;
			   * ) echo "Please answer yes or no.";;
		   esac
	   done
	fi
	
else
   echo "no patch needed for $PG_VER_MAJOR"
fi

./configure --prefix=$PG_INSTALL/$PG_VER_MAJOR 
err_exit "configure postgresql"

make 
make install

cd ..
}



function build_v8 {

cd $CUR_DIR

git_clone_or_pull $GIT_V8 v8 
   
cd v8

export PATH=$PYTHON:$PATH

if [ "$PG_ARCH"  == "32" ]; then
   arch=ia32
else
   arch=x64
fi

$SCONS mode=release arch=$arch toolchain=gcc importenv=PATH library=shared I_know_I_should_build_with_GYP=yes 
err_exit "v8 build"

$SCONS mode=release arch=$arch toolchain=gcc importenv=PATH library=shared I_know_I_should_build_with_GYP=yes d8 
err_exit "d8 build"

cp -v include/*.h $DIST/include
cp -v d8.exe v8*.dll $DIST/bin
cp -v libv8*.a $DIST/lib

}


function build_plv8 {

   cd $CUR_DIR
   
   git_clone_or_pull $GIT_PLV8 plv8 
 
   cd plv8
   rm plv8.dll plv8_${PG_VER_MAJOR}_${PG_ARCH}.dll
   CMD="./install.sh $PG_DEPLOY_DIR $PG_INSTALL $PG_VER_MAJOR $PG_ARCH  $DIST $MINGW"
   echo $CMD
   $CMD
   
   err_exit "build & install plv8"

 
}


function test_plv8 {
 
  cd $CUR_DIR

  export PATH=$PG_DEPLOY_DIR/$PG_VER_MAJOR/bin:$PG_DEPLOY_DIR/$PG_VER_MAJOR/lib:$PATH
  echo "PGPASSWORD=$PGPASSWORD"
  psql -p $PG_PORT -U postgres -h localhost < plv8_test.sql > test_plv8.log
  
  cat test_plv8.log
  
  ret=`cat test_plv8.log | grep -q 'x jedan x'`
  err_exit "plv8 test - 1"
  
  ret=`cat test_plv8.log | grep -c '(1 row)'`
  
  test "$ret" == "2"
  err_exit "plv8 test-2"
 
  echo "plv8 test success :)"
}

prerequisites

set_c_env
set_dist

set_ver_params $1 $2

build_zlib

download_postgresql_src
build_postgresql

build_v8

build_plv8
test_plv8