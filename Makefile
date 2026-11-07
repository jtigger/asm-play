CC = cc
CFLAGS = -Wall -Wextra
PYTHON = python3

all: test

hello-complete: hello-complete.s err_msg.o
	$(CC) -nostdlib -o hello-complete hello-complete.s err_msg.o -lSystem

err_msg.o: err_msg.s
	$(CC) -c -o err_msg.o err_msg.s

.PHONY: all clean run test

run: hello-complete
	./hello-complete

test: hello-complete
	$(PYTHON) -m unittest discover -s tests -v

clean:
	rm -f hello-complete err_msg.o
