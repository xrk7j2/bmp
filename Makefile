REMOVE = rm
CC = gcc
BIN = mandelbrot
LINKFLAGS = -lgambc
CFLAGS = -std=c99 -Wall -pedantic-errors -O2
GAMBFLAGS = -O2

GENERATED = bmp.c sample/mandelbrot.c sample/main.c
OBJECTS = obj/bmp.o obj/linkfile.o obj/main.o obj/mandelbrot.o
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

sample/main.c: sample/main.scm
	gsc -c -o sample/main.c sample/main.scm

sample/mandelbrot.c: sample/mandelbrot.scm
	gsc -c -o sample/mandelbrot.c sample/mandelbrot.scm


$(LINKFILE): $(GENERATED)
	gsc -link -o $(LINKFILE) $(GENERATED)

obj/linkfile.o: linkfile.c obj
	$(CC) -c linkfile.c -o obj/linkfile.o $(GAMBFLAGS)

obj/bmp.o: bmp.c obj
	$(CC) -c bmp.c -o obj/bmp.o $(GAMBFLAGS)

obj/main.o: sample/main.c obj
	$(CC) -c sample/main.c -o obj/main.o $(GAMBFLAGS)

obj/mandelbrot.o: sample/mandelbrot.c obj
	$(CC) -c sample/mandelbrot.c -o obj/mandelbrot.o $(GAMBFLAGS)
