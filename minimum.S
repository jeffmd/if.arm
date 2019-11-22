@ minimum.S

@ must be last word in core
Forthword_ WIPE, 0, "WIPE"
  push_lr_
   
.if BUILD_LEVEL > 9
  lit32_ DPSTART
  y_w_
  do_ DPSHARP
  mw_y_

  lit32_ CPSTART
  y_w_
  do_ CPSHARP
  mw_y_
.endif
    
  lit32_ EE_FORTHWORDLIST
  y_0_
  mw_y_
  fourplus_
  mw_y_
       
  lit32_ HERESTART
  y_w_
  do_ HEREADDR
  mw_y_

  end_do_ ONLY    
