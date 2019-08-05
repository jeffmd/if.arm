@ core-inline.S - inlinned words using core macros
@ push pu p+ | pop pp p- | w=[x] [x] w=*x x@ | !x x=w | x! [x]! [x]=w | d0!x x=d0
@ @ [w] w=[w] | ! [w]=d0

@@@@@@@@@@@@@ Parameter Stack  Manipulation @@@@@@@@@@@@@@
@ ( n -- n n )
@ duplicate wreg
Forthword_ DPUSH, INLINE_OPT, "push"
    push_
    bx lr

@ ( n1 n2 -- n1 a  n2 )
@   d0 WR    d1 d0 WR
@ push register A onto top of data stack
Forthword_ DPUSHA, INLINE_OPT, "pusha"
    pusha_
    bx lr

@ ( n1 n2 -- n1 b  n2 )
@   d0 WR    d1 d0 WR
@ push register B onto top of data stack
Forthword_ DPUSHB, INLINE_OPT, "pushb"
    pushb_
    bx lr

@ ( n1 n2 -- n1 x  n2 )
@   d0 WR    d1 d0 WR
@ push register X onto top of data stack
Forthword_ DPUSHX, INLINE_OPT, "pushx"
    pushx_
    bx lr

@ ( n1 n2 -- n1 y  n2 )
@   d0 WR    d1 d0 WR
@ push register Y onto top of data stack
Forthword_ DPUSHY, INLINE_OPT, "pushy"
    pushy_
    bx lr

@ ( n1 n2 -- n2)
@ drop NOS, one before wreg.
Forthword_ NIP, INLINE_OPT, "nip"
    nip_
    bx lr

@ ( n1 n2 n3 -- n3)
@ drop NOS, one before wreg.
Forthword_ NIP2, INLINE_OPT, "nip2"
    nip2_
    bx lr

@ ( n1 n2 n3 n4 -- n4)
@ drop NOS, one before wreg.
Forthword_ NIP3, INLINE_OPT, "nip3"
    nip3_
    bx lr

@ ( n -- )
@ drop wreg
Forthword_ DPOP, INLINE_OPT, "pop"
    pop_
    bx lr

@ ( n n -- )
@ drop wreg twice
Forthword_ DPOP2, INLINE_OPT, "pop2"
    pop2_
    bx lr

@ ( n n -- )
@ drop wreg three times
Forthword_ DPOP3, INLINE_OPT, "pop3"
    pop3_
    bx lr

@ (  -- addr )
@ current data stack pointer
Forthword_ SP, INLINE_OPT, "sp"
    sp_
    bx lr

@ ( addr -- i*x)
@ set data stack pointer to addr
Forthword_ STR_SP, INLINE_OPT, "!sp"
    str_sp_
    bx lr

@@@@@@@@@@@@@ Return Stack @@@@@@@@@@@@@

@ ( -- n ) (R: n --)
@ move TOR to wreg
Forthword_ RPOP, INLINE_OPT, "rpop"
    rpop_
    bx lr

@ ( -- ) (R: n -- )
@ Drop TOR
Forthword_ RNIP, INLINE_OPT, "rnip"
    rnip_
    bx lr

@ ( n -- n ) (R: -- n )
@ copy wreg to TOR
Forthword_ RPUSH, INLINE_OPT, "rpush"
    rpush_
    bx lr

@ ( -- n) (R: n -- n )
@ put a copy of TOR on wreg
Forthword_ R0, INLINE_OPT, "r0"
    r0_
    bx lr

@ (  -- n)
@ current return stack pointer address
Forthword_ RSP, INLINE_OPT, "rsp"
    rsp_
    bx lr

@ ( addr  -- ) (R: -- x*y)
@ set return stack pointer
@ must be called
Forthword_ RSP_W, INLINE_OPT, "rsp=w"
    @ keep the return address
    rsp_w_
    bx lr
