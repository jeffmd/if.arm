@ defer.S
@ words that support defer

@ ( -- addr )
@ runtime part of user
@ get the address of the user var which is located at the return address of the caller
@ then skip index var for return
@Forthword_ DOUSER, 0, "(user)"
    @ lr has address of variable
    @pushtos_
    @mov r0, lr
    @ get rid of thumb flag in address
    @sub r0, #1
    @ldrh tos, [r0]
    @add tos, sysvar
    @ calculate return address
    @add r0, #3
    @bx r0

@ other option, inline code
    @pushtos_
    @mov tos, #1
    @add tos, sysvar
    @bx lr

@ dodefer - execute a deferred word
@ defer setup as:
@ push {lr}
@ bl DODEFER
@ .word deferptr
@ does not return to defer callee
Forthword_ DODEFER, 0, "(def)"
  push_
  mov wreg, lr
  subs wreg, #1 @ doing memory access, do not want thumb bit
  ldr wreg, [wreg]
  bl EXEC
  pop {pc}
  
