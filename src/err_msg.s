; err_msg.s — error message repository

        .section __TEXT,__text
        .global _err_msg
        .align 2

        ; TODO: extract to `err_codes.inc`
        .set EAGAIN, 35
        .set EISDIR, 21

; err_msg provides the location and length of the error message for
;   the given code.
;
;   (*msg, msg_len) = err_msg(code)
;
; args
;   w0 : error code number
; ret
;   x0 : addr of the message bytes
;   x1 : length of message, in bytes, excluding the NUL
_err_msg:
        cmp    w0, #EAGAIN
        b.eq   Lerr_eagain
        cmp    w0, #EISDIR
        b.eq   Lerr_eisdir

Lerr_unknown:
        ; generic error
        adrp   x0, msg_unknown@PAGE
        add    x0, x0, msg_unknown@PAGEOFF
        mov    x1, #msg_unknown_len
        ret

Lerr_eagain:
        adrp   x0, msg_eagain@PAGE
        add    x0, x0, msg_eagain@PAGEOFF
        mov    x1, #msg_eagain_len
        ret

Lerr_eisdir:
        adrp   x0, msg_eisdir@PAGE
        add    x0, x0, msg_eisdir@PAGEOFF
        mov    x1, #msg_eisdir_len
        ret

        .section __TEXT,__cstring
        .align 2

msg_eagain:
        .ascii "hello-complete: stdin: Expected blocking input; is non-blocking with no data\n\0"
        .set    msg_eagain_len, . - msg_eagain - 1
msg_eisdir:
        .ascii "hello-complete: stdin: Expected a file; is a directory\n\0"
        .set    msg_eisdir_len, . - msg_eisdir - 1
msg_unknown:
        .ascii "hello-complete: stdin: Read failed\n\0"
        .set    msg_unknown_len, . - msg_unknown - 1

; linker "flags"
.subsections_via_symbols
