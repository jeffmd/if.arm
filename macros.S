@ macros.S

wreg .req r0 @ parameter top of stack [TOS] register
xreg .req r3 @ X register 
yreg .req r4 @ X register
@ sysvar .req r4 @ system variables base pointer
areg .req r5 @ A register - non-volatile: user must preserve
breg .req r6 @ B register - non-volatile: user must preserve
dsp .req r7 @ holds the Forth VM Parameter/Data stack pointer

@ header flags
.set HFLAGS, 0xFF
@ low byte is word count : 0 - 255
@ high byte is flags for word
@ enable inlining of word
@ bit 0 : enable inlinning
.set INLINE_OPT_FB, 0
.set INLINE_OPT, 1 << INLINE_OPT_FB

@ bit 3 : disable interpret execution ie compile only
.set COMPILE_ONLY_FB, 3
@ set immediate word as compile time only execution
@ disable interpret execution : & with word count flag ie: 0xFF04 & COMPILE_ONLY
.set COMPILE_ONLY, 1 << COMPILE_ONLY_FB

@ bit 7 : immediate execution when in compile state
@ enable immediate execution : & with word count flag ie: 0xFF04 & IMMEDIATE_EN
.set IMMEDIATE_EN_FB, 7
.set IMMEDIATE_EN, 1 << IMMEDIATE_EN_FB

@ forth flags
@ bit 0 : rcall was last instruction
.set LAST_RCALL_FB, 0
@ bit 1 : call was last instruction
.set LAST_CALL_FB, 1
@ if bit 0 and 1 are cleared then last instruction was an inline or tail call optimization was disabled by word
@ bit 2 : disable tail call optimization
.set DIS_CALL_OPT_FB, 2


