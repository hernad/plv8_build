# Build plv8 on windows

## Prerequisites

  - mingw64-32 environment - c:/ming32/
  - Python 2.7 - c:/Python27
  - scons 2.2.0 - scons build tool
    
## Build

Supose we have installed EnterpriseDB 32bit PostgreSQL 9.2.2, postgres password: `postgres`, port `5433`
Let's build plv8:

    ./build.sh c:/PostgreSQL /c/opt/postgresql 9.2 2 32 postgres 5433
  
At the end, we should have plv8_9.2_32.tar.bz2  
 
The same procedure for PostgreSQL 9.1.7, postgres password: `postgres`, port `5432`
 
    ./build.sh c:/PostgreSQL /c/opt/postgresql 9.1 7 32 postgres 5432


# References


  - http://www.postgresonline.com/journal/archives/261-Building-PLV8JS-and-PLCoffee-for-Windows-using-MingW64-w64-w32.html
  - http://code.google.com/p/plv8js/issues/detail?id=29

## v8 build

  - http://evadeflow.com/2011/03/compiling-v8-on-windows-7
  - http://code.google.com/p/v8/issues/detail?id=1596i

