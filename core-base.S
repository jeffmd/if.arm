@ core-base.S

@ ( xt -- )
@ execute XT
Forthword_ EXEC, 0, "exec"
    movs r1, #1
    @ make sure its a thumb address mode
    orrs r1, wreg
    pop_
    bx r1

@ ( xt -- )
@ Don't do anything, just chew up a few cycles
Forthword_ NOOP, INLINE_OPT, "noop"
    ands wreg, wreg
    bx lr
