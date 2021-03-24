@ minimum.S

@ ( -- dp0 )
@ get start address of dictionary
Forthword_ DP0, 0, "dp0"
  lit32_ DPSTART
  end_

@ ( -- cp0 )
@ get start address of code
Forthword_ CP0, 0, "cp0"
  lit32_ CPSTART
  end_

@ ( -- )
@ must be last word in core
Forthword_ WIPE, 0, "WIPE"
   
.if BUILD_LEVEL >= COMPILER
  lit32_ DPSTART
  do_ DP_STR

  lit32_ CPSTART
  do_ CP_STR
.endif
    
  lit32_ EE_FORTHWORDLIST
  y_0_
  mw_y_
  add_4_
  mw_y_
       
  lit32_ HERESTART
  do_ HERE_STR

  end_do_ ONLY    
