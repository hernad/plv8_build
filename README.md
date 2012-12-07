# Build plv8 on windows

Until now, unsuccessfull :(

## My build mingw build


## Mingw

I already have installed: gcc 4.6.1

The author (see references) doesn't recommend this msys/mingw version. 


I have sucessfully compiled and produced:

v8.dll, v8prepend.dll

plv8.dll

installed to bin/, lib/, shared/extensions to appropriate locations.

but ... 

    create extension plv8;

causes server crash :(.

I have tried with changing PATH variable during link process - the same results.

All of my experiments was on 9.1.6 EnterpriseDB windows installation and the same source code postgersql tree.


## Install plv8 binaries (mingw compiled) postgresonline


the same result with binary build provided on postgresonline:

 - 32bit plv8/v8 dll binaries (for postgresql 9.2 beta, september 2012)
 - PostgreSQL 9.2.1

The same result. command:
 
    create extension plv8;

causes server crash.


Dependency walker reports this strange missing dependencies:

![crash](https://github.com/hernad/plv8_build/raw/master/img/plv8_crash_dependency.png)

Tested on: Windows XP SP3, 32bit

# Notes

# References

## plv8 build

  - http://www.postgresonline.com/journal/archives/261-Building-PLV8JS-and-PLCoffee-for-Windows-using-MingW64-w64-w32.html
  - http://code.google.com/p/plv8js/issues/detail?id=29

## v8 build

  - http://evadeflow.com/2011/03/compiling-v8-on-windows-7
  - http://code.google.com/p/v8/issues/detail?id=1596i


## postgresql build ming64

  - [mingw64 9.1 patch](http://archives.postgresql.org/pgsql-hackers/2011-11/txtRibqmPdzfl.txt) 

      patch -p1 < mingw6491.patch

 
