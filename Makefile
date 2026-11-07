CC = cc
CFLAGS = -Wall -Wextra
PYTHON = python3
OUT_DIR = out

.PHONY: all clean run test

all: clean test run

$(OUT_DIR)/hello-complete: hello-complete.s $(OUT_DIR)/err_msg.o
	$(CC) -nostdlib -o $(OUT_DIR)/hello-complete hello-complete.s $(OUT_DIR)/err_msg.o -lSystem

$(OUT_DIR)/err_msg.o: err_msg.s
	mkdir -p $(OUT_DIR)/
	$(CC) -c -o $(OUT_DIR)/err_msg.o err_msg.s

run: $(OUT_DIR)/hello-complete
	$(OUT_DIR)/hello-complete

test: $(OUT_DIR)/hello-complete
	$(PYTHON) -m unittest discover -s tests -v

clean:
	if [ -d $(OUT_DIR) ]; then rm -r $(OUT_DIR)/; fi
