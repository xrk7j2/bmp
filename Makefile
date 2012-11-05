REMOVE = rm
CC = gcc
BIN = mandelbrot
LINKFLAGS = -lgambc
CFLAGS = -std=c99 -Wall -pedantic-errors -O2
GAMBFLAGS = -O2

GENERATED = bmp.c main.c
OBJECTS = obj/bmp.o obj/linkfile.o obj/main.o
LINKFILE = linkfile.c

.PHONY: all all-before all-after clean clean-custom

all: all-before $(BIN) all-after

clean: clean-custom
	$(REMOVE) $(GENERATED) $(LINKFILE) $(OBJECTS) $(BIN)

$(BIN): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(BIN) $(LINKFLAGS)

obj:
	mkdir obj

bmp.c: bmp.scm
	gsc -c -o bmp.c bmp.scm

main.c: main.scm
	gsc -c -o main.c main.scm


$(LINKFILE): $(GENERATED)
	gsc -link -o $(LINKFILE) $(GENERATED)

obj/linkfile.o: linkfile.c obj
	$(CC) -c linkfile.c -o obj/linkfile.o $(GAMBFLAGS)

obj/bmp.o: bmp.c obj
	$(CC) -c bmp.c -o obj/bmp.o $(GAMBFLAGS)

obj/main.o: main.c obj
	$(CC) -c main.c -o obj/main.o $(GAMBFLAGS)
