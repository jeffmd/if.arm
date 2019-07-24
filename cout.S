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

@ ( -- )
@ turn emit off
Forthword_ EMIT_OFF, 0, "emit.off"
  push {lr}
  @ reset output source for emit
  lit32_ NOOP
  y_w_
  bl EMITADDR
  mw_y_
  pop {pc}

@ ( -- )
@ turn emit on for default output
Forthword_ EMIT_ON, 0, "emit.on"
  push {lr}
  @ reset output source for emit
  lit32_ PUTCHAR
  y_w_
  bl EMITADDR
  mw_y_
  pop {pc}

@ ( c -- )
@ fetch the emit vector and EXEC it. Will emit a character from wreg
Forthword_ EMIT, 0, "emit"
  push {lr}
  push_
  bl EMITADDR
  mw_
  pop_lr_
  b EXEC

@ ( -- )
@ cause subsequent output appear at the beginning of the next line
Forthword_ CR, 0, "cr"
  push {lr}
  lit_ 10
  bl EMIT
  lit_ 13
  pop_lr_ 
  b EMIT

@ ( -- 32 )
@ put ascii code of the blank/space character to the stack
Forthword_ BL, INLINE_OPT, "bl"
    bl_
    bx lr
    
@ ( addr n -- )
@ print a counted string
Forthword_ TYPE, 0, "type"
   push {lr}
   iszero_
   beq.n TYPE_END
   
   rpusha_
   rpushb_
   popa_
   b_w_

TYPE1:
   cma_
   a_plus1_
   bl EMIT
   b_minus1_

TYPE2:
   bne.n TYPE1
   
   rpopb_
   rpopa_

TYPE_END:
   pop {pc}

