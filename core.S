@ core.S


@@@@@@@@@@@@@ Parameter Stack  Manipulation @@@@@@@@@@@@@@



@@@@@@@@@@@@@ Return Stack @@@@@@@@@@@@@


@ ( -- retaddr )
@ pop return onto data stack and exit caller
@ used if data in program mem and need an address to it
Forthword_ POPRET, 0, "popret"
    push_
    mov wreg, lr
    subs wreg, #1
    pop {pc}

@ ( -- n) (R: n -- n+1 )
@ get TOR and then increment TOR by 1 cell (32 bit)
@ assumes TOR content will be used for 32 bit memory access so
@ removes thumb bit flag
Forthword_ RTORPLUS, 0, "r>r+"
    push_
    pop {wreg}
    adds wreg, #0x04
    push {wreg}
    subs wreg, #0x05
    bx lr


@@@@@@@@@@@@@ Arithmatic @@@@@@@@@@@@@

@ ( n1 n2 -- n3)
@ add n1 and n2
Forthword_ PLUS, INLINE_OPT, "+"
  plus_
  bx lr

@ ( n1|u1 n2|u2 -- n3|u3 )
@ subtract n2 from n1
Forthword_ MINUS, INLINE_OPT, "-"
  minus_
  bx lr

@ ( u1|n1 u2|n2 -- u3|n3 )
@ signed multiply 32b x 32b = 32b
Forthword_ MULU, INLINE_OPT,  "*"
  ldm dsp!, {r0}
  muls wreg, r0
  bx lr


Forthword_ NEGATE, INLINE_OPT, "neg"
  neg_
  bx lr

@ ( n1 n2 -- n3 )
@ bitwise and
Forthword_ AND_, INLINE_OPT, "and"
  and_
  bx lr

@ ( n1 n2 -- n3 )
@ logical or
Forthword_ OR, INLINE_OPT, "or"
  or_
  bx lr

@ ( n1 n2 -- n3)
@ exclusive or
Forthword_ XOR, INLINE_OPT, "xor"
  xor_
  bx lr

@ ( n1 -- n2)
@ 1-complement of wreg
Forthword_ NOT, INLINE_OPT, "not"
  not_
  bx lr

@ ( n1 n2 -- flag)
@ flag is true if n1 is not equal to n2
Forthword_ NOTEQUAL, INLINE_OPT, "!="
  xor_
  bx lr

@ ( n1 n2 -- flag )
@ flag is true if wreg and NOS are equal
Forthword_ EQUAL, 0, "="
  ldm dsp!, {r0}
  subs wreg, r0
  subs wreg, #1
  sbcs wreg, wreg
  bx lr

@ ( n1 n2 -- flag)
@ flag is true if n1 is less than n2
Forthword_ LESS, 0, "<"
  ldm dsp!, {r0}
  cmp r0, wreg
  bge.n 1f
  movs wreg, #0
  mvns wreg, wreg
  bx lr
1:
  movs wreg, #0
  bx lr

@ ( n1 n2 -- flag )
@ flag is true if n1 is greater than n2
Forthword_ GREATER, 0, ">"
  ldm dsp!, {r0}     @ Get x1 into a register.
  cmp r0, wreg        @ Is x2 greater?
GREATER_CHK:
  ble.n 1f
  movs wreg, #0
  mvns wreg, wreg
  bx lr
1:
  movs wreg, #0
  bx lr

@ ( n1 -- flag )
@ flag is true if n1 is greater than 0
Forthword_ ZEROGREATER, 0, "0>"
  subs wreg, #0
  b.n GREATER_CHK

@ ( n1 -- flag )
@ flag is true if n1 is 0
Forthword_ ZEROEQUAL, INLINE_OPT, "0="
  zeroequal_
  bx lr


@ ( n1 -- flag)
@ flag is true if wreg is less than zero
forthword_ ZEROLESS, INLINE_OPT, "0<"
  zeroless_
  bx lr

@ ( -- -1 )
@ leaves the value -1 (true) on wreg
Forthword_ TRUE, INLINE_OPT, "true"
  true_
  bx lr

@ ( -- 0 )
@ place a value 0 in wreg
Forthword_ ZERO, INLINE_OPT, "0"
  zero_
  bx lr

@ ( n -- )
@ test wreg if zero
Forthword_ ZEROSENSE, INLINE_OPT, "0="
    zerosense_
    bx lr

