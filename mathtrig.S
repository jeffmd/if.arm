@ mathtrig.S - math words for doing trig

.balign 4

@ ( angle -- sin(angle) )
@ angle is in radians
Forthword_ FSIN, 0, "sin"
  thumb_arm_
  vmov s0, r0
  vcvt.f64.f32 d0, s0
  do_ sin
  vcvt.f32.f64 s0, d0
  vmov r0, s0
  end_

@ ( angle -- cos(angle) )
@ angle is in radians
Forthword_ FCOS, 0, "cos"
  thumb_arm_
  vmov s0, r0
  vcvt.f64.f32 d0, s0
  do_ cos
  vcvt.f32.f64 s0, d0
  vmov r0, s0
  end_

@ ( angle -- tan(angle) )
@ angle is in radians
Forthword_ FTAN, 0, "tan"
  thumb_arm_
  vmov s0, r0
  vcvt.f64.f32 d0, s0
  do_ tan
  vcvt.f32.f64 s0, d0
  vmov r0, s0
  end_

.balign 2
.thumb
