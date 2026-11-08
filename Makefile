CC = cc

CFLAGS = -Wall -Werror -Wextra
#   all :: enables a common set of warnings (not actually all)
# error :: treat warnings as errors
# extra :: includes additional sets of warnings

LDFLAGS = -Wl,-dead_strip
# l,(flags)     :: pass the following flags to the linker
#   -dead_strip :: removes unreferenced functions and data

PYTHON = python3
OUT_DIR = out

.PHONY: all clean lint run test

all: clean test run

$(OUT_DIR)/hello-complete: src/hello-complete.s $(OUT_DIR)/err_msg.o
	$(CC) $(LDFLAGS) -nostdlib \
		-o $(OUT_DIR)/hello-complete \
		src/hello-complete.s $(OUT_DIR)/err_msg.o \
		-lSystem

$(OUT_DIR)/err_msg.o: src/err_msg.s
	mkdir -p $(OUT_DIR)/
	$(CC) -c -o $(OUT_DIR)/err_msg.o src/err_msg.s

run: $(OUT_DIR)/hello-complete
	$(OUT_DIR)/hello-complete

test: $(OUT_DIR)/hello-complete $(OUT_DIR)/err_msg_tests
	$(OUT_DIR)/err_msg_tests
	$(PYTHON) -m unittest discover -s tests/integration -v

$(OUT_DIR)/err_msg_tests: tests/unit/err_msg_tests.c $(OUT_DIR)/err_msg.o
	$(CC) $(CFLAGS) $(LDFLAGS) \
		-o $(OUT_DIR)/err_msg_tests \
		tests/unit/err_msg_tests.c $(OUT_DIR)/err_msg.o

lint:
	@! $(MAKE) -n -B --warn-undefined-variables all 2>&1 | grep 'undefined variable'

clean:
	if [ -d $(OUT_DIR) ]; then rm -r $(OUT_DIR)/; fi
