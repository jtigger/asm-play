#include<stdio.h>
#include<string.h>
#include<errno.h>

typedef struct {
  const char* msg;
  size_t      msg_len;
} err_msg_result;

extern err_msg_result err_msg(int err_code);

int test_given_unknown_err_code_returns_generic_message(void) {
  err_msg_result result;
  int diff;
  int err_code;
  const char* expected_msg;

  // Arrange
  err_code = EFAULT;
  expected_msg = "hello-complete: stdin: Read failed\n";

  // Act
  result = err_msg(err_code);

  // Assert
  diff = strcmp(expected_msg, result.msg);
  if(diff != 0) {
    printf("\n  result.msg:\n");
    printf("    Expected: `%s`\n", expected_msg);
    printf("      Actual: `%s`\n", result.msg);
    return 1;
  }

  return 0;
}

int test_given_unknown_err_code_returns_correct_message_length(void) {
  err_msg_result result;
  int err_code;
  size_t expected_msg_len;

  // Arrange
  err_code = EFAULT;
  expected_msg_len = 35;

  // Act
  result = err_msg(err_code);

  // Assert
  if(expected_msg_len != result.msg_len) {
    printf("\n  result.msg_len:\n");
    printf("    Expected: %zu\n", expected_msg_len);
    printf("      Actual: %zu\n", result.msg_len);
    return 1;
  }

  return 0;
}

int test_given_EISDIR_err_code_returns_correct_message(void) {
  err_msg_result result;
  int diff;
  int err_code;
  const char* expected_msg;

  // Arrange
  err_code = EISDIR;
  expected_msg = "hello-complete: stdin: Expected a file; is a directory\n";

  // Act
  result = err_msg(err_code);

  // Assert
  diff = strcmp(expected_msg, result.msg);
  if(diff != 0) {
    printf("\n  result.msg:\n");
    printf("    Expected: `%s`\n", expected_msg);
    printf("      Actual: `%s`\n", result.msg);
    return 1;
  }

  return 0;
}

int test_given_EISDIR_err_code_returns_correct_message_length(void) {
  err_msg_result result;
  int err_code;
  size_t expected_msg_len;

  // Arrange
  err_code = EISDIR;
  expected_msg_len = 55;

  // Act
  result = err_msg(err_code);

  // Assert
  if(expected_msg_len != result.msg_len) {
    printf("\n  result.msg_len:\n");
    printf("    Expected: %zu\n", expected_msg_len);
    printf("      Actual: %zu\n", result.msg_len);
    return 1;
  }

  return 0;
}

int main(void) {
  int result;
  int count = 0;
  int failures = 0;

  printf("test_given_EISDIR_err_code_returns_correct_message ... ");
  result = test_given_EISDIR_err_code_returns_correct_message();
  count++;
  if (result == 0) {
    printf("ok\n");
  } else {
    printf("FAIL\n");
    failures++;
  }

  printf("test_given_EISDIR_err_code_returns_correct_message_length ... ");
  result = test_given_EISDIR_err_code_returns_correct_message_length();
  count++;
  if (result == 0) {
    printf("ok\n");
  } else {
    printf("FAIL\n");
    failures++;
  }

  printf("test_given_unknown_err_code_returns_generic_message ... ");
  result = test_given_unknown_err_code_returns_generic_message();
  count++;
  if (result == 0) {
    printf("ok\n");
  } else {
    printf("FAIL\n");
    failures++;
  }

  printf("test_given_unknown_err_code_returns_correct_message_length ... ");
  result = test_given_unknown_err_code_returns_correct_message_length();
  count++;
  if (result == 0) {
    printf("ok\n");
  } else {
    printf("FAIL\n");
    failures++;
  }

  printf("\n-----------------------------------------------\n");
  printf("Ran %d tests; %d succeeded, %d failed.\n\n", count, (count - failures), failures);

  if (failures == 0) {
    printf("OK\n\n");
  } else {
    printf("FAIL\n\n");
  }
  
  return !(failures == 0);
}