@ ( n1 n2 -- n3)
@ logically shift n1 left n2 times
forthword_ LSHIFT, INLINE_OPT, "<<"
  lshift_
  bx lr

@ ( n1 n2 -- n3)
@ logically shift n1 right n2 times
forthword_ RSHIFT, INLINE_OPT, ">>"
  rshift_
  bx lr


@ ( a-addr -- n32 )
@ read 1 cell (32 bits) from RAM address
Forthword_ FETCH, INLINE_OPT, "@"
  mw_
  bx lr

@ ( A:n32 a-addr -- )
@ store a word (32 bits) in A register to RAM address
Forthword_ MW_A, 0, "@w=a"
  mw_a_
  bx lr


@ ( n32 a-addr -- )
@ add n32 to content of cell RAM address a-addr
Forthword_ PLUSSTORE, 0, "+!"
  ldm dsp!, {r0, r1} @ X is the new wreg after the store completes.
PLUSSTORE_do:
  ldr  r2, [wreg]     @ Load the current cell value
  adds r2, r0         @ Do the add
  str  r2, [wreg]     @ Store it back
  movs wreg, r1
  bx lr

@ ( n32 a-addr -- )
@ add 1 to content of cell RAM address a-addr
@ *w+=1
Forthword_ ONEPLUSSTORE, 0, "1+!"
  ldm dsp!, {r1}
  movs r0, #1
  b.n PLUSSTORE_do

@ ( a-addr -- n16 )
@ read half cell (16 bits) from RAM address
@ w=*wh
Forthword_ HFETCH, INLINE_OPT, "h@"
  hfetch_
  bx lr

@ ( a-addr A:n -- )
@ store a half word (16 bits) in A register to RAM address
@ *wh=a
Forthword_ AWHSTORE, 0, "a.h!"
  aw_str_
  bx lr

@ ( a-addr B:n -- )
@ store a half word (16 bits) in B register to RAM address
Forthword_ BWHSTORE, 0, "b.h!"
  bw_str_      
  bx lr

@ ( a-addr X:n -- )
@ store a half word (16 bits) in X register to RAM address
Forthword_ XWHSTORE, 0, "x.h!"
  xw_str_      
  bx lr

@ ( a-addr Y:n -- )
@ store a half word (16 bits) in Y register to RAM address
Forthword_ YWHSTORE, 0, "y.h!"
  yw_str_      
  bx lr

@ ( n16 a-addr -- )
@ add n16 to content of half cell RAM address a-addr
Forthword_ PLUSHSTORE, 0, "+h!"
  ldm dsp!, {r0, r1} @ X is the new wreg after the store completes.
PLUSHSTORE_do:
  ldrh r2, [wreg]     @ Load the current cell value
  adds r2, r0         @ Do the add
  strh r2, [wreg]     @ Store it back
  movs wreg, r1
  bx lr

@ ( a-addr -- )
@ add 1 to content of half cell RAM address a-addr
Forthword_ ONEPLUSHSTORE, 0, "1+h!"
  ldm dsp!, {r1}
  movs r0, #1
  b.n PLUSHSTORE_do

@ ( a-addr -- n8 )
@ read byte (8 bits) from RAM address
Forthword_ CFETCH, INLINE_OPT, "c@"
  cfetch_
  bx lr

@ ( c a-addr -- )
@ store a single byte to RAM address
Forthword_ CSTORE, 0, "c!"
  ldm dsp!, {r0, r1} @ X is the new wreg after the store completes.
  strb r0, [wreg]     @ Popping both saves a cycle.
  movs wreg, r1
  bx lr

@ ( a-addr -- )
@ store 0 (16 bits) to RAM address
Forthword_ ZEROCSTORE, 0, "0c!"
  movs r0, #0
  strb r0, [wreg]
  pop_
  bx lr

@ ( c a-addr -- )
@ add c byte to content of byte RAM address a-addr
Forthword_ PLUSCSTORE, 0, "+c!"
  ldm dsp!, {r0, r1} @ X is the new wreg after the store completes.
PLUSCSTORE_do:
  ldrb r2, [wreg]     @ Load the current cell value
  adds r2, r0         @ Do the add
  strb r2, [wreg]     @ Store it back
  movs wreg, r1
  bx lr

