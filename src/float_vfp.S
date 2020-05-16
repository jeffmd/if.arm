@ floatvfp.S - math functions for floating point values using vfpv2

.syntax unified

.balign 4

Forthword_ S0W, 0, "s0="
  thumb_arm_
  vmov s0, r0
  end_

Forthword_ S0FW, 0, "s0i="
  thumb_arm_
  vmov s0, r0
  vcvt.f32.s32 s0, s0
  end_

Forthword_ WIF, 0, "f"
  thumb_arm_
  vmov s0, r0
  vcvt.f32.s32 s0, s0
  vmov r0, s0
  end_

Forthword_ WFI, 0, "i"
  thumb_arm_
  vmov s0, r0
  vcvt.s32.f32 s0, s0
  vmov r0, s0
  end_

Forthword_ FPSCR, 0, "fpscr"
  thumb_arm_
  vmrs r0, fpscr
  end_

@ ( len -- )
@ set fpscr length field
Forthword_ VFP_LEN_SET, 0, "vfplen="
  thumb_arm_
  lit_x_ 0b111
  w_and_x_
  y_w_
  mvn xreg, xreg, lsl #16
  vmrs r0, fpscr
  w_and_x_
  w_or_y_
  vmsr fpscr, r0
  end_

Forthword_ FPSID, 0, "fpsid"
  thumb_arm_
  vmrs r0, fpsid
  end_

Forthword_ MVFR0, 0, "mvfr0"
  thumb_arm_
  vmrs r0, mvfr0
  end_

Forthword_ MVFR1, 0, "mvfr1"
  thumb_arm_
  vmrs r0, mvfr1
  end_

Forthword_ S1X, 0, "s1=x"
  thumb_arm_
  vmov s1, r1
  end_

Forthword_ S1FX, 0, "s1i=x"
  thumb_arm_
  vmov s1, r1
  vcvt.f32.s32 s1, s1
  end_

Forthword_ S2Y, 0, "s2=y"
  thumb_arm_
  vmov s2, r2
  end_

Forthword_ S2FY, 0, "s2i=y"
  thumb_arm_
  vmov s2, r2
  vcvt.f32.s32 s2, s2
  end_

Forthword_ S0, 0, "s0"
  thumb_arm_
  vmov r0, s0
  end_

Forthword_ S0IF, 0, "s0f"
  thumb_arm_
  vcvt.f32.s32 s0, s0
  end_

Forthword_ S0FI, 0, "s0i"
  thumb_arm_
  vcvt.s32.f32 s0, s0
  vmov r0, s0
  end_

Forthword_ S0ADDS1, 0, "s0+s1"
  thumb_arm_
  vadd.f32 s0, s0, s1
  end_

Forthword_ S0ADDS2, 0, "s0+s2"
  thumb_arm_
  vadd.f32 s0, s0, s2
  end_

Forthword_ S0SUBS1, 0, "s0-s1"
  thumb_arm_
  vsub.f32 s0, s0, s1
  end_

Forthword_ S0SUBS2, 0, "s0-s2"
  thumb_arm_
  vsub.f32 s0, s0, s2
  end_

Forthword_ S0MULS1, 0, "s0*s1"
  thumb_arm_
  vmul.f32 s0, s0, s1
  end_

Forthword_ S0DIVS1, 0, "s0/s1"
  thumb_arm_
  vdiv.f32 s0, s0, s1
  end_

Forthword_ S0DIVS2, 0, "s0/s2"
  thumb_arm_
  vdiv.f32 s0, s0, s2
  end_

Forthword_ S1DIVS2, 0, "s1/s2"
  thumb_arm_
  vdiv.f32 s1, s1, s1
  end_

Forthword_ FADD, 0, "f+"
  thumb_arm_
  vmov s0, s1, r0, r1
  vadd.f32 s0, s0, s1
  vmov.f32 r0, s0
  end_

Forthword_ FSUB, 0, "f-"
  thumb_arm_
  vmov s0, s1, r0, r1
  vsub.f32 s0, s0, s1
  vmov.f32 r0, s0
  end_

Forthword_ FMUL, 0, "f*"
  thumb_arm_
  vmov s0, s1, r0, r1
  vmul.f32 s0, s0, s1
  vmov.f32 r0, s0
  end_

Forthword_ FDIV, 0, "f/"
  thumb_arm_
  vmov s0, s1, r0, r1
  vdiv.f32 s0, s0, s1
  vmov.f32 r0, s0
  end_

Forthword_ SQRT, 0, "sqrt"
  thumb_arm_
  vmov.f32 s0, r0
  vsqrt.f32 s0, s0
  vmov.f32 r0, s0
  end_

Forthword_ FABS, 0, "fabs"
  thumb_arm_
  vmov.f32 s0, r0
  vabs.f32 s0, s0
  vmov.f32 r0, s0
  end_

@ ( addr X:cnt -- )
Forthword_ VLTEST, 0, "vltest"
  thumb_arm_
VLT:
  vldm wreg, {s0-s3}
  x_minus1_
  bne VLT 
  end_

@ ( addr X:cnt -- )
Forthword_ SLTEST, 0, "sltest"
  thumb_arm_
