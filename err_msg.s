; err_msg.s — error message repository

        .section __TEXT,__text
        .global _err_msg
        .align 2

; err_msg provides the location and length of the error message for
;   the given code.
;
;   (*msg, msglen) = err_msg(code)
;
; args
;   x0 : error code number
; ret
;   x0 : addr of the message bytes
;   x1 : length of message, in bytes, excluding the NUL
_err_msg:
        adrp   x0, errmsg@PAGE
        add    x0, x0, errmsg@PAGEOFF
        mov    x1, #errmsglen
        ret

        .section __TEXT,__cstring
        .align 2

errmsg:
        .ascii "hello-complete: stdin: Expected a file; is a directory\n\0"
        .set    errmsglen, . - errmsg - 1

; linker "flags"
.subsections_via_symbols
