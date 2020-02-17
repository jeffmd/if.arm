@ floatvfp.S - math functions for floating point values using vfpv2

.syntax unified

.macro thumb_arm_
.thumb
  bx pc
  nop
.arm
.endm

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
  vmov.f32 s0, r0
  vmov.f32 s1, r1
  vadd.f32 s0, s0, s1
  vmov.f32 r0, s0
  end_

Forthword_ FSUB, 0, "f-"
  thumb_arm_
  vmov.f32 s0, r0
  vmov.f32 s1, r1
  vsub.f32 s0, s0, s1
  vmov.f32 r0, s0
  end_

Forthword_ FMUL, 0, "f*"
  thumb_arm_
  vmov.f32 s0, r0
  vmov.f32 s1, r1
  vmul.f32 s0, s0, s1
  vmov.f32 r0, s0
  end_

Forthword_ FDIV, 0, "f/"
  thumb_arm_
  vmov.f32 s0, r0
  vmov.f32 s1, r1
  vdiv.f32 s0, s0, s1
  vmov.f32 r0, s0
  end_

.balign 2
.thumb
