@ include.S

@ ( -- keyfileaddr )
@ get ram address of key file descriptor
Forthword_ KEYFILEADDR, 0, "keyf#"
    douser_ USER_KEYFILE

@ ( -- key )
@ fetch key from an open file using filedes, should leave
@ a single character on wreg or -1 if no more to read in file.
Forthword_ KEYFILE, 0, "keyfile"
  push {lr}
  bl KEYFILEADDR
  fetch_
  movs r0, wreg
  movs wreg, #0
  push_
  mov r1, dsp
  movs r2, #1
  bl read 
  pop_
  @ was one key read from the file?
  cmp r0, #1
  beq.n KEYEND
  subs wreg, #1
  bl BYE  
 KEYEND:
  pop {pc}

@ ( caddr -- ** )
@ open a file that will be used for key input
@ caddr points to null terminated file name
Forthword_ DOINCLUDE, 0, "doinclude"
    push {lr}
    @ set file open mode to reading
    zero_
    swap_
    bl OPENF     @ ( filedes )
    @ if file descriptor > 0 then open is success
    push_
    bl ZEROGREATER
    zerosense_
    
    beq.n DOINCLUDE_EXIT
  	  bl IDLETIMEFETCH
	    to_r_
	    bl SLEEPOFF
      @ push FFLAGS on tor
      bl FFLAGS
      hfetch_
      to_r_
      @ push on return stack the old defer key
      bl KEYADDR
      fetch_
      to_r_
      @ push old keyfile on return stack
      bl KEYFILEADDR
      fetch_
      to_r_
      bl KEYFILEADDR
      bl STORE
      @ defer key to keyfile for input
      dolit32_ KEYFILE
      bl KEYADDR
      bl STORE
      @ run interpreter
      bl DOTASKS
      @ close keyfile
      bl KEYFILEADDR
      fetch_
      bl CLOSEF
      @ pop tor into keyfile
      r_from_
      bl KEYFILEADDR
      bl STORE
      @ pop top of return into defer key
      r_from_
      bl KEYADDR
      bl STORE
      @ restore FFLAGS
      r_from_
      bl FFLAGS
      bl HSTORE
  		r_from_
      pop_lr_
	  	b IDLETIMESTORE
       
DOINCLUDE_EXIT:
    pop_
    type_ "File not found!"
    pop {pc}

@ ( C:filepath -- ** )
@ open a file that will be used for key input
Forthword_ INCLUDEF, 0, "include"
    push {lr}
    @ parse input for filename to include
    bl PNAME     @ ( addr len )
    @ add null to end of string
    over_         
    plus_
    bl ZEROCSTORE
    pop_lr_
    b DOINCLUDE

