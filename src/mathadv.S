@ mathadv.S - advanced math

.if 0
@ Multiply unsigned 32*32 = 64
@ ( u2 u1 -- ud )
Forthword_ UMSTAR, 0, "um*"
.if rpi2

    ldr r1, [dsp]
    umull r1, wreg, r1, wreg @ Unsigned long multiply 32*32=64
    str r1, [dsp]
    bx lr
    
.else
  @ To be calculated: wreg * d0
  @ d0 = high 32bit
  @ wreg = low 32bit
  y_d0            @ ( u2 u1 Y:u2 )
  @ Calculate low part in hardware:
  @ Save the low part for later
  x_w_            @ ( u2 u1 X:u1 )
  @ Gives complete low-part of result
  muls yreg, wreg 

  @ Calculate high part:
  lsrs r1, r0,  #16 @ Shifted half
  lsrs r2, wreg, #16 @ Shifted half

    movs r3, r1  @ High-High
    muls r3, r2

    @ Low-High and High-Low
    uxth wreg, wreg
    uxth r0, r0

    muls wreg, r1
    muls r0, r2
    adds wreg, r0

    lsrs wreg, #16 @ Shift accordingly
    adds wreg, r3  @ Add together
    bx lr

.endif

@ ( n n -- d)
@ multiply 2 signed cells to a double cell
Forthword_ MSTAR, 0, "m*"
@ Multiply signed 32*32 = 64
@ ( n n -- d )

.if rpi2

    ldr r0, [dsp]
    smull r0, wreg, r0, wreg @ Signed long multiply 32*32=64
    str r0, [dsp]
    bx lr

.else

    ldr r0, [dsp]
    movs r1, r0, asr #31 @ Turn MSB into 0xffffffff or 0x00000000
    beq.n 1f
    @ - * ?
      rsbs r0, r0, #0
      str r0, [dsp]

      movs r0, wreg, asr #31 @ Turn MSB into 0xffffffff or 0x00000000
      beq.n 2f @ - * +

      @ - * -
      rsbs wreg, wreg, #0
      b.n UMSTAR

1:  @ + * ?
    movs r0, wreg, asr #31 @ Turn MSB into 0xffffffff or 0x00000000
    beq.n UMSTAR @ + * +
    @ + * -
    rsbs wreg, wreg, #0

    @ - * + or + * -
2:  push {lr}
    bl UMSTAR
    bl DNEG
    pop {pc}

.endif

Forthword_ UM_DIVMOD, 0, "um/mod"
@ ( ud u -- u u ) Dividend Divisor -- Rest Ergebnis
@ 64/32 = 32 Rest 32

