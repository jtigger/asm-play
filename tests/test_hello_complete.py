import unittest
import subprocess

class HelloCompleteTest(unittest.TestCase):
    def test_given_empty_input_prints_default_message(self):
        result = subprocess.run(["./hello-complete"],
                                stdin=subprocess.DEVNULL,
                                capture_output=True,
                                timeout=1,
        )
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout, b"Hello, world!\n")
        self.assertEqual(result.stderr, b"")

if __name__ == "__main__":
    unittest.main()
