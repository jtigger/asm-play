// hello.s — arm64 macOS. Build: cc hello.s -o hello

        .section __TEXT,__text
        .global _main
        .align 2
_main:
        stp     x29, x30, [sp, #-16]!   // save frame pointer + link register
        adrp    x0, msg@PAGE            // address of the string into x0 (arg 1)
        add     x0, x0, msg@PAGEOFF
        bl      _printf                 // printf(msg)
        mov     w0, #0                  // return 0
        ldp     x29, x30, [sp], #16     // restore
        ret

        .section __TEXT,__cstring
msg:
        .asciz "Hello, world!\n"