.macro opdat op, reg, sym
  \op \reg, [r1, #(\sym-Data)]
.endm

@ Inline macros

.macro rpush_ @ put copy of wr on return stack
    push {wreg}
.endm

.macro rpush_x_ @ put copy of X on return stack
    push {xreg}
.endm

.macro rpush_y_ @ put copy of Y on return stack
    push {yreg}
.endm

.macro rpush_a_ @ put copy of A on return stack
    push {areg}
.endm

.macro rpush_b_ @ put copy of B on return stack
    push {breg}
.endm

.macro rpush_sp_ @ put copy of data stack pointer on return stack
    push {dsp}
.endm

.macro rpop_
  pop {wreg}
.endm

.macro rpop_a_
  pop {areg}
.endm

.macro rpop_b_
  pop {breg}
.endm

.macro rpop_x_
  pop {xreg}
.endm

.macro rpop_y_
  pop {yreg}
.endm

.macro rnip_ @ drop TOR
    adds sp, #4
.endm

.macro rnip2_ 
    adds sp, #8
.endm

.macro rnip3_ 
    adds sp, #12
.endm

.macro r0_str_a_
  ldr areg, [sp]
.endm

.macro r0_str_b_
  ldr breg, [sp]
.endm

.macro r0_str_x_
  ldr xreg, [sp]
.endm

.macro r0_str_y_
  ldr yreg, [sp]
.endm

.macro r1_str_a_
  ldr areg, [sp, #4]
.endm

.macro r1_str_b_
  ldr breg, [sp, #4]
.endm

.macro r1_str_x_
  ldr xreg, [sp, #4]
.endm

.macro r1_str_y_
  ldr yreg, [sp, #4]
.endm

.macro r2_str_a_
  ldr areg, [sp, #8]
.endm

.macro r2_str_b_
  ldr breg, [sp, #8]
.endm

.macro r2_str_x_
  ldr xreg, [sp, #8]
.endm

.macro r2_str_y_
  ldr yreg, [sp, #8]
.endm

.macro str_r0_
  str wreg, [sp] 
.endm

.macro a_str_r0_
  str areg, [sp] 
.endm

.macro b_str_r0_
  str breg, [sp] 
.endm

.macro x_str_r0_
  str xreg, [sp] 
.endm

.macro y_str_r0_
  str yreg, [sp] 
.endm

.macro str_r1_
  str wreg, [sp, #4] 
.endm

.macro a_str_r1_
  str areg, [sp, #4] 
.endm

.macro b_str_r1_
  str breg, [sp, #4] 
.endm

.macro x_str_r1_
  str xreg, [sp, #4] 
.endm

.macro y_str_r1_
  str yreg, [sp, #4] 
.endm

.macro str_r2_
  str wreg, [sp, #8] 
.endm

.macro a_str_r2_
  str areg, [sp, #8] 
.endm

.macro b_str_r2_
  str breg, [sp, #8] 
.endm

.macro x_str_r2_
  str xreg, [sp, #8] 
.endm

.macro y_str_r2_
  str yreg, [sp, #8] 
.endm

.macro rp_
  mov wreg, sp
.endm

.macro rp_str_a_
  mov areg, sp
.endm

.macro rp_str_b_
  mov breg, sp
.endm

.macro rp_str_x_
  mov xreg, sp
.endm

.macro rp_str_y_
  mov yreg, sp
.endm

.macro str_rp_
  mov sp, wreg
.endm

.macro r0_
  ldr wreg, [sp]
.endm

.macro r1_
  ldr wreg, [sp, #4]
.endm

.macro r2_
  ldr wreg, [sp, #8]
.endm

.macro pop_lr_ @ pop lr from return stack into lr
.if rpi2
  pop {lr}
.else
  pop {r0}
  mov lr, r0
.endif
.endm

.macro sysv_ sym
    #(\sym - sysvar_base)
.endm

@ test with 8 bit constant
.macro bittest_ v
    movs r1, #\v
    tst wreg, r1
    pop_
.endm

.macro pushsysv_ sym
    push_
    ldr wreg, 1f
    bx lr
.balign 4
1:
    .word \sym
.balign 2
.endm

.macro douser_ sym
    movs wreg, #(\sym-sysvar_base)
    adds wreg, sysvar
    bx lr
.endm


@ Push small 8 bit constant on datastack
.macro dolit8_ val
  movs wreg, #\val
.endm

@ Push small 16 bit constant on datastack
.macro dolit16_ val
  movs wreg, #(\val/256)
  lsls wreg, #8
  adds wreg, #(\val & 255)
.endm

@ push a 32 bit inline val on datastack
.macro dolit32_ val
  bl ICFETCH
  .word \val
.endm

.macro d0_
  ldr wreg, [dsp]
.endm

.macro d1_
  ldr wreg, [dsp, #4]
.endm

.macro d2_
  ldr wreg, [dsp, #8]
.endm

.macro str_d0_
  str wreg, [dsp] @ Replace it with wr.
.endm

.macro str_d1_
  str wreg, [dsp, #4] @ Replace it with wr.
.endm

.macro str_d2_
  str wreg, [dsp, #8] @ Replace it with wr.
.endm

.macro a_str_d0_
  str areg, [dsp] 
.endm

.macro a_str_d1_
  str areg, [dsp, #4] 
.endm

.macro a_str_d2_
  str areg, [dsp, #8] 
.endm

.macro b_str_d0_
  str breg, [dsp] 
.endm

.macro b_str_d1_
  str breg, [dsp, #4] 
.endm

.macro b_str_d2_
  str breg, [dsp, #8] 
.endm

.macro x_str_d0_
  str xreg, [dsp] 
.endm

.macro x_str_d1_
  str xreg, [dsp, #4] 
.endm

.macro x_str_d2_
  str areg, [dsp, #8] 
.endm

.macro y_str_d0_
  str yreg, [dsp] 
.endm

.macro y_str_d1_
  str yreg, [dsp, #4] 
.endm

.macro y_str_d2_
  str areg, [dsp, #8] 
.endm

.macro d0_str_a_
  ldr areg, [dsp]
.endm

.macro d1_str_a_
  ldr areg, [dsp, #4]
.endm

.macro d2_str_a_
  ldr areg, [dsp, #8]
.endm

.macro d0_str_b_
  ldr breg, [dsp]
.endm

.macro d1_str_b_
  ldr breg, [dsp, #4]
.endm

.macro d2_str_b_
  ldr breg, [dsp, #8]
.endm

.macro d0_str_x_
  ldr xreg, [dsp]
.endm

.macro d1_str_x_
  ldr xreg, [dsp, #4]
.endm

.macro d2_str_x_
  ldr xreg, [dsp, #8]
.endm

.macro d0_str_y_
  ldr yreg, [dsp]
.endm

.macro d1_str_y_
  ldr yreg, [dsp, #4]
.endm

.macro d2_str_y_
  ldr yreg, [dsp, #8]
.endm

.macro top1_ @ move stack pointer down one cell
   subs dsp, #4
.endm

.macro top2_ @ move stack pointer down two cells
   subs dsp, #8
.endm

.macro top3_ @ move stack pointer down three cells
   subs dsp, #12
.endm

.macro push_ @ duplicate wr
.if rpi2
  str.w wreg, [dsp, #-4]!
.else
  top1_
  str_d0_
.endif
.endm

.macro push2_ 
  top2_
  str_d0_
  str_d1_
.endm

.macro push_a_ 
  top1_
  a_str_d0_
.endm

.macro push_b_ 
  top1_
  b_str_d0_
.endm

.macro push_x_ 
  top1_
  x_str_d0_
.endm

.macro push_y_ 
  top1_
  y_str_d0_
.endm

.macro pop_ @ pop val from data stack into wr
  ldmia dsp!, {wreg}
.endm

.macro pop2_
  nip_
  pop_
.endm

.macro pop_a_ 
  ldmia dsp!, {areg}
.endm

.macro pop_b_ 
  ldmia dsp!, {breg}
.endm

.macro pop_x_ 
  ldmia dsp!, {xreg}
.endm

.macro pop_y_ 
  ldmia dsp!, {yreg}
.endm

.macro swap_
  ldr r1, [dsp] @ Load r1 from the stack, no SP change.
  str_d0_       @ Replace it with wr.
  mov wreg, r1    @ And vice versa.
.endm

.macro over_
  push_
  d1_
.endm

.macro sp_
  mov wreg, dsp
.endm

.macro str_sp_
  mov dsp, wreg
.endm

.macro nip_
  adds dsp, #4
.endm

.macro nip2_
  adds dsp, #8
.endm

.macro nip3_
  adds dsp, #12
.endm

.macro plus_a_
  adds wreg, areg
.endm

.macro a_plus_
  adds areg, wreg
.endm

.macro plus_b_
  adds wreg, breg
.endm

.macro b_plus_
  adds breg, wreg
.endm

.macro plus_x_
  adds wreg, xreg
.endm

.macro x_plus_
  adds xreg, wreg
.endm

.macro plus_y_
  adds wreg, yreg
.endm

.macro y_plus_
  adds yreg, wreg
.endm

.macro minus_a_
  subs wreg, areg
.endm

.macro a_minus_
  subs areg, wreg
.endm

.macro minus_b_
  subs wreg, breg
.endm

.macro b_minus_
  subs breg, wreg
.endm

.macro minus_x_
  subs wreg, xreg
.endm

.macro x_minus_
  subs xreg, wreg
.endm

.macro minus_y_
  subs wreg, yreg
.endm

.macro y_minus_
  subs yreg, wreg
.endm

.macro and_a_
  ands wreg, areg
.endm

.macro a_and_
  ands areg, wreg
.endm

.macro and_b_
  ands wreg, breg
.endm

.macro b_and_
  ands breg, wreg
.endm

.macro and_x_
  ands wreg, xreg
.endm

.macro x_and_
  ands xreg, wreg
.endm

.macro and_y_
  ands wreg, yreg
.endm

.macro y_and_
  ands yreg, wreg
.endm

.macro or_a_
  orrs wreg, areg
.endm

.macro a_or_
  orrs areg, wreg
.endm

.macro or_b_
  orrs wreg, breg
.endm

.macro b_or_
  orrs breg, wreg
.endm

.macro or_x_
  orrs wreg, xreg
.endm

.macro x_or_
  orrs xreg, wreg
.endm

.macro xor_a_
  eors wreg, areg
.endm

.macro a_xor_
  eors areg, wreg
.endm

.macro xor_b_
  eors wreg, breg
.endm

.macro b_xor_
  eors breg, wreg
.endm

.macro xor_x_
  eors wreg, xreg
.endm

.macro x_xor_
  eors xreg, wreg
.endm

.macro xor_y_
  eors wreg, yreg
.endm

.macro y_xor_
  eors yreg, wreg
.endm

.macro not_
  mvns wreg, wreg
.endm

.macro not_a_
  mvns areg, areg
.endm

.macro not_b_
  mvns breg, breg
.endm

.macro not_x_
  mvns xreg, xreg
.endm

.macro not_y_
  mvns yreg, yreg
.endm

.macro neg_
    rsbs wreg, wreg, #0
.endm

.macro neg_a_
    rsbs areg, areg, #0
.endm

.macro neg_b_
    rsbs breg, breg, #0
.endm

.macro neg_x_
    rsbs xreg, xreg, #0
.endm

.macro neg_y_
    rsbs yreg, yreg, #0
.endm

.macro oneplus_
  adds wreg, #1
.endm

.macro oneminus_
  subs wreg, #1
.endm

.macro twoplus_
  adds wreg, #2
.endm

.macro fourplus_
  adds wreg, #4
.endm

.macro twominus_
  subs wreg, #2
.endm

.macro fourminus_
  subs wreg, #4
.endm

.macro twoslash_
    asrs wreg, #1
.endm

.macro fourslash_
    asrs wreg, #2
.endm

.macro twostar_
    lsls wreg, #1
.endm

.macro fourstar_
    lsls wreg, #2
.endm

.macro dupzerosense_
    cmp wreg, #0
.endm

.macro zerosense_
    dupzerosense_
    pop_
.endm

.macro zeroless_
  asrs wreg, #31    @ Turn MSB into 0xffffffff or 0x00000000
.endm

.macro zero_
    movs wreg, #0
.endm

.macro zeroequal_
  subs wreg, #1
  sbcs wreg, wreg
.endm

.macro bl_
  dolit8_ 32
.endm

.macro true_
  zero_
  mvns wreg, wreg
.endm

.macro lshift_
  ldm dsp!, {r0}
  lsls r0, wreg
  mov wreg, r0
.endm

.macro rshift_
  ldm dsp!, {r0}
  lsrs r0, wreg
  mov wreg, r0
.endm

.macro fetch_
  ldr wreg, [wreg]
.endm

.macro hfetch_
  ldrh wreg, [wreg]
.endm

.macro cfetch_
  ldrb wreg, [wreg]
.endm

.macro a_
    mov wreg, areg
.endm

.macro b_
    mov wreg, breg
.endm

.macro x_
    mov wreg, xreg
.endm

.macro y_
    mov wreg, yreg
.endm

.macro str_a_
    mov areg, wreg
.endm

.macro str_b_
    mov breg, wreg
.endm

.macro str_x_
    mov xreg, wreg
.endm

.macro str_y_
    mov yreg, wreg
.endm

.macro a_fetch_
  ldr wreg, [areg]
.endm

.macro b_fetch_
  ldr wreg, [breg]
.endm

.macro x_fetch_
  ldr wreg, [xreg]
.endm

.macro y_fetch_
  ldr wreg, [yreg]
.endm

.macro a_hfetch_
  ldrh wreg, [areg]
.endm

.macro b_hfetch_
  ldrh wreg, [breg]
.endm

.macro x_hfetch_
  ldrh wreg, [xreg]
.endm

.macro y_hfetch_
  ldrh wreg, [yreg]
.endm

.macro a_cfetch_
  ldrb wreg, [areg]
.endm

.macro b_cfetch_
  ldrb wreg, [breg]
.endm

.macro x_cfetch_
  ldrb wreg, [xreg]
.endm

.macro y_cfetch_
  ldrb wreg, [yreg]
.endm

.macro a_plus4_
  adds areg, #4
.endm

.macro b_plus4_
  adds breg, #4
.endm

.macro a_plus2_
  adds areg, #2
.endm

.macro b_plus2_
  adds breg, #2
.endm

.macro x_plus2_
  adds xreg, #2
.endm

.macro y_plus2_
  adds yreg, #2
.endm

.macro a_plus1_
  adds areg, #1
.endm

.macro b_plus1_
  adds breg, #1
.endm

.macro x_plus1_
  adds xreg, #1
.endm

.macro y_plus1_
  adds yreg, #1
.endm

.macro ascii_ str, flg=0
  .p2align 1 @ Align to even locations
  .byte (8f - 7f)
  .byte \flg
7:  .ascii "\str"
8:
  .p2align 1
.endm

.macro $lit_ str
    bl DOSLIT
    ascii_ "\str"
.endm

.macro type_ str
    $lit_ "\str"
    bl TYPE
.endm


.macro Forthword_ lbl, flags, name

VE_\lbl:
    ascii_ "\name", HFLAGS & ~(\flags)

    .word VE_HEAD
    .set VE_HEAD, VE_\lbl
\lbl:
.endm
