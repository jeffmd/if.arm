@ cout.S - character output


@ ( -- emitaddr )
@ get ram address of emit defer
Forthword_ EMITADDR, 0, "emit#"
    user_ USER_EMIT
    end_

@ ( c -- )
@ fetch the emit vector and EXEC it. Will emit a character from wreg
Forthword_ PUTCHAR, 0, "putchar"
  end_do_ putchar

@ ( -- )
@ turn emit off
Forthword_ EMIT_OFF, 0, "emit.off"
  @ reset output source for emit
  lit32_ NOOP
  y_w_
  do_ EMITADDR
  mw_y_
  end_

@ ( -- )
@ turn emit on for default output
Forthword_ EMIT_ON, 0, "emit.on"
  @ reset output source for emit
  lit32_ PUTCHAR
  y_w_
  do_ EMITADDR
  mw_y_
  end_

@ ( c -- )
@ fetch the emit vector and EXEC it. Will emit a character from wreg
Forthword_ EMIT, 0, "emit"
  push_
  do_ EMITADDR
  mw_
  end_do_ EXEC

@ ( -- )
@ cause subsequent output appear at the beginning of the next line
Forthword_ CR, 0, "cr"
  lit_ 10
  do_ EMIT
  lit_ 13
  end_do_ EMIT

@ ( -- 32 )
@ put ascii code of the blank/space character to the stack
Forthword_ BL, INLINE_OPT, "bl"
    bl_
    end_
    
@ ( addr n -- )
@ print a counted string
Forthword_ TYPE, 0, "type"
   push_lr_
   iszero_
   if_0_ TYPE_END
   
   rpusha_
   rpushb_
   popa_
   b_w_

TYPE1:
   cma_
   a_plus1_
   do_ EMIT
   b_minus1_

TYPE2:
   if_not_0_ TYPE1
   
   rpopb_
   rpopa_

TYPE_END:
   end_
