@ file.S - words used to work with files and shared libraries

@ ( flags path -- filedes )
@ open a file
@ path - address of path string null terminated
@ flags: 0 read, 1 write, 2 read/write
Forthword_ OPENF, 0, "open"
  push_lr_
  ldmia dsp!, {r1} @ flags
  do_ open
  end_

@ ( filedes -- )
@ close a file
@ filedes - file descriptor
Forthword_ CLOSEF, 0, "close"
  push_lr_
  do_ close
  end_

@ (  filedes buffer length -- bytesread )
@ fetch bytes from an open file using filedes
@ number of bytes read left on wreg
Forthword_ READF, 0, "read"
  push_lr_
  x_w_             @ r2 = length
  ldmia dsp!, {r1} @ r1 = buffer
  w_d_             @ r0 = filedes
  do_ read 
  end_

@ (  filedes buffer length -- byteswritten )
@ write bytes to an open file using filedes
@ number of bytes written left on wreg
Forthword_ WRITEF, 0, "write"
  push_lr_
  x_w_             @ r2 = length
  ldmia dsp!, {r1} @ r1 = buffer
  w_d_             @ r0 = filedes
  do_ write 
  end_

.if 0
@ ( mode path -- handle )
@ open a dynamic linked library (*.so)
@ path - address of path string null terminated
@ mode -  
Forthword_ DLOPEN, 0, "dlopen"
  push {lr}
  mov r0, wreg @ path
  pop_
  mov r1, wreg @ mode
  bl dlopen
  mov wreg, r0
  pop {pc}

@ ( symname handle -- funcptr )
@ get the address of a symbol in shared library with handle
@ symname - address of null terminated symbol name
@ funcptr - address of symbol if found 
Forthword_ DLSYM, 0, "dlsym"
  push {lr}
  mov r0, wreg @ handle
  pop_
  mov r1, wreg @ symname
  bl dlsym
  mov wreg, r0
  pop {pc}
  
@ ( handle -- flag )
@ close a shared library
@ flag - 0 if success  
Forthword_ DLCLOSE, 0, "dlclose"
  push {lr}
  mov r0, wreg @ handle
  bl dlclose
  mov wreg, r0
  pop {pc}

@ ( -- stringptr )
@ gets a human readable string describing the
@ most recent error that occurred from  dlopen,
@ dlsym, or dlclose since the last call to dlerror
Forthword_ DLERROR, 0, "dlerror"
  push {lr}
  bl dlerror
  push_
  mov wreg, r0
  pop {pc}

@ ( calladdr -- [] )
@ call a dl symbol with no call arguments  
Forthword_ DLCALL0, 0, "dlcall0"
  push {lr}
  blx wreg
  mov wreg, r0
  pop {pc}

@ ( arg1 calladdr -- [] )
@ call a dl symbol with one call arguments  
Forthword_ DLCALL1, 0, "dlcall1"
  push {lr}
  mov r1, wreg @ call addr
  pop_
  mov r0, wreg @ arg1
  blx r1
  mov wreg, r0
  pop {pc}
  
.endif
