@ macros.S
@ if registers and stacks
@
@ data stack       registers      return stack
@ d0               w              r0
@ d1               a              r1
@ d2               b              r2
@                  x
@                  y
@                  dsp
@                  rsp

@ use register load / store
wreg .req r0 @ working register
@ r1 is temp/scratch
xreg .req r2 @ X register 
yreg .req r3 @ Y register
areg .req r5 @ A register - non-volatile: user must preserve
breg .req r6 @ B register - non-volatile: user must preserve
dsp  .req r7 @ holds the Data stack pointer
sysvar .req r4 @ system variables base pointer


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
@ bit 0 : Terminate Tasks
.set TERMINATE_F, 1
@ bit 1 : call was last instruction
.set LAST_CALL_FB, 1
@ if bit 0 and 1 are cleared then last instruction was an inline or tail call optimization was disabled by word
@ bit 2 : disable tail call optimization
.set DIS_CALL_OPT_FB, 2


.macro opdat op, reg, sym
  \op \reg, [r1, #(\sym-Data)]
.endm

@ Inline macros

@ load register into working register

@ a
.macro a_
    mov wreg, areg
.endm

@ b
.macro b_
    mov wreg, breg
.endm

@ x
.macro x_
    mov wreg, xreg
.endm

@ y
.macro y_
    mov wreg, yreg
.endm

@ load working register into another register

@ a=w
.macro a_w_
    mov areg, wreg
.endm

@ b=w
.macro b_w_
    mov breg, wreg
.endm

@ x=w
.macro x_w_
    mov xreg, wreg
.endm

@ y=w
.macro y_w_
    mov yreg, wreg
.endm

@ push registers on return stack

@ rpush
.macro rpush_ @ put copy of w on return stack
    push {wreg}
.endm

@ rpusha
.macro rpusha_ @ put copy of A on return stack
    push {areg}
.endm

@ rpushb
.macro rpushb_ @ put copy of B on return stack
    push {breg}
.endm

@ rpushx
.macro rpushx_ @ put copy of X on return stack
    push {xreg}
.endm

@ rpushb
.macro rpushy_ @ put copy of Y on return stack
    push {yreg}
.endm

@ rpushdsp
.macro rpushdsp_ @ put copy of data stack pointer on return stack
    push {dsp}
.endm

@ pop value from return stack into register

@ rpop
.macro rpop_
  pop {wreg}
.endm

@ rpopa
.macro rpopa_
  pop {areg}
.endm

@ rpopb
.macro rpopb_
  pop {breg}
.endm

@ rpopx
.macro rpopx_
  pop {xreg}
.endm

@ rpopy
.macro rpopy_
  pop {yreg}
.endm

@ rpopdsp
.macro rpopdsp_
  pop {dsp}
.endm

.macro rnip_
    add sp, #4
.endm

.macro rnip2_ 
    add sp, #8
.endm

.macro rnip3_ 
    add sp, #12
.endm

@ load value from return stack into register

@ r0
.macro r0_
  ldr wreg, [sp]
.endm

@ a=r0
.macro a_r0_
  ldr areg, [sp]
.endm

@ b=r0
.macro b_r0_
  ldr breg, [sp]
.endm

@ x=r0
.macro x_r0_
  ldr xreg, [sp]
.endm

@ y=r0
.macro y_r0_
  ldr yreg, [sp]
.endm

@ r1
.macro r1_
  ldr wreg, [sp, #4]
.endm

@ a=r1
.macro a_r1_
  ldr areg, [sp, #4]
.endm

@ b=r1
.macro b_r1_
  ldr breg, [sp, #4]
.endm

@ x=r1
.macro x_r1_
  ldr xreg, [sp, #4]
.endm

@ y=r1
.macro y_r1_
  ldr yreg, [sp, #4]
.endm

@ r2
.macro r2_
  ldr wreg, [sp, #8]
.endm

@ a=r2
.macro a_r2_
  ldr areg, [sp, #8]
.endm

@ b=r2
.macro b_r2_
  ldr breg, [sp, #8]
.endm

@ x=r2
.macro x_r2_
  ldr xreg, [sp, #8]
.endm

@ y=r2
.macro y_r2_
  ldr yreg, [sp, #8]
.endm

@ store register value in return stack

@ r0=w
.macro r0_w_
  str wreg, [sp] 
.endm

@ r0=a
.macro r0_a_
  str areg, [sp] 
.endm

@ r0=b
.macro r0_b_
  str breg, [sp] 
.endm

@ r0=x
.macro r0_x_
  str xreg, [sp] 
.endm

@ r0=y
.macro r0_y_
  str yreg, [sp] 
.endm

@ r1=w
.macro r1_w_
  str wreg, [sp, #4] 
.endm

@ r1=a
.macro r1_a_
  str areg, [sp, #4] 
.endm

@ r1=b
.macro r1_b_
  str breg, [sp, #4] 
.endm

@ r1=x
.macro r1_x_
  str xreg, [sp, #4] 
.endm

@ r1=y
.macro r1_y_
  str yreg, [sp, #4] 
.endm

@ r2=w
.macro r2_w_
  str wreg, [sp, #8] 
.endm

@ r2=a
.macro r2_a_
  str areg, [sp, #8] 
.endm

@ r2=b
.macro r2_b_
  str breg, [sp, #8] 
.endm

@ r2=x
.macro r2_x_
  str xreg, [sp, #8] 
.endm

@ r2=y
.macro r2_y_
  str yreg, [sp, #8] 
.endm

# store return stack register in register

@ rsp
.macro rsp_
  mov wreg, sp
.endm

@ rsp=w
.macro rsp_w_
  mov sp, wreg
.endm

@ test with 8 bit constant
.macro bittest_ v
    movs r1, #\v
    tst wreg, r1
.endm

.macro user_ sym
    movs wreg, #(\sym-sysvar_base)
    adds wreg, sysvar
.endm


.macro lit_ val reg=wreg
.if \val < 256
  movs \reg, #\val
.else
  .if \val < 0x10000
    movs \reg, #(\val/256)
    lsls \reg, #8
    adds \reg, #(\val & 255)
  .else
    do_ W_MI
    .word \val
  .endif
.endif
.endm

.macro lit_y_ val
  lit_ \val yreg
.endm

.macro lit_x_ val
  lit_ \val xreg
.endm

.macro lit_a_ val
  lit_ \val areg
.endm

.macro lit_b_ val
  lit_ \val breg
.endm


@ store register into data stack

@ d0=w
.macro d0_w_
  str wreg, [dsp] @ Replace it with wr.
.endm

@ d1=w
.macro d1_w_
  str wreg, [dsp, #4] @ Replace it with wr.
.endm

@ d2=w
.macro d2_w_
  str wreg, [dsp, #8] @ Replace it with wr.
.endm

@ d0=a
.macro d0_a_
  str areg, [dsp] 
.endm

@ d1=a
.macro d1_a_
  str areg, [dsp, #4] 
.endm

@ d2=a
.macro d2_a_
  str areg, [dsp, #8] 
.endm

@ d0=b
.macro d0_b_
  str breg, [dsp] 
.endm

@ d1=b
.macro d1_b_
  str breg, [dsp, #4] 
.endm

@ d2=b
.macro d2_b_
  str breg, [dsp, #8] 
.endm

@ d0=x
.macro d0_x_
  str xreg, [dsp] 
.endm

@ d1=x
.macro d1_x_
  str xreg, [dsp, #4] 
.endm

@ d2=x
.macro d2_x_
  str areg, [dsp, #8] 
.endm

@ d0=y
.macro d0_y_
  str yreg, [dsp] 
.endm

@ d1=y
.macro d1_y_
  str yreg, [dsp, #4] 
.endm

@ d2=y
.macro d2_y_
  str areg, [dsp, #8] 
.endm

@ store data stack item in register

@ d0
.macro d0_
  ldr wreg, [dsp]
.endm

@ d1
.macro d1_
  ldr wreg, [dsp, #4]
.endm

@ d2
.macro d2_
  ldr wreg, [dsp, #8]
.endm

@ a=d0
.macro a_d0_
  ldr areg, [dsp]
.endm

@ a=d1
.macro a_d1_
  ldr areg, [dsp, #4]
.endm

@ a=d2
.macro a_d2_
  ldr areg, [dsp, #8]
.endm

@ b=d0
.macro b_d0_
  ldr breg, [dsp]
.endm

@ b=d1
.macro b_d1_
  ldr breg, [dsp, #4]
.endm

@ b=d2
.macro b_d2_
  ldr breg, [dsp, #8]
.endm

@ x=d0
.macro x_d0_
  ldr xreg, [dsp]
.endm

@ x=d1
.macro x_d1_
  ldr xreg, [dsp, #4]
.endm

@ x=d2
.macro x_d2_
  ldr xreg, [dsp, #8]
.endm

@ y=d0
.macro y_d0_
  ldr yreg, [dsp]
.endm

@ y=d1
.macro y_d1_
  ldr yreg, [dsp, #4]
.endm

@ y=d2
.macro y_d2_
  ldr yreg, [dsp, #8]
.endm

@ make room on data stack

.macro put1_ @ move stack pointer down one cell
   subs dsp, #4
.endm

.macro put2_ @ move stack pointer down two cells
   subs dsp, #8
.endm

.macro put3_ @ move stack pointer down three cells
   subs dsp, #12
.endm

@ push register onto data stack

@ push
.macro push_ 
  put1_
  d0_w_
.endm

@ pusha
.macro pusha_ 
  put1_
  d0_a_
.endm

@ pushb
.macro pushb_ 
  put1_
  d0_b_
.endm

@ pushx
.macro pushx_ 
  put1_
  d0_x_
.endm

@ pushy
.macro pushy_ 
  put1_
  d0_y_
.endm

@ pop value from data stack into register

@ pop
.macro pop_
  ldmia dsp!, {wreg}
.endm

@ popa
.macro popa_
  ldmia dsp!, {areg}
.endm

@ popb
.macro popb_
  ldmia dsp!, {breg}
.endm

@ popx
.macro popx_
  ldmia dsp!, {xreg}
.endm

@ popy
.macro popy_
  ldmia dsp!, {yreg}
.endm

@ nip
.macro nip_
  adds dsp, #4
.endm

@ nip2
.macro nip2_
  adds dsp, #8
.endm

@ nip3
.macro nip3_
  adds dsp, #12
.endm

@ dsp
.macro dsp_
  mov wreg, dsp
.endm

@ dsp=w
.macro dsp_w_
  mov dsp, wreg
.endm

@ add register to register

@ w+=a
.macro w_plus_a_
  adds wreg, areg
.endm

@ w+=b
.macro w_plus_b_
  adds wreg, breg
.endm

@ w+=x
.macro w_plus_x_
  adds wreg, xreg
.endm

@ w+=y
.macro w_plus_y_
  adds wreg, yreg
.endm

@ a+=w
.macro a_plus_w_
  adds areg, wreg
.endm

@ a+=b
.macro a_plus_b_
  adds areg, breg
.endm

@ a+=x
.macro a_plus_x_
  adds areg, xreg
.endm

@ a+=y
.macro a_plus_y_
  adds areg, yreg
.endm

@ b+=w
.macro b_plus_w_
  adds breg, wreg
.endm

@ b+=a
.macro b_plus_a_
  adds breg, areg
.endm

@ b+=x
.macro b_plus_x_
  adds breg, xreg
.endm

@ b+=y
.macro b_plus_y_
  adds breg, yreg
.endm

@ x+=w
.macro x_plus_w_
  adds xreg, wreg
.endm

@ x+=a
.macro x_plus_a_
  adds xreg, areg
.endm

@ x+=b
.macro x_plus_b_
  adds xreg, breg
.endm

@ x+=y
.macro x_plus_y_
  adds xreg, yreg
.endm

@ y+=w
.macro y_plus_w_
  adds yreg, wreg
.endm

@ y+=a
.macro y_plus_a_
  adds yreg, areg
.endm

@ y+=b
.macro y_plus_b_
  adds yreg, breg
.endm

@ y+=x
.macro y_plus_x_
  adds yreg, xreg
.endm

@ w-=a
.macro w_minus_a_
  subs wreg, areg
.endm

@ w-=b
.macro w_minus_b_
  subs wreg, breg
.endm

@ w-=x
.macro w_minus_x_
  subs wreg, xreg
.endm

@ w-=y
.macro w_minus_y_
  subs wreg, yreg
.endm

@ a-=w
.macro a_minus_w_
  subs areg, wreg
.endm

@ a-=b
.macro a_minus_b_
  subs areg, breg
.endm

@ a-=x
.macro a_minus_x_
  subs areg, xreg
.endm

@ a-=y
.macro a_minus_y_
  subs areg, yreg
.endm

@ b-=w
.macro b_minus_w_
  subs breg, wreg
.endm

@ b-=a
.macro b_minus_a_
  subs breg, areg
.endm

@ b-=x
.macro b_minus_x_
  subs breg, xreg
.endm

@ b-=y
.macro b_minus_y_
  subs breg, yreg
.endm

@ x-=w
.macro x_minus_w_
  subs xreg, wreg
.endm

@ x-=a
.macro x_minus_a_
  subs xreg, areg
.endm

@ x-=b
.macro x_minus_b_
  subs xreg, breg
.endm

@ x-=y
.macro x_minus_y_
  subs xreg, yreg
.endm

@ y-=w
.macro y_minus_w_
  subs yreg, wreg
.endm

@ y-=a
.macro y_minus_a_
  subs yreg, areg
.endm

@ y-=b
.macro y_minus_b_
  subs yreg, breg
.endm

@ y-=x
.macro y_minus_x_
  subs yreg, xreg
.endm

@ w&=a
.macro w_and_a_
  ands wreg, areg
.endm

@ a&=w
.macro a_and_w_
  ands areg, wreg
.endm

@ w&=b
.macro w_and_b_
  ands wreg, breg
.endm

@ b&=w
.macro b_and_w_
  ands breg, wreg
.endm

@ w&=x
.macro w_and_x_
  ands wreg, xreg
.endm

@ x&=w
.macro x_and_w_
  ands xreg, wreg
.endm

@ w&=y
.macro w_and_y_
  ands wreg, yreg
.endm

@ y&=w
.macro y_and_w_
  ands yreg, wreg
.endm

@ w|=a
.macro w_or_a_
  orrs wreg, areg
.endm

@ a|=w
.macro a_or_w_
  orrs areg, wreg
.endm

@ w|=b
.macro w_or_b_
  orrs wreg, breg
.endm

@ b|=w
.macro b_or_
  orrs breg, wreg
.endm

@ w|=x
.macro w_or_x_
  orrs wreg, xreg
.endm

@ x|=w
.macro x_or_w_
  orrs xreg, wreg
.endm

@ w|=y
.macro w_or_y_
  orrs wreg, yreg
.endm

@ y|=w
.macro y_or_w_
  orrs yreg, wreg
.endm

@ w^=a
.macro w_xor_a_
  eors wreg, areg
.endm

@ a^=w
.macro a_xor_w_
  eors areg, wreg
.endm

@ w^=b
.macro w_xor_b_
  eors wreg, breg
.endm

@ b^=w
.macro b_xor_w_
  eors breg, wreg
.endm

@ w^=x
.macro w_xor_x_
  eors wreg, xreg
.endm

@ x^=w
.macro x_xor_w_
  eors xreg, wreg
.endm

@ w^=y
.macro w_xor_y_
  eors wreg, yreg
.endm

@ y^=w
.macro y_xor_w_
  eors yreg, wreg
.endm

@ !
.macro not_
  mvns wreg, wreg
.endm

@ !a
.macro not_a_
  mvns areg, areg
.endm

@ !b
.macro not_b_
  mvns breg, breg
.endm

@ !x
.macro not_x_
  mvns xreg, xreg
.endm

@ !y
.macro not_y_
  mvns yreg, yreg
.endm

@ -
.macro neg_
    rsbs wreg, wreg, #0
.endm

@ -a
.macro neg_a_
    rsbs areg, areg, #0
.endm

@ -b
.macro neg_b_
    rsbs breg, breg, #0
.endm

@ -x
.macro neg_x_
    rsbs xreg, xreg, #0
.endm

@ -y
.macro neg_y_
    rsbs yreg, yreg, #0
.endm

@ 1+ 
.macro oneplus_
  adds wreg, #1
.endm

@ 1-
.macro oneminus_
  subs wreg, #1
.endm

@ 2+
.macro twoplus_
  adds wreg, #2
.endm

@ 4+
.macro fourplus_
  adds wreg, #4
.endm

@ 2-
.macro twominus_
  subs wreg, #2
.endm

@ 4-
.macro fourminus_
  subs wreg, #4
.endm

@ 2/
.macro twoslash_
    asrs wreg, #1
.endm

@ 4/
.macro fourslash_
    asrs wreg, #2
.endm

@ 2*
.macro twostar_
    lsls wreg, #1
.endm

@ 4*
.macro fourstar_
    lsls wreg, #2
.endm

@ x/=2
.macro x_twoslash_
  asrs xreg, #1
.endm

@ x/=4
.macro x_fourslash_
  asrs xreg, #2
.endm

@ x*=2
.macro x_twostar_
  lsls xreg, #1
.endm

@ x*=4
.macro x_fourstar_
  lsls xreg, #2
.endm

@ y/=2
.macro y_twoslash_
  asrs yreg, #1
.endm

@ y/=4
.macro y_fourslash_
  asrs yreg, #2
.endm

@ y*=2
.macro y_twostar_
  lsls yreg, #1
.endm

@ y*=4
.macro y_fourstar_
  lsls yreg, #2
.endm

@ a/=2
.macro a_twoslash_
  asrs areg, #1
.endm

@ a/=4
.macro a_fourslash_
  asrs areg, #2
.endm

@ a*=2
.macro a_twostar_
  lsls areg, #1
.endm

@ a*=4
.macro a_fourstar_
  lsls areg, #2
.endm

@ b/=2
.macro b_twoslash_
  asrs breg, #1
.endm

@ b/=4
.macro b_fourslash_
  asrs breg, #2
.endm

@ b*=2
.macro b_twostar_
  lsls breg, #1
.endm

@ b*=4
.macro b_fourstar_
  lsls breg, #2
.endm

@ ==0
.macro iszero_
    cmp wreg, #0
.endm

@ a==0
.macro a_iszero_
    cmp areg, #0
.endm

@ b==0
.macro b_iszero_
    cmp breg, #0
.endm

@ x==0
.macro x_iszero_
    cmp xreg, #0
.endm

@ y==0
.macro y_iszero_
    cmp yreg, #0
.endm

@ <0
.macro zeroless_
  asrs wreg, #31    @ Turn MSB into 0xffffffff or 0x00000000
.endm

@ 0
.macro zero_
    movs wreg, #0
.endm

@ a=0
.macro a_0_
    movs areg, #0
.endm

@ b=0
.macro b_0_
    movs breg, #0
.endm

@ x=0
.macro x_0_
    movs xreg, #0
.endm

@ y=0
.macro y_0_
    movs yreg, #0
.endm

@ 0= 
.macro zeroequal_
  subs wreg, #1
  sbcs wreg, wreg
.endm

.macro bl_
  lit_ 32
.endm

.macro true_
  zero_
  not_
.endm

.macro lshift_
  ldm dsp!, {r1}
  lsls r1, wreg
  mov wreg, r1
.endm

.macro rshift_
  ldm dsp!, {r1}
  lsrs r1, wreg
  mov wreg, r1
.endm

@ fetch from memory pointed to by working register and store in register

@ @
.macro mw_
  ldr wreg, [wreg]
.endm

@ a=@w
.macro a_mw_
  ldr areg, [wreg]
.endm

@ b=@w
.macro b_mw_
  ldr breg, [wreg]
.endm

@ x=@w
.macro x_mw_
  ldr xreg, [wreg]
.endm

@ y=@w
.macro y_mw_
  ldr yreg, [wreg]
.endm

@ h@
.macro hmw_
  ldrh wreg, [wreg]
.endm

@ a=h@w
.macro a_hmw_
  ldrh areg, [wreg]
.endm

@ b=h@w
.macro b_hmw_
  ldrh breg, [wreg]
.endm

@ x=h@w
.macro x_hmw_
  ldrh xreg, [wreg]
.endm

@ y=h@w
.macro y_hmw_
  ldrh yreg, [wreg]
.endm

@ c@ 
.macro cmw_
  ldrb wreg, [wreg]
.endm

@ a=c@w
.macro a_cmw_
  ldrb areg, [wreg]
.endm

@ b=c@w
.macro b_cmw_
  ldrb breg, [wreg]
.endm

@ x=c@w
.macro x_cmw_
  ldrb xreg, [wreg]
.endm

@ y=c@w
.macro y_cmw_
  ldrb yreg, [wreg]
.endm

@ fetch value from memory pointed to by register

@ @a
.macro ma_
  ldr wreg, [areg]
.endm

@ @b
.macro mb_
  ldr wreg, [breg]
.endm

@ @x
.macro mx_
  ldr wreg, [xreg]
.endm

@ @y
.macro my_
  ldr wreg, [yreg]
.endm

@ h@a
.macro hma_
  ldrh wreg, [areg]
.endm

@ h@b
.macro hmb_
  ldrh wreg, [breg]
.endm

@ h@x
.macro hmx_
  ldrh wreg, [xreg]
.endm

@ h@y
.macro hmy_
  ldrh wreg, [yreg]
.endm

@ c@a
.macro cma_
  ldrb wreg, [areg]
.endm

@ c@b
.macro cmb_
  ldrb wreg, [breg]
.endm

@ c@x
.macro cmx_
  ldrb wreg, [xreg]
.endm

@ c@y
.macro cmy_
  ldrb wreg, [yreg]
.endm

@ store register into memory pointed to by working register

@ @w=a
.macro mw_a_
  str areg, [wreg]     
.endm

@ @w=b
.macro mw_b_
  str breg, [wreg]     
.endm

@ @w=x
.macro mw_x_
  str xreg, [wreg]     
.endm

@ @w=y
.macro mw_y_
  str yreg, [wreg]
.endm

@ h@w=a
.macro hmw_a_
  strh areg, [wreg]     
.endm

@ h@w=b
.macro hmw_b_
  strh breg, [wreg]     
.endm

@ h@w=x
.macro hmw_x_
  strh xreg, [wreg]     
.endm

@ h@w=y
.macro hmw_y_
  strh yreg, [wreg]
.endm

@ c@w=a
.macro cmw_a_
  strb areg, [wreg]     
.endm

@ c@w=b
.macro cmw_b_
  strb breg, [wreg]     
.endm

@ c@w=x
.macro cmw_x_
  strb xreg, [wreg]     
.endm

@ c@w=y
.macro cmw_y_
  strb yreg, [wreg]
.endm

@ @a=w
.macro ma_w_
  str wreg, [areg]     
.endm

@ @b=w
.macro mb_w_
  str wreg, [breg]     
.endm

@ @x=w
.macro mx_w_
  str wreg, [xreg]     
.endm

@ @y=w
.macro my_w_
  str wreg, [yreg]     
.endm

@ h@a=w
.macro hma_w_
  strh wreg, [areg]     
.endm

@ h@b=w
.macro hmb_w_
  strh wreg, [breg]     
.endm

@ h@x=w
.macro hmx_w_
  strh wreg, [xreg]     
.endm

@ h@y=w
.macro hmy_w_
  strh wreg, [yreg]     
.endm

@ c@a=w
.macro cma_w_
  strb wreg, [areg]     
.endm

@ c@b=w
.macro cmb_w_
  strb wreg, [breg]     
.endm

@ c@x=w
.macro cmx_w_
  strb wreg, [xreg]     
.endm

@ c@y=w
.macro cmy_w_
  strb wreg, [yreg]     
.endm

@ add 4 to register

@ a+=4
.macro a_plus4_
  adds areg, #4
.endm

@ b+=4
.macro b_plus4_
  adds breg, #4
.endm

@ x+=4
.macro x_plus4_
  adds xreg, #4
.endm

@ y+=4
.macro y_plus4_
  adds yreg, #4
.endm

@ subtract 4 from register

@ a-=4
.macro a_minus4_
  subs areg, #4
.endm

@ b-=4
.macro b_minus4_
  subs breg, #4
.endm

@ x-=4
.macro x_minus4_
  subs xreg, #4
.endm

@ y-=4
.macro y_minus4_
  subs yreg, #4
.endm

@ add 2 to register

@ a+=2
.macro a_plus2_
  adds areg, #2
.endm

@ b+=2
.macro b_plus2_
  adds breg, #2
.endm

@ x+=2
.macro x_plus2_
  adds xreg, #2
.endm

@ y+=2
.macro y_plus2_
  adds yreg, #2
.endm

@ subtract 2 from register

@ a-=2
.macro a_minus2_
  subs areg, #2
.endm

@ b-=2
.macro b_minus2_
  subs breg, #2
.endm

@ x-=2
.macro x_minus2_
  subs xreg, #2
.endm

@ y-=2
.macro y_minus2_
  subs yreg, #2
.endm

@ add 1 to register

@ a+=1
.macro a_plus1_
  adds areg, #1
.endm

@ b+=1
.macro b_plus1_
  adds breg, #1
.endm

@ x+=1
.macro x_plus1_
  adds xreg, #1
.endm

@ y+=1
.macro y_plus1_
  adds yreg, #1
.endm

@ subtract 1 from register

@ a-=1
.macro a_minus1_
  subs areg, #1
.endm

@ b-=1
.macro b_minus1_
  subs breg, #1
.endm

@ x-=1
.macro x_minus1_
  subs xreg, #1
.endm

@ y-=1
.macro y_minus1_
  subs yreg, #1
.endm

@ if zero flag ==0 jump to addr
.macro if_0_ addr
  beq.n \addr
.endm

@ if zero flag !=0 jump to addr
.macro if_not_0_ addr
  bne.n \addr
.endm

.macro push_lr_
  .set PUSH_LR, 1
  push {lr}
.endm

.macro pop_lr_ @ pop lr from return stack into lr
.if rpi2
  pop {lr}
.else
  pop {r1}
  mov lr, r1
.endif
.set PUSH_LR, 0
.endm

@ do command
.macro do_ addr
  .if PUSH_LR == 0
    push_lr_ 
  .endif
  bl \addr
.endm

.macro goto_ addr
  b.n \addr
.endm

.macro exit_
  .if PUSH_LR
    pop {pc}
  .else
    bx lr
  .endif
.endm

.macro exit_do_ addr
  .if PUSH_LR
    pop_lr_
    .set PUSH_LR, 1
  .endif
  b.n \addr  
.endm

.macro end_
  exit_
  .set PUSH_LR, 0
.endm

.macro end_next_
  .if PUSH_LR
    pop_lr_
  .endif
.endm

.macro end_do_ addr
  .if PUSH_LR
    pop_lr_
  .endif
  b.n \addr
.endm

.macro end_goto_ addr
  .set PUSH_LR,0
  b.n \addr
.endm

@ load a 32 bit inline val into working register
.macro lit32_ val
  do_ W_MI
  .word \val
.endm

@ load a 32 bit inline val into X register
.macro lit32_x_ val
  do_ X_MI
  .word \val
.endm

@ load a 32 bit inline val into Y register
.macro lit32_y_ val
  do_ Y_MI
  .word \val
.endm

@ load a 32 bit inline val into A register
.macro lit32_a_ val
  do_ A_MI
  .word \val
.endm

@ load a 32 bit inline val into B register
.macro lit32_b_ val
  do_ B_MI
  .word \val
.endm

.macro ascii_ str, flg=0
  .p2align 1 @ Align to even locations
  .byte (8f - 7f)
  .byte \flg
7:  .ascii "\str"
8:
  .p2align 1
.endm

.macro slit_ str
    do_ DOSLIT
    ascii_ "\str"
.endm

.macro type_ str
    slit_ "\str"
    do_ TYPE
.endm


.macro Forthword_ lbl, flags, name
.data
VE_\lbl:
    ascii_ "\name", HFLAGS & ~(\flags)

    .word VE_HEAD
    .word \lbl
    .set VE_HEAD, VE_\lbl
.text
\lbl:
.endm
