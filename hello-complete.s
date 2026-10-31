// hello-complete.s — arm64 macOS, raw kernel syscalls only (libSystem linked only to satisfy ld).
// Build: cc -nostdlib -e _start hello-complete.s -lSystem -o hello-complete

        .section __TEXT,__text
        .global _start
        .align 2
_start:
        // write(1, msg, len)
        mov     x0, #1              // arg1: fd = stdout
        adrp    x1, Lmsg@PAGE       // arg2: buf = address of Lmsg
        add     x1, x1, Lmsg@PAGEOFF
        mov     x2, #msglen         // arg3: length in bytes
        mov     x16, #4             // syscall number: write
        svc     #0x80               // trap into the kernel

        // exit(0)
        mov     x0, #0              // arg1: status = 0
        mov     x16, #1             // syscall number: exit
        svc     #0x80

        .section __TEXT,__cstring
Lmsg:
        .asciz "Hello, world!\n"
        .set    msglen, . - Lmsg - 1 // byte count, excluding the trailing NUL
