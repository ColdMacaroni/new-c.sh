#!/bin/env sh
# Released under the MIT license
# Copyright (c) 2023 ColdMacaroni
# Creates a new C project folder

# Remove trailing slash
projdir="$(echo "$1" | sed 's@/*$@@')"

# Check we've actually got smth
if [ -z "$projdir" ]; then
  >&2 echo "Please provide a folder for the project"
  exit 1
fi

# We don't want to overwrite
if [ -e "$projdir" ]; then
  >&2 echo "Folder '$projdir' already exists"
  exit 2
fi

# Folders
mkdir -p "$projdir"
for d in obj src bin include; do
  mkdir -p "$projdir/$d"
  touch "$projdir/$d/.keep"
done

# Create a Makefile
# shellcheck disable=2016
echo '# Compiler and compiler flags
CC=gcc

# Show all the Warnings! May want to add -Werror as well.
CCFLAGS=-Wall -Wextra -pedantic

# Libraries to use
LIBS=

# Where to store the executable
BINDIR=bin

# Name of executable
BIN=BINARYNAMEHERE

# Directory with header files
INCLUDEDIR=include

# Directory with the .cpp files
SRCDIR=src

# Directory for object files (compiled)
OBJDIR=obj

SRCFILES=$(patsubst %,${SRCDIR}/%,main.c)
OBJFILES=$(patsubst ${SRCDIR}%.c,${OBJDIR}%.o,${SRCFILES})

# Make the executable, linking the compiled files together with the libraries
${BINDIR}/${BIN}: ${OBJFILES} ${BINDIR}
	${CC} ${CCFLAGS} ${OBJFILES} ${LIBS} -I${INCLUDEDIR} -o ${BINDIR}/${BIN}

${BINDIR}:
	mkdir -p ${BINDIR}

# Compile the files, no linking.
${OBJDIR}/%.o: ${SRCDIR}/%.c ${OBJDIR}
	${CC} ${CCFLAGS} ${OBJDIR} -c -o $@ $< -I${INCLUDEDIR}

${OBJDIR}:
	mkdir -p ${OBJDIR}

clean:
	rm -f ${OBJFILES}
	rm -f ${BINDIR}/${BIN}
' > "$projdir/Makefile"

sed "s/BINARYNAMEHERE/$(basename "$projdir")/" -i "$projdir/Makefile"

# Start git
git -C "$projdir" init

# Create .gitignore
echo 'obj/*
bin/*' > "$projdir/.gitignore"

# Stage the generated files
git -C "$projdir" add .

# Commit with a custom message, but let the user edit
git -C "$projdir" commit -v --edit -m "Setup project structure"

# Start coding!
if [ -e "$projdir/src" ]; then
  touch "$projdir/src/main.c"
fi
