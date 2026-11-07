CC = cc
CFLAGS = -Wall -Wextra
PYTHON = python3
OUT_DIR = out

.PHONY: all clean lint run test

all: clean test run

$(OUT_DIR)/hello-complete: hello-complete.s $(OUT_DIR)/err_msg.o
	$(CC) -nostdlib -o $(OUT_DIR)/hello-complete hello-complete.s $(OUT_DIR)/err_msg.o -lSystem

$(OUT_DIR)/err_msg.o: err_msg.s
	mkdir -p $(OUT_DIR)/
	$(CC) -c -o $(OUT_DIR)/err_msg.o err_msg.s

run: $(OUT_DIR)/hello-complete
	$(OUT_DIR)/hello-complete

test: $(OUT_DIR)/hello-complete $(OUT_DIR)/err_msg_tests
	$(OUT_DIR)/err_msg_tests
	$(PYTHON) -m unittest discover -s tests -v

$(OUT_DIR)/err_msg_tests: err_msg_tests.c $(OUT_DIR)/err_msg.o
	$(CC) $(CFLAGS) -o $(OUT_DIR)/err_msg_tests err_msg_tests.c $(OUT_DIR)/err_msg.o

lint:
	@! $(MAKE) -n -B --warn-undefined-variables all 2>&1 | grep 'undefined variable'

clean:
	if [ -d $(OUT_DIR) ]; then rm -r $(OUT_DIR)/; fi
