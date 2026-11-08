#include<stdio.h>
#include<string.h>
#include<errno.h>

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

static int test_given_unknown_err_code_returns_generic_message(void) {
  err_msg_result result;
  int err_code;
  const char* expected_msg;

  // Arrange
  err_code = EFAULT;
  expected_msg = "hello-complete: stdin: Read failed\n";

  // Act
  result = err_msg(err_code);

  // Assert
  return check_str_eq("err_msg", expected_msg, result.msg);
}

static int test_given_unknown_err_code_returns_correct_message_length(void) {
  err_msg_result result;
  int err_code;
  size_t expected_msg_len;

  // Arrange
  err_code = EFAULT;
  expected_msg_len = 35;

  // Act
  result = err_msg(err_code);

  // Assert
  return check_size_eq("msg_len", expected_msg_len, result.msg_len);
}

static int test_given_EISDIR_err_code_returns_correct_message(void) {
  err_msg_result result;
  int err_code;
  const char* expected_msg;

  // Arrange
  err_code = EISDIR;
  expected_msg = "hello-complete: stdin: Expected a file; is a directory\n";

  // Act
  result = err_msg(err_code);

  // Assert
  return check_str_eq("err_msg", expected_msg, result.msg);
}

static int test_given_EISDIR_err_code_returns_correct_message_length(void) {
  err_msg_result result;
  int err_code;
  size_t expected_msg_len;

  // Arrange
  err_code = EISDIR;
  expected_msg_len = 55;

  // Act
  result = err_msg(err_code);

  // Assert
  return check_size_eq("msg_len", expected_msg_len, result.msg_len);
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
  TEST_ENTRY(test_given_EISDIR_err_code_returns_correct_message),
  TEST_ENTRY(test_given_EISDIR_err_code_returns_correct_message_length),
  TEST_ENTRY(test_given_unknown_err_code_returns_generic_message),
  TEST_ENTRY(test_given_unknown_err_code_returns_correct_message_length),
};

static const int NUM_TESTS = sizeof(tests)/sizeof(tests[0]);

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

  for(int idx = 0; idx < NUM_TESTS; idx++) {
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
