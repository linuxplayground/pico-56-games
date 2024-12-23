<!-- vim: set tw=80 cc=80 ft=markdown: -->
# pico-56-games

A collection of games written for the Pico-56
[https://github.com/visrealm/pico-56](https://github.com/visrealm/pico-56ttps://github.com/visrealm/pico-56)

- jumpingjack - Original game (c) 1983 Imagine Software

## COMPILING

You need CC65 installed and in your path.  To use the emulator make sure that's
instlaled someplace too.  You might have to edit the Makefile to point to the
correct location of the emulator.  In my case this works, because I am building
in Windows Subsystem For Linux (WSL) which supports direct execution of windows
EXE files.

```shell
cd jumpingjack
make
```

All going well, the game will be compiled and the `jj.o` file will be in the
`build` directory.

The Makefile also starts up the emulator.
