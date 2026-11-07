# How to

Run these commands from the repo root. Build output goes in `out/`.

- [Build and test](#build-and-test)
- [Run and debug](#run-and-debug)

## Build and test

### Clean, build, test, and run

```bash
make
```

### Build and run all tests

```bash
make test
```

`make test` runs the unit tests first, then the integration tests. A failing
unit test stops `make` before the integration tests run.

### Run only the unit tests

```bash
make out/err_msg_tests && out/err_msg_tests
```

### Run only the integration tests

```bash
make out/hello-complete && python3 -m unittest discover -s tests -v
```

### Run the integration tests whose names match a word

```bash
python3 -m unittest discover -s tests -v -k directory
```

### Add a new test

Write the test first, and watch it fail before you make it pass.

**A unit test** calls an assembly function directly from C. Unit tests live in
`err_msg_tests.c`.

1. Add a function, `int test_...(void)`, that returns 0 when the test passes
   and 1 when it fails. When it fails, print the expected and actual values.
2. In `main`, call the function the same way the existing tests are called, so
   it's counted in the summary and the exit status.
3. Run the unit tests:

   ```bash
   make out/err_msg_tests && out/err_msg_tests
   ```

**An integration test** runs `out/hello-complete` as a separate process and
checks its stdout, stderr, and exit status. Integration tests live in
`tests/test_hello_complete.py`.

1. Add a method to `HelloCompleteTest` whose name starts with `test_`.
2. Start the program with `subprocess.run(["./out/hello-complete"], ...)`, and
   give it a `timeout` so a hang fails the test instead of stopping the run.
3. Run just that test, by a word from its name:

   ```bash
   make out/hello-complete && python3 -m unittest discover -s tests -v -k <word>
   ```

### Check the Makefile for undefined variables

```bash
make lint
```

### Remove the build output

```bash
make clean
```

## Run and debug

### Run the program

```bash
make run
```

### Run the program with input

```bash
echo "Hi there" | out/hello-complete
```

### Debug the program

```bash
lldb out/hello-complete
```

For a walkthrough, see [Try it in lldb](learn/README.md#try-it-in-lldb).
