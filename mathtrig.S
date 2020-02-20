@ mathtrig.S - math words for doing trig

.balign 4

@ ( angle -- sin(angle) )
@ angle is in radians
Forthword_ FSIN, 0, "sin"
  thumb_arm_
  vmov s0, r0
  do_ sinf
  vmov r0, s0
  end_

@ ( angle -- cos(angle) )
@ angle is in radians
Forthword_ FCOS, 0, "cos"
  thumb_arm_
  vmov s0, r0
  do_ cosf
  vmov r0, s0
  end_

@ ( angle -- tan(angle) )
@ angle is in radians
Forthword_ FTAN, 0, "tan"
  thumb_arm_
  vmov s0, r0
  do_ tanf
  vmov r0, s0
  end_

@ ( val -- asin(val) )
@ result is in radians
Forthword_ FASIN, 0, "asin"
  thumb_arm_
  vmov s0, r0
  do_ asinf
  vmov r0, s0
  end_

@ ( val -- acos(val) )
@ result is in radians
Forthword_ FACOS, 0, "acos"
  thumb_arm_
  vmov s0, r0
  do_ acosf
  vmov r0, s0
  end_

@ ( val -- atan(val) )
@ result is in radians
Forthword_ FATAN, 0, "atan"
  thumb_arm_
  vmov s0, r0
  do_ atanf
  vmov r0, s0
  end_

@ ( n X:y -- n^y )
@ raise n to the power of y
Forthword_ FPOW, 0, "pow"
  thumb_arm_
  vmov s0, s1, r0, r1
  do_ powf
  vmov r0, s0
  end_

.balign 2
.thumb
