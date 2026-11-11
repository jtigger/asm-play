#include <stdio.h>
#include <string.h>
#include <errno.h>

#define ARRAY_LEN(arr) (sizeof(arr) / sizeof((arr)[0]))

typedef struct {
  const char* msg;
  size_t      msg_len;
} err_msg_result;

extern err_msg_result err_msg(int err_code);

static int check_str_eq(const char* name, const char* expected, const char* actual) {
  int diff;

  diff = strcmp(expected, actual);
  if(diff != 0) {
    printf("\n  %s:\n", name);
    printf("    Expected: `%s`\n", expected);
    printf("      Actual: `%s`\n", actual);
    return 1;
  }

  return 0;
}

static int check_size_eq(const char* name, size_t expected, size_t actual) {
  if(expected != actual) {
    printf("\n  %s:\n", name);
    printf("    Expected: %zu\n", expected);
    printf("      Actual: %zu\n", actual);
    return 1;
  }

  return 0;
}

typedef struct {
  int err_code;
  const char* expected_msg;
  size_t expected_msg_len;
} test_case;

static const test_case test_cases[] = {
  {EFAULT, "hello-complete: stdin: Read failed\n", 35},
  {EISDIR, "hello-complete: stdin: Expected a file; is a directory\n", 55},
};

static int test_given_an_err_code_returns_correct_message(void) {
  int num_test_cases = ARRAY_LEN(test_cases);

  for(int idx = 0; idx < num_test_cases; idx++) {
    err_msg_result result = err_msg(test_cases[idx].err_code);
    char label[80];
    snprintf(label, sizeof(label), "err_msg (when err_code = %d)", test_cases[idx].err_code);
    int fail = check_str_eq(label, test_cases[idx].expected_msg, result.msg);
    if (fail) {
      return fail;
    }
  }

  return 0;
}

static int test_given_an_err_code_returns_correct_message_length(void) {
  int num_test_cases = ARRAY_LEN(test_cases);

  for(int idx = 0; idx < num_test_cases; idx++) {
    err_msg_result result = err_msg(test_cases[idx].err_code);
    char label[80];
    snprintf(label, sizeof(label), "msg_len (when err_code = %d)", test_cases[idx].err_code);
    int fail = check_size_eq(label, test_cases[idx].expected_msg_len, result.msg_len);
    if (fail) {
      return fail;
    }
  }

  return 0;
}

typedef struct {
  int test_count;
  int failures;
} test_run;

typedef int (*test_fn)(void);

typedef struct {
  const char* name;
  test_fn fn;
} test_entry;

#define TEST_ENTRY(fn) { #fn, fn }
static const test_entry tests[] = {
  TEST_ENTRY(test_given_an_err_code_returns_correct_message),
  TEST_ENTRY(test_given_an_err_code_returns_correct_message_length),
};

static void exec_test(test_run* run, const char* name, test_fn fn) {
  int result;

  printf("%s ... ", name);
  result = fn();
  run->test_count++;

  if (result == 0) {
    printf("ok\n");
  } else {
    printf("FAIL\n");
    run->failures++;
  }
}


int main(void) {
  test_run run = {0};

  int num_tests = ARRAY_LEN(tests);

  for(int idx = 0; idx < num_tests; idx++) {
    exec_test(&run, tests[idx].name, tests[idx].fn);
  }

  printf("\n-----------------------------------------------\n");
  printf("Ran %d tests; %d succeeded, %d failed.\n\n",
      run.test_count, run.test_count-run.failures, run.failures);

  if (run.failures == 0) {
    printf("OK\n\n");
  } else {
    printf("FAIL\n\n");
  }

  return !(run.failures == 0);
}
