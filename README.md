# Build plv8 on windows

## Prerequisites

  - mingw64-32 environment - c:/ming32/
  - Python 2.7 - c:/Python27
  - scons 2.2.0 - scons build tool
  - msys Git - c:/Program Files/Git/bin/git.exe
    
## Build

Supose we have installed [EnterpriseDB 32bit MSVC++ PostgreSQL 9.2.2](http://www.enterprisedb.com/products-services-training/pgdownload#windows), postgres password: `postgres`, port `5433`, installed to `c:/PostgreSQL/9.2`
Let's build plv8:

    ./build.sh c:/PostgreSQL /c/opt/postgresql 9.2 2 32 postgres 5433
  
At the end, we should have [plv8_9.2_32.tar.bz2](https://github.com/hernad/plv8_build/blob/master/binary/plv8_9.2_32.tar.bz2)  
 
The same procedure for PostgreSQL 9.1.7, postgres password: `postgres`, port `5432`
 
    ./build.sh c:/PostgreSQL /c/opt/postgresql 9.1 7 32 postgres 5432

    => [plv8_9.1_32.tar.bz2](https://github.com/hernad/plv8_build/blob/master/binary/plv8_9.1_32.tar.bz2)  

## Usage

    cd c:/PostgreSQL/9.1 # location of my EnterpriseDB PostgreSQL 9.1 Windows 32bit installation
    tar xvfj plv8_9.1_32.tar.bz2


# References

  - http://www.postgresonline.com/journal/archives/261-Building-PLV8JS-and-PLCoffee-for-Windows-using-MingW64-w64-w32.html
  - http://code.google.com/p/plv8js/issues/detail?id=29



