@ file.S - words used to work with files and shared libraries

@ ( flags path -- filedes )
@ open a file
@ path - address of path string null terminated
@ flags: 0 read, 1 write, 2 read/write
Forthword_ OPENF, 0, "open"
  x_d_             @ r1=flags
  do_ open
  end_

@ ( filedes -- )
@ close a file
@ filedes - file descriptor
Forthword_ CLOSEF, 0, "close"
  do_ close
  end_

@ (  filedes buffer length -- filedes buffer bytesread )
@ fetch bytes from an open file using filedes
@ number of bytes read left on wreg
Forthword_ READF, 0, "read"
  y_w_             @ r2 = length
  x_d0_            @ r1 = buffer
  d1_              @ r0 = filedes
  do_ read 
  end_

@ (  filedes buffer length -- filedes byteswritten )
@ write bytes to an open file using filedes
@ number of bytes written left on wreg
Forthword_ WRITEF, 0, "write"
  y_w_             @ r2 = length
  x_d_             @ r1 = buffer
  d0_              @ r0 = filedes
  do_ write 
  end_

@ ( x:mode path -- handle )
@ open a dynamic linked library (*.so)
@ path - address of path string null terminated
@ mode -  
Forthword_ DLOPEN, 0, "dlopen"
                   @ r0 path string
                   @ r1 mode
  do_ dlopen
  end_

@ ( x:symname handle -- funcptr )
@ get the address of a symbol in shared library with handle
@ symname - address of null terminated symbol name
@ funcptr - address of symbol if found 
Forthword_ DLSYM, 0, "dlsym"
                   @ r0 handle
                   @ r1 symname string
  do_ dlsym
  end_
  
@ ( handle -- flag )
@ close a shared library
@ flag - 0 if success  
Forthword_ DLCLOSE, 0, "dlclose"
  do_ dlclose
  end_

@ ( -- stringptr )
@ gets a human readable string describing the
@ most recent error that occurred from  dlopen,
@ dlsym, or dlclose since the last call to dlerror
Forthword_ DLERROR, 0, "dlerror"
  do_ dlerror
  end_

@ ( [arg1 x:arg2 y:arg3] calladdr -- [] )
@ call a dl symbol
@ with call arguments in r0 - r3 if 4 or less arguments
@ d0 - r0
@ x - r1
@ y - r2
Forthword_ DLCALL, 0, "dlcall"
  push_lr_
  r_a_
  a_w_
  w_d_
  blx areg
  a_r_
  end_
 