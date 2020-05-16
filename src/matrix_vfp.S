matmul4x4
  @ r0 address of A
  @ r1 address of B
  @ r2 address of C

  push {r4, r5, r6, r7, r8, lr} 
  vpush {s16-s19}              @ Floating point registers starting from s16 must be preserved 
 
  
  mov r4, r2
  mov r5, #16
  mov r6, #0
  b loop_init_test
loop_init:
  str r6, [r4], +#4   /* *r4 ← r6 then r4 ← r4 + 4 */
loop_init_test:
  subs r5, r5, #1
  bnz loop_init
 
  @ Set the LEN field of FPSCR to be 4 (value 3)
    mov r5, #0b011                        /* r5 ← 3 */
    mov r5, r5, LSL #16                   /* r5 ← r5 << 16 */
    fmrx r4, fpscr                        /* r4 ← fpscr */
    orr r4, r4, r5                        /* r4 ← r4 | r5 */
    fmxr fpscr, r4                        /* fpscr ← r4 */
 
    /* We will use 
           r4 as k
           r5 as i
    */
    mov r4, #0 /* r4 ← 0 */
    .L4_loop_k:  /* loop header of k */
      cmp r4, #4  /* if r4 == 4 goto end of the loop k */
      beq .L4_end_loop_k
      mov r5, #0  /* r5 ← 0 */
      .L4_loop_i: /* loop header of i */
       cmp r5, #4 /* if r5 == 4 goto end of the loop i */
        beq .L4_end_loop_i
        /* Compute the address of C[i][0] */
        /* Address of C[i][0] is C + 4*(4 * i) */
        add r7, r2, r5, LSL #4         /* r7 ← r2 + (r5 << 4). This is r7 ← c + 4*4*i */
        vldmia r7, {s8-s15}            /* Load {s8,s9,s10,s11,s12,s13,s14,s15} 
                                            ← {c[i][0],   c[i][1],   c[i][2],   c[i][3]
                                               c[i+1][0], c[i+1][1], c[i+1][2], c[i+1][3]} */
        /* Compute the address of A[i][k] */
        /* Address of A[i][k] is A + 4*(4*i + k) */
        add r8, r4, r5, LSL #2         /* r8 ← r4 + r5 << 2. This is r8 ← k + 4*i */
        add r8, r0, r8, LSL #2         /* r8 ← r0 + r8 << 2. This is r8 ← a + 4*(k + 4*i) */
        vldr s0, [r8]                  /* Load s0 ← a[i][k] */
        vldr s1, [r8, #16]             /* Load s1 ← a[i+1][k] */
 
        /* Compute the address of B[k][0] */
        /* Address of B[k][0] is B + 4*(4*k) */
        add r8, r1, r4, LSL #4         /* r8 ← r1 + r4 << 4. This is r8 ← b + 4*(4*k) */
        vldmia r8, {s16-s19}           /* Load {s16,s17,s18,s19} ← {b[k][0], b[k][1], b[k][2], b[k][3]} */
 
        vmla.f32 s8, s16, s0           /* {s8,s9,s10,s11} ← {s8,s9,s10,s11} + ({s16,s17,s18,s19} * {s0,s0,s0,s0}) */
        vmla.f32 s12, s16, s1          /* {s12,s13,s14,s15} ← {s12,s13,s14,s15} + ({s16,s17,s18,s19} * {s1,s1,s1,s1}) */
 
        vstmia r7, {s8-s15}            /* Store {c[i][0],   c[i][1],   c[i][2],    c[i][3],
                                                 c[i+1][0], c[i+1][1], c[i+1][2]}, c[i+1][3] }
                                                ← {s8,s9,s10,s11,s12,s13,s14,s15} */
 
        add r5, r5, #2  /* r5 ← r5 + 2. This is i = i + 2 */
        b .L4_loop_i /* next iteration of loop i */
       .L4_end_loop_i: /* Here ends loop i */
       add r4, r4, #1 /* r4 ← r4 + 1. This is k = k + 1 */
       b .L4_loop_k     /* next iteration of loop k */
    .L4_end_loop_k: /* Here ends loop k */
 
    /* Set the LEN field of FPSCR back to 1 (value 0) */
    mov r5, #0b011                        /* r5 ← 3 */
    mvn r5, r5, LSL #16                   /* r5 ← ~(r5 << 16) */
    fmrx r4, fpscr                        /* r4 ← fpscr */
    and r4, r4, r5                        /* r4 ← r4 & r5 */
    fmxr fpscr, r4                        /* fpscr ← r4 */
 
    vpop {s16-s19}                /* Restore preserved floating registers */
    pop {r4, r5, r6, r7, r8, lr}  /* Restore integer registers */
    end_ /* Leave function */

@void m4x4_multiply(GLfloat d[16], const GLfloat m0[16], const GLfloat m1[16])
@ scaler   vector
  row      output   
@  s0        s8      s16   s24
@  s7        s15     s23   s31
@  d[0] = m0[0]*m1[0] + m0[4]*m1[1] + m0[8]*m1[2] + m0[12]*m1[3];
  vldr	s13, [r1]              @ m0[0]
  vldr	s14, [r2]              @ m1[0]
  vldr	s15, [r1, #16]         @ m0[4]
  vldr	s12, [r2, #4]          @ m1[1]
  vmul.f32	s15, s15, s12
  vmla.f32	s15, s13, s14
  vldr	s13, [r1, #32]         @ m0[8]
  vldr	s14, [r2, #8]          @ m1[2]
  vmla.f32	s15, s13, s14
  vldr	s13, [r1, #48]	; 0x30 @ m0[12]
  vldr	s14, [r2, #12]         @ m1[3]
  vmla.f32	s15, s13, s14
  vstr	s15, [r0]

@  d[1] = m0[1]*m1[0] + m0[5]*m1[1] + m0[9]*m1[2] + m0[13]*m1[3];
  vldr	s13, [r1, #4]
  @vldr	s14, [r2]
  vldr	s15, [r1, #20]
  @vldr	s12, [r2, #4]
   130bc:	ee677a86 	vmul.f32	s15, s15, s12
   130c0:	ee467a87 	vmla.f32	s15, s13, s14
   130c4:	edd16a09 	vldr	s13, [r1, #36]	; 0x24
   130c8:	ed927a02 	vldr	s14, [r2, #8]
   130cc:	ee467a87 	vmla.f32	s15, s13, s14
   130d0:	edd16a0d 	vldr	s13, [r1, #52]	; 0x34
   130d4:	ed927a03 	vldr	s14, [r2, #12]
   130d8:	ee467a87 	vmla.f32	s15, s13, s14
   130dc:	edc07a01 	vstr	s15, [r0, #4]
  d[2] = m0[2]*m1[0] + m0[6]*m1[1] + m0[10]*m1[2] + m0[14]*m1[3];
   130e0:	edd16a02 	vldr	s13, [r1, #8]
   130e4:	ed927a00 	vldr	s14, [r2]
   130e8:	edd17a06 	vldr	s15, [r1, #24]
   130ec:	ed926a01 	vldr	s12, [r2, #4]
   130f0:	ee677a86 	vmul.f32	s15, s15, s12
   130f4:	ee467a87 	vmla.f32	s15, s13, s14
   130f8:	edd16a0a 	vldr	s13, [r1, #40]	; 0x28
   130fc:	ed927a02 	vldr	s14, [r2, #8]
   13100:	ee467a87 	vmla.f32	s15, s13, s14
   13104:	edd16a0e 	vldr	s13, [r1, #56]	; 0x38
   13108:	ed927a03 	vldr	s14, [r2, #12]
   1310c:	ee467a87 	vmla.f32	s15, s13, s14
   13110:	edc07a02 	vstr	s15, [r0, #8]
  d[3] = m0[3]*m1[0] + m0[7]*m1[1] + m0[11]*m1[2] + m0[15]*m1[3];
   13114:	edd16a03 	vldr	s13, [r1, #12]
   13118:	ed927a00 	vldr	s14, [r2]
   1311c:	edd17a07 	vldr	s15, [r1, #28]
   13120:	ed926a01 	vldr	s12, [r2, #4]
   13124:	ee677a86 	vmul.f32	s15, s15, s12
   13128:	ee467a87 	vmla.f32	s15, s13, s14
   1312c:	edd16a0b 	vldr	s13, [r1, #44]	; 0x2c
   13130:	ed927a02 	vldr	s14, [r2, #8]
   13134:	ee467a87 	vmla.f32	s15, s13, s14
   13138:	edd16a0f 	vldr	s13, [r1, #60]	; 0x3c
   1313c:	ed927a03 	vldr	s14, [r2, #12]
   13140:	ee467a87 	vmla.f32	s15, s13, s14
   13144:	edc07a03 	vstr	s15, [r0, #12]
  d[4] = m0[0]*m1[4] + m0[4]*m1[5] + m0[8]*m1[6] + m0[12]*m1[7];
   13148:	edd16a00 	vldr	s13, [r1]
   1314c:	ed927a04 	vldr	s14, [r2, #16]
   13150:	edd17a04 	vldr	s15, [r1, #16]
   13154:	ed926a05 	vldr	s12, [r2, #20]
   13158:	ee677a86 	vmul.f32	s15, s15, s12
   1315c:	ee467a87 	vmla.f32	s15, s13, s14
   13160:	edd16a08 	vldr	s13, [r1, #32]
   13164:	ed927a06 	vldr	s14, [r2, #24]
   13168:	ee467a87 	vmla.f32	s15, s13, s14
   1316c:	edd16a0c 	vldr	s13, [r1, #48]	; 0x30
   13170:	ed927a07 	vldr	s14, [r2, #28]
   13174:	ee467a87 	vmla.f32	s15, s13, s14
   13178:	edc07a04 	vstr	s15, [r0, #16]
  d[5] = m0[1]*m1[4] + m0[5]*m1[5] + m0[9]*m1[6] + m0[13]*m1[7];
   1317c:	edd16a01 	vldr	s13, [r1, #4]
   13180:	ed927a04 	vldr	s14, [r2, #16]
   13184:	edd17a05 	vldr	s15, [r1, #20]
   13188:	ed926a05 	vldr	s12, [r2, #20]
   1318c:	ee677a86 	vmul.f32	s15, s15, s12
   13190:	ee467a87 	vmla.f32	s15, s13, s14
   13194:	edd16a09 	vldr	s13, [r1, #36]	; 0x24
   13198:	ed927a06 	vldr	s14, [r2, #24]
   1319c:	ee467a87 	vmla.f32	s15, s13, s14
   131a0:	edd16a0d 	vldr	s13, [r1, #52]	; 0x34
   131a4:	ed927a07 	vldr	s14, [r2, #28]
   131a8:	ee467a87 	vmla.f32	s15, s13, s14
   131ac:	edc07a05 	vstr	s15, [r0, #20]
  d[6] = m0[2]*m1[4] + m0[6]*m1[5] + m0[10]*m1[6] + m0[14]*m1[7];
   131b0:	edd16a02 	vldr	s13, [r1, #8]
   131b4:	ed927a04 	vldr	s14, [r2, #16]
   131b8:	edd17a06 	vldr	s15, [r1, #24]
   131bc:	ed926a05 	vldr	s12, [r2, #20]
   131c0:	ee677a86 	vmul.f32	s15, s15, s12
   131c4:	ee467a87 	vmla.f32	s15, s13, s14
   131c8:	edd16a0a 	vldr	s13, [r1, #40]	; 0x28
   131cc:	ed927a06 	vldr	s14, [r2, #24]
   131d0:	ee467a87 	vmla.f32	s15, s13, s14
   131d4:	edd16a0e 	vldr	s13, [r1, #56]	; 0x38
   131d8:	ed927a07 	vldr	s14, [r2, #28]
   131dc:	ee467a87 	vmla.f32	s15, s13, s14
   131e0:	edc07a06 	vstr	s15, [r0, #24]
  d[7] = m0[3]*m1[4] + m0[7]*m1[5] + m0[11]*m1[6] + m0[15]*m1[7];
   131e4:	edd16a03 	vldr	s13, [r1, #12]
   131e8:	ed927a04 	vldr	s14, [r2, #16]
   131ec:	edd17a07 	vldr	s15, [r1, #28]
   131f0:	ed926a05 	vldr	s12, [r2, #20]
   131f4:	ee677a86 	vmul.f32	s15, s15, s12
   131f8:	ee467a87 	vmla.f32	s15, s13, s14
   131fc:	edd16a0b 	vldr	s13, [r1, #44]	; 0x2c
   13200:	ed927a06 	vldr	s14, [r2, #24]
   13204:	ee467a87 	vmla.f32	s15, s13, s14
   13208:	edd16a0f 	vldr	s13, [r1, #60]	; 0x3c
   1320c:	ed927a07 	vldr	s14, [r2, #28]
   13210:	ee467a87 	vmla.f32	s15, s13, s14
   13214:	edc07a07 	vstr	s15, [r0, #28]
  d[8] = m0[0]*m1[8] + m0[4]*m1[9] + m0[8]*m1[10] + m0[12]*m1[11];
   13218:	edd16a00 	vldr	s13, [r1]
   1321c:	ed927a08 	vldr	s14, [r2, #32]
   13220:	edd17a04 	vldr	s15, [r1, #16]
   13224:	ed926a09 	vldr	s12, [r2, #36]	; 0x24
   13228:	ee677a86 	vmul.f32	s15, s15, s12
   1322c:	ee467a87 	vmla.f32	s15, s13, s14
   13230:	edd16a08 	vldr	s13, [r1, #32]
   13234:	ed927a0a 	vldr	s14, [r2, #40]	; 0x28
   13238:	ee467a87 	vmla.f32	s15, s13, s14
   1323c:	edd16a0c 	vldr	s13, [r1, #48]	; 0x30
   13240:	ed927a0b 	vldr	s14, [r2, #44]	; 0x2c
   13244:	ee467a87 	vmla.f32	s15, s13, s14
   13248:	edc07a08 	vstr	s15, [r0, #32]
  d[9] = m0[1]*m1[8] + m0[5]*m1[9] + m0[9]*m1[10] + m0[13]*m1[11];
   1324c:	edd16a01 	vldr	s13, [r1, #4]
   13250:	ed927a08 	vldr	s14, [r2, #32]
   13254:	edd17a05 	vldr	s15, [r1, #20]
   13258:	ed926a09 	vldr	s12, [r2, #36]	; 0x24
   1325c:	ee677a86 	vmul.f32	s15, s15, s12
   13260:	ee467a87 	vmla.f32	s15, s13, s14
   13264:	edd16a09 	vldr	s13, [r1, #36]	; 0x24
   13268:	ed927a0a 	vldr	s14, [r2, #40]	; 0x28
   1326c:	ee467a87 	vmla.f32	s15, s13, s14
   13270:	edd16a0d 	vldr	s13, [r1, #52]	; 0x34
   13274:	ed927a0b 	vldr	s14, [r2, #44]	; 0x2c
   13278:	ee467a87 	vmla.f32	s15, s13, s14
   1327c:	edc07a09 	vstr	s15, [r0, #36]	; 0x24
  d[10] = m0[2]*m1[8] + m0[6]*m1[9] + m0[10]*m1[10] + m0[14]*m1[11];
   13280:	edd16a02 	vldr	s13, [r1, #8]
   13284:	ed927a08 	vldr	s14, [r2, #32]
   13288:	edd17a06 	vldr	s15, [r1, #24]
   1328c:	ed926a09 	vldr	s12, [r2, #36]	; 0x24
   13290:	ee677a86 	vmul.f32	s15, s15, s12
   13294:	ee467a87 	vmla.f32	s15, s13, s14
   13298:	edd16a0a 	vldr	s13, [r1, #40]	; 0x28
   1329c:	ed927a0a 	vldr	s14, [r2, #40]	; 0x28
   132a0:	ee467a87 	vmla.f32	s15, s13, s14
   132a4:	edd16a0e 	vldr	s13, [r1, #56]	; 0x38
   132a8:	ed927a0b 	vldr	s14, [r2, #44]	; 0x2c
   132ac:	ee467a87 	vmla.f32	s15, s13, s14
   132b0:	edc07a0a 	vstr	s15, [r0, #40]	; 0x28
  d[11] = m0[3]*m1[8] + m0[7]*m1[9] + m0[11]*m1[10] + m0[15]*m1[11];
   132b4:	edd16a03 	vldr	s13, [r1, #12]
   132b8:	ed927a08 	vldr	s14, [r2, #32]
   132bc:	edd17a07 	vldr	s15, [r1, #28]
   132c0:	ed926a09 	vldr	s12, [r2, #36]	; 0x24
   132c4:	ee677a86 	vmul.f32	s15, s15, s12
   132c8:	ee467a87 	vmla.f32	s15, s13, s14
   132cc:	edd16a0b 	vldr	s13, [r1, #44]	; 0x2c
   132d0:	ed927a0a 	vldr	s14, [r2, #40]	; 0x28
   132d4:	ee467a87 	vmla.f32	s15, s13, s14
   132d8:	edd16a0f 	vldr	s13, [r1, #60]	; 0x3c
   132dc:	ed927a0b 	vldr	s14, [r2, #44]	; 0x2c
   132e0:	ee467a87 	vmla.f32	s15, s13, s14
   132e4:	edc07a0b 	vstr	s15, [r0, #44]	; 0x2c
  d[12] = m0[0]*m1[12] + m0[4]*m1[13] + m0[8]*m1[14] + m0[12]*m1[15];
   132e8:	edd16a00 	vldr	s13, [r1]
   132ec:	ed927a0c 	vldr	s14, [r2, #48]	; 0x30
   132f0:	edd17a04 	vldr	s15, [r1, #16]
   132f4:	ed926a0d 	vldr	s12, [r2, #52]	; 0x34
   132f8:	ee677a86 	vmul.f32	s15, s15, s12
   132fc:	ee467a87 	vmla.f32	s15, s13, s14
   13300:	edd16a08 	vldr	s13, [r1, #32]
   13304:	ed927a0e 	vldr	s14, [r2, #56]	; 0x38
   13308:	ee467a87 	vmla.f32	s15, s13, s14
   1330c:	edd16a0c 	vldr	s13, [r1, #48]	; 0x30
   13310:	ed927a0f 	vldr	s14, [r2, #60]	; 0x3c
   13314:	ee467a87 	vmla.f32	s15, s13, s14
   13318:	edc07a0c 	vstr	s15, [r0, #48]	; 0x30
  d[13] = m0[1]*m1[12] + m0[5]*m1[13] + m0[9]*m1[14] + m0[13]*m1[15];
   1331c:	edd16a01 	vldr	s13, [r1, #4]
   13320:	ed927a0c 	vldr	s14, [r2, #48]	; 0x30
   13324:	edd17a05 	vldr	s15, [r1, #20]
   13328:	ed926a0d 	vldr	s12, [r2, #52]	; 0x34
   1332c:	ee677a86 	vmul.f32	s15, s15, s12
   13330:	ee467a87 	vmla.f32	s15, s13, s14
   13334:	edd16a09 	vldr	s13, [r1, #36]	; 0x24
   13338:	ed927a0e 	vldr	s14, [r2, #56]	; 0x38
   1333c:	ee467a87 	vmla.f32	s15, s13, s14
   13340:	edd16a0d 	vldr	s13, [r1, #52]	; 0x34
   13344:	ed927a0f 	vldr	s14, [r2, #60]	; 0x3c
   13348:	ee467a87 	vmla.f32	s15, s13, s14
   1334c:	edc07a0d 	vstr	s15, [r0, #52]	; 0x34
  d[14] = m0[2]*m1[12] + m0[6]*m1[13] + m0[10]*m1[14] + m0[14]*m1[15];
   13350:	edd16a02 	vldr	s13, [r1, #8]
   13354:	ed927a0c 	vldr	s14, [r2, #48]	; 0x30
   13358:	edd17a06 	vldr	s15, [r1, #24]
   1335c:	ed926a0d 	vldr	s12, [r2, #52]	; 0x34
   13360:	ee677a86 	vmul.f32	s15, s15, s12
   13364:	ee467a87 	vmla.f32	s15, s13, s14
   13368:	edd16a0a 	vldr	s13, [r1, #40]	; 0x28
   1336c:	ed927a0e 	vldr	s14, [r2, #56]	; 0x38
   13370:	ee467a87 	vmla.f32	s15, s13, s14
   13374:	edd16a0e 	vldr	s13, [r1, #56]	; 0x38
   13378:	ed927a0f 	vldr	s14, [r2, #60]	; 0x3c
   1337c:	ee467a87 	vmla.f32	s15, s13, s14
   13380:	edc07a0e 	vstr	s15, [r0, #56]	; 0x38
  d[15] = m0[3]*m1[12] + m0[7]*m1[13] + m0[11]*m1[14] + m0[15]*m1[15];
   13384:	edd16a03 	vldr	s13, [r1, #12]
   13388:	ed927a0c 	vldr	s14, [r2, #48]	; 0x30
   1338c:	edd17a07 	vldr	s15, [r1, #28]
   13390:	ed926a0d 	vldr	s12, [r2, #52]	; 0x34
   13394:	ee677a86 	vmul.f32	s15, s15, s12
   13398:	ee467a87 	vmla.f32	s15, s13, s14
   1339c:	edd16a0b 	vldr	s13, [r1, #44]	; 0x2c
   133a0:	ed927a0e 	vldr	s14, [r2, #56]	; 0x38
   133a4:	ee467a87 	vmla.f32	s15, s13, s14
   133a8:	edd16a0f 	vldr	s13, [r1, #60]	; 0x3c
   133ac:	ed927a0f 	vldr	s14, [r2, #60]	; 0x3c
   133b0:	ee467a87 	vmla.f32	s15, s13, s14
   133b4:	edc07a0f 	vstr	s15, [r0, #60]	; 0x3c
}
   133b8:	e12fff1e 	bx	lr

