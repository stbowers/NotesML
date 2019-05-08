# NotesML
A simple notes app written in SML, using the curses library for a terminal interface.

This is a small project for taking quick notes in the terminal that will automatically be saved to the filesystem.
The goal is to be as lightweight and unintrusive as possible so that you can focus on taking quick notes without having
to worry about where they will be saved, what to name them, or even just to take the extra time to open vim in the terminal.

The other goal of this project is education and experimentation, which is why it is written in SML, rather than another language
which might be more suited towards this purpose. The greatest challenge in making this app was finding a way to call curses
functions from within ML. The solution is a tool/library pacakged with SML called ML-NLFFI, which is a "Foreign Function Interface"
for ML, and allows ML code to load and access symbols in a dynamic library. The makefile for this project automatically runs a tool
called ml-nlffigen on the curses.h file in the src directory. This generates the SML equivalent to the header allowing the program
to call any functions/access any symbols defined in the header. A "clean" curses.h file is used instead of the "official" header
shipped with most curses installations because the official header does some weird tricks with the C preprocessor that the tool
doesn't seem to keep up with. As such the header in this repository is much simpler, and only defines a certain subset of the
library, in a way that is easier for the tool (and the user!) to understsand. The header is based off of both the official ncurses.h,
and the man pages for curses.

## Dependencies
To build this project you will need
- curses (or a compatible library such as ncurses or pdcurses, this is usually pre-installed on most linux distros and macOS)
- make

## Important Note!
The current version of the code does not intelligently load the curses dynamic library. This is because *correct* dynamic library loading
that is cross platform is very hard. For this reason if you are not running Linux with the `ncursesw` library installed
(i.e. `/usr/lib(32)/libncursesw.so` exists), you will likely not be able to build the project. The library that is used can easily be changed
by editing line 4 of `src/curses.h.sml`, to look like `val soname = "<library soname>"`. For example, on Windows (with the pdcurses library
installed), it might look like `val soname = "pdcurses.dll"`

## Build instructions
To build the project:
```
git clone https://github.com/stbowers/NotesML
cd NotesML
make
```

To run the project either use sml to run the image at ./out/notes-image.\<arch\>, or run the following:
```
make run
```
