CC = cc
CFLAGS = -Wall -Wextra

all: hello hello-complete

hello: hello.c
	$(CC) $(CFLAGS) -o hello hello.c

hello-complete: hello-complete.s
	$(CC) -nostdlib -e _start -o hello-complete hello-complete.s -lSystem

.PHONY: all run run-complete clean

run: hello
	./hello

run-complete: hello-complete
	./hello-complete

clean:
	rm -f hello hello-complete
