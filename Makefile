CC = cc
CFLAGS = -Wall -Wextra
PYTHON = python3

all: test

hello: hello.c
	$(CC) $(CFLAGS) -o hello hello.c

hello-complete: hello-complete.s
	$(CC) -nostdlib -o hello-complete hello-complete.s -lSystem

.PHONY: all clean run run-complete test

run: hello
	./hello

run-complete: hello-complete
	./hello-complete

test: hello-complete
	$(PYTHON) -m unittest discover -s tests -v

clean:
	rm -f hello hello-complete
