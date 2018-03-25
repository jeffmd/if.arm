@ macros.S

wr .req r0 @ parameter top of stack [TOS] register
xr .req r3 @ X register 
yr .req r4 @ X register
sysvar .req r4 @ system variables base pointer
ar .req r5 @ A register
br .req r6 @ B register
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
    push {wr}
.endm

.macro rpush_x_ @ put copy of X on return stack
    push {xr}
.endm

.macro rnip_ @ drop TOR
    pop {r1}
.endm

.macro pop_lr_ @ pop lr from return stack into lr
.if rpi2
  pop {lr}
.else
  pop {r0}
  mov lr, r0
.endif
.endm

.macro push_ @ duplicate wr
.if rpi2
  str.w wr, [dsp, #-4]!
.else
  subs dsp, #4
  str wr, [dsp]
.endif
.endm

.macro pop_ @ pop val from data stack into wr
  ldmia dsp!, {wr}
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
    movs wr, #(\sym-sysvar_base)
    adds wr, sysvar
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
  ldr wr, [dsp]
.endm

.macro d1_
  ldr wr, [dsp, #4]
.endm

.macro d2_
  ldr wr, [dsp, #8]
.endm

.macro str_d0_
  str wr, [dsp] @ Replace it with wr.
.endm

.macro str_d1_
  str wr, [dsp, #4] @ Replace it with wr.
.endm

.macro str_d2_
  str wr, [dsp, #8] @ Replace it with wr.
.endm

.macro swap_
  ldr r1, [dsp] @ Load r1 from the stack, no SP change.
  str_d0_       @ Replace it with wr.
  mov wr, r1    @ And vice versa.
.endm

.macro over_
  push_
  d1_
.endm

.macro spfetch_
  push_
  mov wreg, dsp
.endm

.macro spstore_
  mov dsp, wreg
  pop_
.endm

.macro to_r_
  dup_r_
  pop_
.endm

.macro r_from_
  push_
  pop {wreg}
.endm

.macro r_fetch_
  push_
  ldr wreg, [sp]
.endm

.macro rpfetch_
  push_
  mov wreg, sp
.endm

.macro rpstore_
  mov sp, wreg
  pop_
.endm

.macro nip_
  adds dsp, #4
.endm

.macro dnip_
  adds dsp, #8
.endm

.macro ddrop_
  nip_
  pop_
.endm

.macro plus_
  ldm dsp!, {r0}
  adds wreg, r0
.endm

.macro minus_
  ldm dsp!, {r0}
  subs wreg, r0, wreg
.endm

.macro and_
  ldm dsp!, {r0}
  ands wreg, r0
.endm

.macro or_
  ldm dsp!, {r0}
  orrs wreg, r0
.endm

.macro xor_
  ldm dsp!, {r0}
  eors wreg, r0
.endm

.macro not_
  mvns wreg, wreg
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

.macro neg_
    rsbs wreg, wreg, #0
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

.macro zerotos_
    movs wreg, #0
.endm

.macro zero_
    push_
    zerotos_
.endm

.macro zeroequal_
  subs wreg, #1
  sbcs wreg, wreg
.endm

.macro one_
  dolit8_ 1
.endm

.macro two_
  dolit8_ 2
.endm

.macro four_
  dolit8_ 4
.endm

.macro ten_
  dolit8_ 10
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

.macro niptoa_
  ldm dsp!, {areg}
.endm

.macro niptob_
  ldm dsp!, {breg}
.endm

.macro copytoa_
    mov areg, wreg
.endm

.macro copytob_
    mov breg, wreg
.endm

.macro toa_
    mov areg, wreg
    pop_
.endm

.macro tob_
    mov breg, wreg
    pop_
.endm

.macro geta_
    push_
    mov wreg, areg
.endm

.macro getb_
    push_
    mov wreg, breg
.endm

.macro afetch_
  push_
  ldr wreg, [areg]
.endm

.macro bfetch_
  push_
  ldr wreg, [breg]
.endm

.macro ahfetch_
  push_
  ldrh wreg, [areg]
.endm

.macro bhfetch_
  push_
  ldrh wreg, [breg]
.endm

.macro acfetch_
  push_
  ldrb wreg, [areg]
.endm

.macro bcfetch_
  push_
  ldrb wreg, [breg]
.endm

.macro aplus_
  adds areg, #4
.endm

.macro bplus_
  adds breg, #4
.endm

.macro ahplus_
  adds areg, #2
.endm

.macro bhplus_
  adds breg, #2
.endm

.macro acplus_
  adds areg, #1
.endm

.macro bcplus_
  adds breg, #1
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
