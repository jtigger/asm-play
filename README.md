# asm-play

A place to learn arm64 assembly on macOS by writing it. The program,
`hello-complete`, echoes what it reads on stdin, or prints `Hello, world!` when
stdin is empty, closed, or a terminal. Notes from the side lessons live in
[`learn/`](learn/README.md).

## Prerequisites

- **macOS on Apple silicon (arm64).** The assembly uses macOS system calls and
  the arm64 instruction set.
- **Xcode Command Line Tools:** `cc` (Apple clang), `make` (GNU Make 3.81), and
  `lldb`. Install them with `xcode-select --install`.
- **Python 3**, for the integration tests. The tests use only the standard
  library.

Last checked with macOS 27.0.1, Apple clang 21.0.0, and Python 3.15.0.

## How to

To build, test, run, and debug, and to add a new test, see
[how-to.md](how-to.md).
