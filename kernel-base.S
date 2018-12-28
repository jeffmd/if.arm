@ kernel-base.S - minimum kernel to get if running

@ ( val -- char )
@ convert low byte of val to a printable hex character
Forthword_ NHEX, 0, "#h"
    movs r0, #0x0F
    ands wreg, r0
    cmp wreg, #10
    blo.n NHEX_NEXT
    adds wreg, #7

    @ <then>
NHEX_NEXT:
    adds wreg, #48
    bx lr

@ ( n -- )
@ simple 4 bit hex print
Forthword_ PNIB, 0, ".h"
    push {lr}
    bl NHEX
    pop_lr_
    b EMIT

@ ( n -- )
@ simple 32 bit hex print
Forthword_ PHEX, 0, ".$"
    push {lr}
    dolit8_ '$
    bl EMIT
    dolit8_ 28
PHEX_BEGIN:
    bl TWOOVER
    rshift_
    bl PNIB
    subs wreg, #4
    bne.n PHEX_BEGIN

    pop_
    push_
    bl PNIB
    movs wreg, #32
    pop_lr_
    b EMIT

@ ( -- )
@ reset stacks and start over again
Forthword_ QUIT, 0, "quit"
    push {lr}
    @ reset data stack
    bl SP0
    bl SP_STORE
    @ reset return stack pointers
    bl RP0
    fetch_
    bl RP_STORE
@    bl RESET
    pop_lr_
    b DOTASKS