@ ( a-addr -- )
@ add 1 to content of byte cell RAM address a-addr
Forthword_ ONEPLUSCSTORE, 0, "1+c!"
  ldm dsp!, {r1}
  movs r0, #1
  b.n PLUSCSTORE_do

@ ( n1 n2 -- n2 ) A: n1
@ Remove next on stack and write to A register (Extended VM)
Forthword_ NIPTOA, INLINE_OPT, "nip>a"
  niptoa_
  bx lr

@ ( n1 n2 -- n2 ) B: n1
@ Remove next on stack and write to B register (Extended VM)
Forthword_ NIPTOB, INLINE_OPT, "nip>b"
  niptob_
  bx lr

@ ( n -- ) A: n
@ Move wreg to A register (Extended VM)
Forthword_ TO_A, INLINE_OPT, ">a"
    toa_
    bx lr

@ ( n -- ) B: n
@ Move wreg to B register (Extended VM)
Forthword_ TO_B, INLINE_OPT, ">b"
    tob_
    bx lr

@ ( n -- n ) A: n
@ copy wreg to A register (Extended VM)
Forthword_ _A, INLINE_OPT, ":a"
    copytoa_
    bx lr

@ ( n -- n ) B: n
@ copy wreg to B register (Extended VM)
Forthword_ _B, INLINE_OPT, ":b"
    copytob_
    bx lr

@ ( -- n )
@ read the A register (Extended VM)
Forthword_ A_, INLINE_OPT, "a"
    geta_
    bx lr

@ ( -- n )
@ read the B register (Extended VM)
Forthword_ B_, INLINE_OPT, "b"
    getb_
    bx lr

@ ( -- n )
@ Read a word (32bit) from memory pointed to by register A (Extended VM)
Forthword_ AFETCH, INLINE_OPT, "a@"
    afetch_
    bx lr

@ ( n -- )
@ store a word to RAM address pointed to by areg
Forthword_ ASTORE, 0, "a!"
  str wreg, [areg]
  pop_
  bx lr

@ ( -- n )
@ Read a half word (32bit) from memory pointed to by register A (Extended VM)
Forthword_ AHFETCH, INLINE_OPT, "ah@"
    ahfetch_
    bx lr

@ ( h -- )
@ store a half word to RAM address pointed to by areg
Forthword_ AHSTORE, 0, "ah!"
  strh wreg, [areg]
  pop_
  bx lr

@ ( -- n )
@ Read a byte from memory pointed to by register A (Extended VM)
Forthword_ ACFETCH, INLINE_OPT, "ac@"
    acfetch_
    bx lr

@ ( c -- )
@ store a single byte to RAM address pointed to by areg
Forthword_ ACSTORE, 0, "ac!"
  strb wreg, [areg]
  pop_
  bx lr

@ ( -- )
@ update register A with post increment 4+ from last memory operation (Extended VM)
Forthword_ APLUS, INLINE_OPT, "a+"
    aplus_
    bx lr

@ ( -- )
@ update register A with post increment 2+ from last memory operation (Extended VM)
Forthword_ AHPLUS, INLINE_OPT, "ah+"
    ahplus_
    bx lr


@ ( -- )
@ update register A with post increment 1+ from last memory operation (Extended VM)
Forthword_ ACPLUS, INLINE_OPT, "ac+"
    acplus_
    bx lr

@ ( len -- len/2 rem)
@ convert byte length to word length plus remainder
Forthword_ BTOW, 0, "btow"
    push {lr}
    push_        @ ( len len )
    twoslash_   @ ( len len/2 )
    bl TUCK     @ ( len/2 len len/2 )
    twostar_    @ ( len/2 len len' )
    minus_      @ ( len/2 rem )
    pop {pc}

@ (start dest count -- )
@ count is the number of bytes to copy and must be a multiple of two
@ copy ram using half words.  Assumes no overlap.
Forthword_ MCPY, 0, "mcpy"
    push {lr}
    niptoa_         @ ( start count ) A: dest
MCPY_B:
    dupzerosense_   @ ( start count )
    beq.n MCPY_END
    tob_            @ ( start ) B: count
    push_            @ ( start start )
    hfetch_         @ ( start val )
    geta_           @ ( start val dest )
    bl HSTORE       @ ( start )
    ahplus_
    twoplus_        @ ( start+2 )
    getb_           @ ( start+2 count )
    twominus_       @ ( start+2 count-2 )
    b.n MCPY_B

MCPY_END:
    pop_lr_
    b DDROP
