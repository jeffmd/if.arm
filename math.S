@ math.S

@ ( n1 n2 -- n1|n2 )
@ compare two values leave the smaller one
Forthword_ MIN, 0, "min"
  ldm dsp!, {r0}
  cmp r0, wreg
  bge.n 1f
  movs wreg, r0
1:
  bx lr

@ ( n1 n2 -- n1|n2 )
@ compare two values, leave the bigger one
Forthword_ MAX, 0, "max"
  ldm dsp!, {r0}
  cmp r0, wreg
  blt.n 1f
  mov wreg, r0
1:
  bx lr

@ ( u1 u2 -- flag )
@ compare two unsigned numbers, returns true flag if u1 is less then or equal to u2
Forthword_ ULESSEQUAL, 0, "u<="
    push {lr}
    bl UGREATER
    not_
    pop {pc}

@ ( u1 u2 -- flag )
@ compare two unsigned numbers, returns true flag if u1 is greater then or equal to u2
Forthword_ UGREATEREQUAL, 0, "u>="
    push {lr}
    bl ULESS
    not_
    pop {pc}

@ ( n1 -- u1 )
@ get the absolute value
Forthword_ ABS, 0, "abs"
  dupzerosense_
  bpl.n 1f
  neg_
1:
  bx lr
  
@ ( n -- -n )
@ negate a double word
Forthword_ DNEG, 0, "dneg"
  ldr r0, [dsp]
  movs r1, #0
  mvns r0, r0
  mvns wreg, wreg
  adds r0, #1
  adcs wreg, r1
  str r0, [dsp]
  bx lr

