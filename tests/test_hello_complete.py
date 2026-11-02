import os
import subprocess
import unittest

class HelloCompleteTest(unittest.TestCase):
    def test_given_empty_input_prints_default_message(self):
        given_in = subprocess.DEVNULL
        expected_out = b"Hello, world!\n"
        expected_err = b""

        result = subprocess.run(["./hello-complete"],
                                stdin=given_in,
                                capture_output=True,
                                timeout=1,
        )

        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout, expected_out)
        self.assertEqual(result.stderr, expected_err)

    def test_given_an_input_prints_that_as_message(self):
        given_in = b"Greetings from the CLI..."
        expected_out = given_in
        expected_err = b""

        result = subprocess.run(["./hello-complete"],
                                input=given_in,
                                capture_output=True,
                                timeout=1,
        )

        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout, expected_out)
        self.assertEqual(result.stderr, expected_err)

    def test_given_closed_stdin_prints_default_message(self):
        expected_out = b"Hello, world!\n"
        expected_err = b""

        close_stdin = lambda: os.close(0)
        result = subprocess.run(["./hello-complete"],
                                preexec_fn=close_stdin,
                                capture_output=True,
                                timeout=1,
        )

        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout, expected_out)
        self.assertEqual(result.stderr, expected_err)

    def test_given_directory_for_stdin_errors_with_message(self):
        expected_out = b""
        expected_err = b"hello-complete: stdin: Expected a file; is a directory\n"

        dir_fd = os.open(".", os.O_RDONLY)
        self.addCleanup(os.close, dir_fd)

        result = subprocess.run(["./hello-complete"],
                                stdin=dir_fd,
                                capture_output=True,
                                timeout=1,
        )

        self.assertEqual(result.returncode, 2)
        self.assertEqual(result.stdout, expected_out)
        self.assertEqual(result.stderr, expected_err)

if __name__ == "__main__":
    unittest.main()
