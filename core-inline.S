@ core-inline.S - inlinned words using core macros

@@@@@@@@@@@@@ Parameter Stack  Manipulation @@@@@@@@@@@@@@
@ ( n -- n n )
@ duplicate wreg
Forthword_ DPUSH, INLINE_OPT, "push"
    push_
    end_

@ ( n1 n2 -- n1 a  n2 )
@   d0 WR    d1 d0 WR
@ push register A onto top of data stack
Forthword_ DPUSHA, INLINE_OPT, "pusha"
    pusha_
    end_

@ ( n1 n2 -- n1 b  n2 )
@   d0 WR    d1 d0 WR
@ push register B onto top of data stack
Forthword_ DPUSHB, INLINE_OPT, "pushb"
    pushb_
    end_

@ ( n1 n2 -- n1 x  n2 )
@   d0 WR    d1 d0 WR
@ push register X onto top of data stack
Forthword_ DPUSHX, INLINE_OPT, "pushx"
    pushx_
    end_

@ ( n1 n2 -- n1 y  n2 )
@   d0 WR    d1 d0 WR
@ push register Y onto top of data stack
Forthword_ DPUSHY, INLINE_OPT, "pushy"
    pushy_
    end_

@ ( n1 n2 -- n2)
@ drop NOS, one before wreg.
Forthword_ NIP, INLINE_OPT, "nip"
    nip_
    end_

@ ( n1 n2 n3 -- n3)
@ drop NOS, one before wreg.
Forthword_ NIP2, INLINE_OPT, "nip2"
    nip2_
    end_

@ ( n1 n2 n3 n4 -- n4)
@ drop NOS, one before wreg.
Forthword_ NIP3, INLINE_OPT, "nip3"
    nip3_
    end_

@ ( n -- )
@ drop wreg
Forthword_ DPOP, INLINE_OPT, "pop"
    pop_
    end_

@ ( n n -- )
@ drop wreg twice
Forthword_ DPOP2, INLINE_OPT, "pop2"
    pop2_
    end_

@ ( n n -- )
@ drop wreg three times
Forthword_ DPOP3, INLINE_OPT, "pop3"
    pop3_
    end_

@ (  -- addr )
@ current data stack pointer
Forthword_ DSP, INLINE_OPT, "dsp"
    dsp_
    end_

@ ( addr -- i*x)
@ set data stack pointer to addr
Forthword_ DSP_W, INLINE_OPT, "dsp=w"
    dsp_w_
    end_

@@@@@@@@@@@@@ Return Stack @@@@@@@@@@@@@

@ ( -- n ) (R: n --)
@ move TOR to wreg
Forthword_ RPOP, INLINE_OPT, "rpop"
    rpop_
    end_

@ ( -- ) (R: n -- )
@ Drop TOR
Forthword_ RNIP, INLINE_OPT, "rnip"
    rnip_
    end_

@ ( n -- n ) (R: -- n )
@ copy wreg to TOR
Forthword_ RPUSH, INLINE_OPT, "rpush"
    rpush_
    end_

@ ( -- n) (R: n -- n )
@ put a copy of TOR on wreg
Forthword_ R0, INLINE_OPT, "r0"
    r0_
    end_

@ (  -- n)
@ current return stack pointer address
Forthword_ RSP, INLINE_OPT, "rsp"
    rsp_
    end_

@ ( addr  -- ) (R: -- x*y)
@ set return stack pointer
@ must be called
Forthword_ RSP_W, INLINE_OPT, "rsp=w"
    @ keep the return address
    rsp_w_
    end_
