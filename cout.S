@ cout.S - character output


@ ( -- emitaddr )
@ get ram address of emit defer
Forthword_ EMITADDR, 0, "emit#"
    user_ USER_EMIT
    bx lr

@ ( c -- )
@ fetch the emit vector and EXEC it. Will emit a character from wreg
Forthword_ PUTCHAR, 0, "putchar"
  b putchar

@ ( c -- )
@ fetch the emit vector and EXEC it. Will emit a character from wreg
Forthword_ EMIT, 0, "emit"
  push {lr}
  bl EMITADDR
  fetch_
  pop_lr_
  b EXEC

@ ( -- )
@ cause subsequent output appear at the beginning of the next line
Forthword_ CR, 0, "cr"
  push {lr}
  ten_
  bl EMIT
  lit8_ 13
  pop_lr_ 
  b EMIT

@ ( -- 32 )
@ put ascii code of the blank/space character to the stack
Forthword_ BL, 0, "bl"
    bl_
    bx lr
    


@ ( addr n -- )
@ print a counted string
Forthword_ TYPE, 0, "type"
   push {lr}
   iszero_
   beq.n TYPE_END
   
   rpush_a_
   rpush_b_
   pop_a_
   str_b_

TYPE1:
   a_cfetch_
   aplus1_
   bl EMIT
   bminus1_

TYPE2:
   bne.n TYPE1
   
   rpop_b_
   rpop_a_

TYPE_END:
   pop {pc}

