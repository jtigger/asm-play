# Learning sidebars

This directory holds the visuals we made when we paused the main work to learn
a concept in depth. Each section below says what the visual teaches, what we
were doing when we took the sidebar, and why the concept mattered at that
moment.

To view a visual, open its `.html` file in a browser (for example,
`open learn/bl_ret_two_level_call_stepper.html`).

## Contents

- [The frame-record chain: `bl` and `ret` two calls deep](#the-frame-record-chain-bl-and-ret-two-calls-deep)

---

## The frame-record chain: `bl` and `ret` two calls deep

Visual: [bl_ret_two_level_call_stepper.html](bl_ret_two_level_call_stepper.html),
a step-by-step animation of `main` calling `A`, and `A` calling `B`.

### Key insight

**The chain of frame records on the stack is an
[intrusive linked list](https://en.wikipedia.org/wiki/Linked_list#Internal_and_external_storage)**,
and **the programmer is responsible for keeping it intact by following the
calling convention**
([AAPCS64](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst),
with [Apple's changes to it](https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms)).

- **Each node is a frame record:** two 64-bit values, 16 bytes in all.
  - The lower-addressed value is the **link**: the caller's `x29`, which holds
    the address of the caller's frame record.
  - The higher-addressed value is the **data**: the caller's `x30`, which holds
    the address in the caller where this function returns.
- **The head of the list is the live `x29` register.** It points to the frame
  record of the function that is running now.
- **The end of the list is a link whose value is 0.** At process start, the
  kernel sets `x29` to 0, so the first frame record (in dyld's `start`) stores
  a 0 link.
- **The list is intrusive:** the frame records are not next to each other in
  memory. Each frame record sits inside its function's stack frame, next to
  that function's local data (such as `_main`'s 256-byte read buffer).
- **Leaf functions add no node.** A leaf function calls nothing, so nothing
  overwrites its `x30`, and it doesn't need to save `x30`.

AAPCS64 uses the same words. Section 6.4.6,
[The Frame Pointer](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst#the-frame-pointer),
begins: "Conforming code shall construct a linked list of stack-frames."

### Nothing enforces the convention except you

The hardware knows nothing about frame records. The hardware only does two
things:

- `bl label` copies the return address (the address of the next instruction)
  into `x30`, then jumps to `label`.
- `ret` jumps to the address in `x30`.

Everything else is software following a convention:

| Rule | Where it's written | What breaks if you skip it |
|------|--------------------|----------------------------|
| A function that calls another function saves `x30` first. | AAPCS64 §6.4.6; the prologue `stp x29, x30, [sp, #-16]!` | The inner `bl` overwrites `x30`. The outer `ret` jumps back to just after the inner `bl`, runs the outer function's tail again, and loops forever. |
| `x29` points to a valid frame record at all times. | [Apple](https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms): "The frame pointer register (x29) must always address a valid frame record." | Debuggers, crash reports, and profilers print a wrong or truncated backtrace. |
| A function restores `x19`–`x29` and `sp` before it returns. | AAPCS64 §6.1.1, [General-purpose Registers](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst#general-purpose-registers) ("Registers r19-r29 and SP are Callee-saved") | The caller finds its values changed and misbehaves far from the cause. |
| `sp` stays a multiple of 16. | AAPCS64 [Universal stack constraints](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst#universal-stack-constraints) ("SP mod 16 = 0") | A memory access through a misaligned `sp` raises an alignment fault. |
| Don't use `x18`. | Apple: "The platforms reserve register x18." | The platform owns `x18`. A value your code puts there isn't guaranteed to survive. |

The assembler doesn't check any of these rules. In C, the compiler follows
these rules for you. In assembly, you follow them yourself.

### Where we were when we took this sidebar

We were working on story
[#4: Extract the error-message lookup into its own function and file](https://github.com/jtigger/asm-play/issues/4),
part of goal [#1: Bring `hello-complete` under test](https://github.com/jtigger/asm-play/issues/1).

`_err_msg` is the first function in `hello-complete.s` that `_main` calls with
`bl`. Writing `_err_msg` raised questions that the earlier code never did:

- Which registers does `_err_msg` receive its argument in, and return its
  results in? (`x0` in; `x0` and `x1` out.)
- Where does `_main` save `x30`, given that `bl _err_msg` overwrites `x30`?
- What do `stp x29, x30, [sp, #-16]!` and `mov x29, sp` actually do to memory
  and to the registers?

We stepped through `_main`'s prologue in lldb and saw the saved `x29` and `x30`
in memory. The vocabulary (frame record, frame pointer, link register) was
still hard to keep straight, so we built this animation.

This mattered now because:

- Story #4 adds the first `bl` and `ret` pair to the program.
- Story [#5](https://github.com/jtigger/asm-play/issues/5) will call
  `_err_msg` from C, so `_err_msg` must follow the calling convention exactly.
- Story [#7](https://github.com/jtigger/asm-play/issues/7) will grow
  `_err_msg`. If `_err_msg` ever calls another function, `_err_msg` stops being
  a leaf function and needs its own prologue and epilogue.

### What to watch in the animation

- **`stp` only copies.** `stp` copies `x29` and `x30` into memory. The
  registers keep their values.
- **`mov x29, sp` doesn't undo the save.** The `stp` already saved the old
  `x29` in memory. `mov x29, sp` then sets `x29` to the address of the new
  frame record, which makes the new frame record the head of the list.
- **The second `bl` overwrites `x30`.** After `bl B`, the saved copy of `A`'s
  return address in `A`'s frame record is the only copy left.
- **`B` never touches the stack.** `B` is a leaf function.
- **`ldp` leaves stale values behind.** `ldp` copies the saved values back into
  the registers and moves `sp` up. The bytes below `sp` still hold the old
  values, but they are no longer part of the stack.

### Vocabulary

| Term | Meaning |
|------|---------|
| Link register (`x30`, `lr` in lldb) | The register `bl` writes the return address to, and `ret` reads it from. |
| Frame pointer (`x29`, `fp` in lldb) | The register that points to the current function's frame record. |
| Frame record | Two 64-bit values on the stack: the caller's `x29` (the link), then the caller's `x30` (the return address). |
| Stack frame | All of a function's stack space: its frame record plus its local data. |
| Prologue | The instructions at the start of a function that build its stack frame: `stp x29, x30, [sp, #-16]!` then `mov x29, sp`. |
| Epilogue | The instructions at the end of a function that undo the prologue: `ldp x29, x30, [sp], #16` then `ret`. |
| Pre-index (`[sp, #-16]!`) | Change `sp` first, then access memory at the new `sp`. |
| Post-index (`[sp], #16`) | Access memory at `sp` first, then change `sp`. |
| Leaf function | A function that calls no other function. It may skip the frame record. |
| Callee-saved register | A register that a called function must restore before it returns (`x19`–`x29`, `sp`). |
| Caller-saved register | A register that any call may overwrite (`x0`–`x15`). The caller saves it if the caller needs it later. |

### Try it in lldb

`err_msg` only runs on an error, so give the program a directory on stdin
(`-i .`) to reach the breakpoint. From the repo root, after `make`:

```
lldb out/hello-complete
(lldb) breakpoint set -n err_msg
(lldb) process launch -i .
(lldb) bt
(lldb) register read fp lr sp
(lldb) memory read -f x -s 8 -c 2 $fp
(lldb) memory read -f x -s 8 -c 2 *(long*)$fp
```

- `bt` prints one line per frame: `err_msg`, `main`, then dyld's `start`.
- `err_msg` is a leaf function, so `fp` still points to `main`'s frame record.
  `bt` finds `err_msg`'s caller from the live `lr` register, not from the stack.
- The first `memory read` shows `main`'s frame record: the link to `start`'s
  frame record, then `main`'s return address into `start`.
- The second `memory read` follows that link. The result we got (2026-11-07):

  ```
  0x16fdfe250: 0x0000000000000000 0x0000000000000000
  ```

  `start`'s frame record holds a 0 link, which ends the list. Its saved return
  address is also 0, because nothing called `start`.

### References

- [AAPCS64: Procedure Call Standard for the Arm 64-bit Architecture](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst)
  - §6.1.1 [General-purpose Registers](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst#general-purpose-registers)
  - §6.4.6 [The Frame Pointer](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst#the-frame-pointer)
  - §6.5 [Subroutine calls](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst#subroutine-calls)
- [Apple: Writing ARM64 code for Apple platforms](https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms)
- [Wikipedia: Linked list, Internal and external storage](https://en.wikipedia.org/wiki/Linked_list#Internal_and_external_storage)
  (the section that describes intrusive lists)
