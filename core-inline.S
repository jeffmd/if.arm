@ core-inline.S - inlinned words using core macros
@ push pu p+ | pop pp p- | w=[x] [x] x@ | !x x=w | x! [x]! [x]=w | d0!x x=d0
@ @ [w] w=[w] | ! [w]=d0

@@@@@@@@@@@@@ Parameter Stack  Manipulation @@@@@@@@@@@@@@
@ ( n -- n n )
@ duplicate wreg
Forthword_ DPUSH, INLINE_OPT, "push"
    push_
    bx lr

@ ( n -- n n n )
@ push WR onto top of data stack twice
Forthword_ DPUSH2, INLINE_OPT, "push2"
    push2_
    bx lr

@ ( n1 n2 -- n1 a  n2 )
@   d0 WR    d1 d0 WR
@ push register A onto top of data stack
Forthword_ DPUSHA, INLINE_OPT, "push.a"
    push_a_
    bx lr

@ ( n1 n2 -- n1 b  n2 )
@   d0 WR    d1 d0 WR
@ push register B onto top of data stack
Forthword_ DPUSHB, INLINE_OPT, "push.b"
    push_b_
    bx lr

@ ( n1 n2 -- n1 x  n2 )
@   d0 WR    d1 d0 WR
@ push register X onto top of data stack
Forthword_ DPUSHX, INLINE_OPT, "push.x"
    push_x_
    bx lr

@ ( n1 n2 -- n1 y  n2 )
@   d0 WR    d1 d0 WR
@ push register Y onto top of data stack
Forthword_ DPUSHY, INLINE_OPT, "push.y"
    push_y_
    bx lr

@ ( n1 -- [ n1 n1 ] | 0)
@ duplicate wreg if non-zero
Forthword_ QPUSH, 0, "?push"
    iszero_
    beq.n PFA_QDUP1
    push_
PFA_QDUP1:
    bx lr

@ ( n1 n2 -- n2 n1)
@ swaps the two top level stack cells
Forthword_ SWAP, INLINE_OPT, "swap"
    swap_
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

@ ( x1 x2 -- x1 x2 x1 )
@ Place a copy of x1 on top of the stack
Forthword_ OVER, INLINE_OPT, "over"
    over_
    bx lr

@ ( x1 x2 -- x1 x2 x1 x2)
@ Place a copy of x1 and x2 on top of the stack
Forthword_ TWOOVER, 0, "2over"
    over_
    b.n OVER

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
Forthword_ RP, INLINE_OPT, "rp"
    rpfetch_
    bx lr

@ ( addr  -- ) (R: -- x*y)
@ set return stack pointer
@ must be called
Forthword_ STR_RP, INLINE_OPT, "!rp"
    @ keep the return address
    str_rp_
    bx lr
