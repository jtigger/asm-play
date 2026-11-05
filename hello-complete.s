; hello-complete.s — arm64 macOS, raw kernel syscalls only (libSystem linked only to satisfy ld).
; Build: cc -nostdlib -e _main hello-complete.s -lSystem -o hello-complete

        .section __TEXT,__text
        .global _main
        .align 2

; User constants
        .set    BUFSIZE, 256        ; input buffer size (bytes)
                                    ; - must be a multiple of 16 because we're using the stack
                                    ;   and `sp` must remain 16-byte aligned.

; System-Constants
        .set    EBADF, 9            ; syscall#3 err: bad file descriptor
        .set    STDERR, 2           ; fd: standard error

_main:
        sub     sp, sp, #BUFSIZE    ; allocate buffer on the stack

        ; n = read(fd, buf, max)
        mov     x0, #0              ; stdin
        mov     x1, sp              ; addr of buffer we just allocated
        mov     x2, #BUFSIZE        ; size of buffer we just allocated
        mov     x16, #3             ; syscall: read
        svc     #0x80
          ; x0 = success ? number chars read : error number
          ;  success : "carry" clear
          ;  error : "carry" set

        b.cs    Lhandle_read_error

        cbz     x0, Lset_default_msg

        mov     x1, sp
        mov     x2, x0
        b       Ldo_write

Lhandle_read_error:
        cmp     x0, #EBADF
        b.eq    Lset_default_msg

        ; exit(2)
        b       Lerr2

Lset_default_msg:
        ; configure write() to use default message
        adrp    x1, msg@PAGE        ; addr of page where message is
        add     x1, x1, msg@PAGEOFF ; offset within the page where message is
        mov     x2, #msglen         ; length in bytes

Ldo_write:
        ; write(fd, msg, len)
        mov     x0, #1              ; arg1: fd = stdout
        mov     x16, #4             ; syscall number: write
        svc     #0x80               ; trap into the kernel

Lexit0:
        ; exit(status)
        mov     x0, #0
Lexit:
        mov     x16, #1             ; syscall: exit
        svc     #0x80

; ===* exit() *===

Lerr2:
        ; write(fd, msg, len)
        mov     x0, #STDERR
        adrp    x1, errmsg@PAGE
        add     x1, x1, errmsg@PAGEOFF
        mov     x2, #errmsglen
        mov     x16, #4             ; syscall number: write
        svc     #0x80
        ; we are erring out: no error handling, here.

        mov     x0, #2
        b       Lexit

        .section __TEXT,__cstring
        .align 2
        .subsections_via_symbols

msg:
        .ascii "Hello, world!\n\0"
        .set    msglen, . - msg - 1  ; byte count (without trailing NUL)
errmsg:
        .ascii "hello-complete: stdin: Expected a file; is a directory\n\0"
        .set    errmsglen, . - errmsg - 1

