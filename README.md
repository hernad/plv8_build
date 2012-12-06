# Build plv8 on windows

Until now, unsuccessfull :(

## my build

I have produced:

v8.dll, v8prepend.dll

plv8.dll

but ... 

   create extension plv8;

causes server crash


## install binaries (mingw compiled) postgresonline

the same result with binary build provided on postgresonline:

 - 32bit plv8/v8 dll binaries (for postgresql 9.2 beta, september 2012)
 - PostgreSQL 9.2.1

The same result. command:
 
    create extension plv8;

causes server crash.


Dependency walker reports this strange missing dependencies:

![crash](https://github.com/hernad/plv8_build/raw/master/img/plv8_crash_dependency.png)






# Mingw

gcc 4.6.1

# References

http://www.postgresonline.com/journal/archives/261-Building-PLV8JS-and-PLCoffee-for-Windows-using-MingW64-w64-w32.html