@  push {lr}
@  pushdaconst 0
@  bl ud_slash_mod
@  drop
@  nip
@  pop {pc}

  push {r4}
                     @ wreg : Divisor
  ldr  r0, [dsp, #4] @ (LL) Dividend L
  ldr  r1, [dsp, #0] @ (L)  Dividend H
  movs r2, #0        @ (H)  Shift L

  movs r4, #0        @ Result

  @ Loop in r3:
  movs r3, #32

1:lsls r4, #1 @ Shift result
  
  adds r0, r0 @ Shift through first three registers
  adcs r1, r1
  adcs r2, r2 

  @ Compare the top two registers to divisor
  cmp wreg, r2  @ Compare low part
  bhi.n 2f      @ If lower or same:
    subs r2, wreg  @  Low-part first
    adds r4, #1  @ Set bit in result
2:
  subs r3, #1
  bne.n 1b
  @ r3 is Zero now. No need to clear.

  @ Shifted 32 places - r0 (LL) is shifted out completely now. 
  @ Result is kept as it is and may overflow

  @ Loop in r3:
  movs r3, #32

1:lsls r4, #1 @ Shift result
  
  adds r1, r1 @ Shift through two registers only
  adcs r2, r2

  @ Compare the top two registers to divisor
  cmp wreg, r2  @ Compare low part
  bhi.n 2f      @ If lower or same:
    subs r2, wreg  @  Low-part first
    adds r4, #1  @ Set bit in result
2:
  subs r3, #1
  bne.n 1b
  @ r3 is Zero now. No need to clear.

  adds dsp, #4
  str r2, [dsp] @ Remainder
  movs wreg, r4

  pop {r4}
  bx lr


Forthword_ M_DIVMOD, 0, "m/mod"
@ Signed symmetric divide 64/32 = 32 remainder 32
@ ( d n -- n n )
@  push {lr}
@  pushdatos                 @ s>d
@  movs wreg, wreg, asr #31    @ Turn MSB into 0xffffffff or 0x00000000
@  bl d_slash_mod
@  drop
@  nip
@  pop {pc}

  @ Check Divisor
  push {lr}
  movs r0, wreg, asr #31 @ Turn MSB into 0xffffffff or 0x00000000
  beq.n 2f
    @ ? / -
    rsbs wreg, wreg, #0 @ Negate
    bl RROT
    movs r0, wreg, asr #31 @ Turn MSB into 0xffffffff or 0x00000000
    beq.n 1f
    @ - / -
    bl DNEG
    bl ROT
    bl UM_DIVMOD

    swap_
    rsbs wreg, wreg, #0 @ Negate for Negative remainder
    swap_
    pop {pc}

1:  @ + / -
    bl ROT
    bl UM_DIVMOD
    rsbs wreg, wreg, #0 @ Negate for Negative result
    pop {pc}

2:  @ ? / +
    bl RROT
    movs r0, wreg, asr #31 @ Turn MSB into 0xffffffff or 0x00000000
    beq.n 3f
    @ - / +
    bl DNEG
    bl ROT

    bl UM_DIVMOD

    rsbs wreg, wreg, #0 @ Negate for Negative result
    swap_
    rsbs wreg, wreg, #0 @ Negate for Negative remainder
    swap_
    pop {pc}

3:  @ + / +
    bl ROT
    bl UM_DIVMOD
    pop {pc}

@ Tool for ud/mod

  .macro division_step
    @ Shift the long chain of four registers.
    lsls r0, #1
    adcs r1, r1
    adcs r2, r2
    adcs r3, r3

    @ Compare Divisor with top two registers
    cmp r3, r5 @ Check high part first
    bhi.n 1f
    blo.n 2f

    cmp r2, r4 @ High part is identical. Low part decides.
    blo.n 2f

    @ Subtract Divisor from two top registers
1:  subs r2, r4 @ Subtract low part
    sbcs r3, r5 @ Subtract high part with carry

    @ Insert a bit into Result which is inside LSB of the long register.
    adds r0, #1
2:
  .endm

Forthword_ UD_SLASHMOD, 0, "ud/mod"
         @ Unsigned divide 64/64 = 64 remainder 64
         @ ( ud1 ud2 -- ud ud)
         @ ( 1L 1H 2L wreg: 2H -- Rem-L Rem-H Quot-L wreg: Quot-H )
   push {r4, r5}

   @ ( DividendL DividendH DivisorL DivisorH -- RemainderL RemainderH ResultL ResultH )
   @   8         4         0        wreg      -- 8          4          0       wreg


   @ Shift-High Shift-Low Dividend-High Dividend-Low
   @         r3        r2            r1           r0

   movs r3, #0
   movs r2, #0
   ldr  r1, [dsp, #4]
   ldr  r0, [dsp, #8]

   @ Divisor-High Divisor-Low
   @          r5           r4

ud_slash_mod_internal:
   movs r5, wreg
   ldr  r4, [dsp, #0]

   @ For this long division, we need 64 individual division steps.
   movs wreg, #64

3: division_step
   subs wreg, #1
   bne.n 3b

   @ Now place all values to their destination.
   movs wreg, r1       @ Result-High
   str  r0, [dsp, #0] @ Result-Low
   str  r3, [dsp, #4] @ Remainder-High
   str  r2, [dsp, #8] @ Remainder-Low

   pop {r4, r5}
   bx lr

Forthword_ D_SLASHMOD, 0, "d/mod"
@ Signed symmetric divide 64/64 = 64 remainder 64
@ ( d1 d2 -- d d )
@ ( 1L 1H 2L wreg: 2H -- Rem-L Rem-H Quot-L wreg: Quot-H )
  @ Check Divisor
  push {lr}
  movs r0, wreg, asr #31 @ Turn MSB into 0xffffffff or 0x00000000
  beq.n 2f
    @ ? / -
    bl DNEG
    bl DSWAP
    movs r0, wreg, asr #31 @ Turn MSB into 0xffffffff or 0x00000000
    beq.n 1f
    @ - / -
    bl DNEG
    bl DSWAP
    bl UD_SLASHMOD

    bl DSWAP
    bl DNEG @ Negative remainder
    bl DSWAP
    pop {pc}

1:  @ + / -
    bl DSWAP
    bl UD_SLASHMOD
    bl DNEG  @ Negative result
    pop {pc}

2:  @ ? / +
    bl DSWAP
    movs r0, wreg, asr #31 @ Turn MSB into 0xffffffff or 0x00000000
    beq.n 3f
    @ - / +
    bl DNEG
    bl DSWAP

    bl UD_SLASHMOD

    bl DNEG @ Negative result
    bl DSWAP
    bl DNEG @ Negative remainder
    bl DSWAP
    pop {pc}

3:  @ + / +
    bl DSWAP
    bl UD_SLASHMOD
    pop {pc}

@ ( u1 u2 -- rem quot )
@ unsigned 32b division with modulus result
Forthword_ U_DIVMOD, 0, "u/mod"
@ ARM provides no remainder operation, so we fake it by un-dividing and subtracting.
  .if rpi2

  ldm dsp!, {r0}       @ Get u1 into a register
  movs r1, wreg         @ Back up the divisor in X.
  udiv wreg, r0, wreg    @ Divide: quotient in wreg.
  muls r1, wreg, r1     @ Un-divide to compute remainder.
  subs r0, r1          @ Compute remainder.
  subs dsp, #4
  str r0, [dsp]
  bx lr
    
  .else

  movs r1, wreg
  ldm dsp!, {wreg}

  @ Catch divide by zero..
  cmp r1, #0
  bne.n 1f
    zero_           @ Null
    bx lr
1:

  @ Shift left the denominator until it is greater than the numerator
  movs r2, #1
  movs r3, #0
  cmp wreg, r1
  bls.n 3f
  adds r1, #0    @ Don't shift if denominator would overflow
  bmi.n 3f

2:lsls r2, #1
  lsls r1, #1
  bmi.n 3f
  cmp wreg, r1
  bhi.n 2b

3:cmp wreg, r1
  bcc.n 4f         @ if (num>denom)
  subs wreg, r1     @ numerator -= denom
  orrs r3, r2      @ result(r3) |= bitmask(r2)

4:lsrs r1, #1      @ denom(r1) >>= 1
  lsrs r2, #1      @ bitmask(r2) >>= 1
  bne.n 3b

  push_
  movs wreg, r3
  bx lr
  .endif
  
@ ( n1 n2 -- rem quot )
@ signed division with remainder
Forthword_ DIVMOD, 0, "/mod"
@ ARM provides no remainder operation, so we fake it by un-dividing and subtracting.
.if rpi2

  ldm dsp!, {r0}       @ Get u1 into a register
  movs r1, wreg         @ Back up the divisor in X.
  sdiv wreg, r0, wreg    @ Divide: quotient in wreg.
  muls r1, wreg, r1     @ Un-divide to compute remainder.
  subs r0, r1          @ Compute remainder.
  subs dsp, #4
  str r0, [dsp]
  bx lr

.else

  push {lr}
  movs r0, wreg
  ldm dsp!, {wreg}
  @     wreg: Dividend

  cmp wreg, #0
  bge.n divmod_plus
  rsbs wreg, wreg, #0

divmod_minus:
    cmp r0, #0
    bge.n divmod_minus_plus

divmod_minus_minus:
      rsbs r0, r0, #0
      push_
      movs wreg, r0
      bl U_DIVMOD
      movs r0, wreg
      ldm dsp!, {wreg}
      rsbs wreg, wreg, #0
      push_
      movs wreg, r0
      pop {pc}

divmod_minus_plus:
      push_
      mov wreg, r0
      bl U_DIVMOD
      movs r0, wreg
      ldm dsp!, {wreg}
      rsbs r0, r0, #0
      rsbs wreg, wreg, #0
      push_
      movs wreg, r0
      pop {pc}

divmod_plus:
    cmp r0, #0
    bge.n divmod_plus_plus

divmod_plus_minus:
      rsbs r0, r0, #0
      push_
      movs wreg, r0
      bl U_DIVMOD
      rsbs wreg, wreg, #0
      pop {pc}

divmod_plus_plus:
      push_
      mov wreg, r0
      bl U_DIVMOD
      pop {pc}
.endif

@ ( n1 n2 -- n1/n2 )
@ 32bit/32bit = 32bit
.if rpi2

Forthword_ DIV, INLINE_OPT, "/"
  ldm dsp!, {r0}       @ Get n1 into a register
  sdiv wreg, r0, wreg    @ Divide !
  bx lr

.else


.endif

.endif

@ ( n1 n2 -- rem quot )
@ quot = n1/n2
@ signed division with remainder
Forthword_ DIVMOD, 0, "/mod"
  x_d0_
  y_w_ 
  d_w_
  dsp_
  do_ div
  d_
  end_

Forthword_ DIV, 0, "/" 
  do_ DIVMOD
  d_sub_1_
  end_