SLT:
  vldr s0, [wreg]
  vldr s1, [wreg, #4]
  vldr s2, [wreg, #8]
  vldr s3, [wreg, #12]
  x_minus1_
  bne SLT 
  end_

@ ( addr X:cnt -- )
Forthword_ VSTEST, 0, "vstest"
  thumb_arm_
VST:
  vstmia wreg, {s0-s3}
  x_minus1_
  bne VLT 
  end_

@ ( addr X:cnt -- )
Forthword_ SSTEST, 0, "sstest"
  thumb_arm_
SST:
  vstr s0, [wreg]
  vstr s1, [wreg, #4]
  vstr s2, [wreg, #8]
  vstr s3, [wreg, #12]
  x_minus1_
  bne SLT 
  end_

@ ( -- )
Forthword_ FASTFLOAT, 0, "fastfloat"
  thumb_arm_
  mov xreg, #0b11
  vmrs yreg, fpscr
  mov xreg, xreg, LSL #24
  orr xreg, xreg, yreg
  vmsr fpscr, xreg
  end_

@ ( cnt addr  -- )
Forthword_ VAT, 0, "vat"
  thumb_arm_
  mov yreg, #0b011
  mov yreg, yreg, LSL #16
  vmrs xreg, fpscr
  orr xreg, xreg, yreg
  vmsr fpscr, xreg
  vldr s0, [wreg, #4]
  x_d_
VATL:
  vldr s0, [wreg, #16]
  vldm wreg, {s8-s11}
  vmla.f32 s12, s8, s0
  x_minus1_
  bne VATL 

  vstr s0, [wreg]
  mov yreg, #0b011
  mvn yreg, yreg, LSL #16
  vmrs xreg, fpscr
  and xreg, xreg, yreg
  vmsr fpscr, xreg
  end_

@ ( cnt addr  -- )
Forthword_ VAT2, 0, "vat2"
  thumb_arm_
  mov yreg, #0b011
  mov yreg, yreg, LSL #16
  vmrs xreg, fpscr
  orr xreg, xreg, yreg
  vmsr fpscr, xreg
  vldr s0, [wreg, #4]
  x_d_
VAT2L:
  vldr s0, [wreg, #16]
  vldm wreg, {s8-s11}
  vmla.f32 s16, s8, s0
  vldm wreg, {s12-s15}
  vmla.f32 s20, s12, s0
  x_minus1_
  bne VAT2L 

  vstr s0, [wreg]
  mov yreg, #0b011
  mvn yreg, yreg, LSL #16
  vmrs xreg, fpscr
  and xreg, xreg, yreg
  vmsr fpscr, xreg
  end_

@ ( cnt addr  -- )
Forthword_ SAT, 0, "sat"
  thumb_arm_
  x_d_
SADDT:
  vldr s0, [wreg, #16]
  vldr s8, [wreg]
  vldr s9, [wreg, #4]
  vldr s10, [wreg, #8]
  vldr s11, [wreg, #12]
  vmla.f32 s4, s8, s0
  vmla.f32 s5, s9, s0
  vmla.f32 s6, s10, s0
  vmla.f32 s7, s11, s0
  x_minus1_
  bne SADDT 

  end_

@ ( cnt addr  -- )
Forthword_ SAT2, 0, "sat2"
  thumb_arm_
  x_d_
SADDT2:
  vldr s0, [wreg, #16]
  vldr s8, [wreg]
  vldr s9, [wreg, #4]
  vldr s10, [wreg, #8]
  vldr s11, [wreg, #12]
  vmla.f32 s4, s8, s0
  vmla.f32 s5, s9, s0
  vmla.f32 s6, s10, s0
  vmla.f32 s7, s11, s0

  vldr s16, [wreg]
  vldr s17, [wreg, #4]
  vldr s18, [wreg, #8]
  vldr s19, [wreg, #12]
  vmla.f32 s20, s16, s0
  vmla.f32 s21, s17, s0
  vmla.f32 s22, s18, s0
  vmla.f32 s23, s19, s0
  x_minus1_
  bne SADDT2 

  end_

@ ( cnt addr  -- )
Forthword_ LSAT, 0, "lsat"
  thumb_arm_
  x_d_
LSADDT:
  vldmia wreg, {s8-s15}
  vmla.f32 s16, s8, s0
  vmla.f32 s17, s9, s0
  vmla.f32 s18, s10, s0
  vmla.f32 s19, s11, s0
  vmla.f32 s20, s12, s0
  vmla.f32 s21, s13, s0
  vmla.f32 s22, s14, s0
  vmla.f32 s23, s15, s0
  x_minus1_
  @vstr s16, [wreg]
  @vstr s17, [wreg, #4]
  @vstr s18, [wreg, #8]
  @vstr s19, [wreg, #12]
  @vstr s20, [wreg, #16]
  @vstr s21, [wreg, #20]
  @vstr s22, [wreg, #24]
  @vstr s23, [wreg, #28]
  bne LSADDT 

  end_

@ ( cnt addr  -- )
Forthword_ SADT, 0, "sadt"
  thumb_arm_
  x_d_
ADT:
  vldr s0, [wreg]
  vldr s1, [wreg, #4]
  vldr s2, [wreg, #8]
  vldr s3, [wreg, #12]
  vadd.f32 s4, s1, s0
  vadd.f32 s5, s2, s3
  vadd.f32 s6, s4, s5
  x_minus1_
  bne ADT 

  vstr s0, [wreg]
  end_

.balign 2
.thumb
