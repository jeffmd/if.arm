\ gpio.fs - words to manipulate gpio pins on Raspberry Pi
only
voc: GPIO
GPIO def

: root$ s" /sys/class/gpio/" ;
: exp$ s" export" ;
: unexp$ s" unexport" ;
: dir$ s" /direction" ;
: value$ s" /value" ;
: gpio$ s" gpio" ;
: in$ s" in" ;
: out$ s" out" ;
: inbuf$ s"    " ;

: .fail ." Failed to open GPIO: " ;
: .wrting ."  for writing!" ;

\ file open using null terminated buffer
: #>Open ( mode straddr len -- fs flag )
  #$ root$ #$ #>    ( mode addr len )
  =d open           ( fs )
  d= >0             ( fs flag )
;

\ write pin number to file
: writePin ( fs pin -- fs flag )
  <# #s #>       ( fs addr len )
  write          ( fs flag )
;

\ unexport a GPIO pin when no longer needed by user
: unexp ( pin --  )
  \ open unexport file for writing
  d= 1                ( pin 1 )
  <#_ unexp$ #>Open   ( pin fs flag)
  ==0
  ifnz
    d1                ( pin fs pin )
    writePin          ( pin fs flag )
    d0 close          ( pin fs ? )
  else
    .fail unexp$ type
    .wrting           ( pin fs ? )
  then
  d-2                 ( ? )
;

\ open the direction file
: dirOpen ( pin -- fs flag )
    y# 1 d=y       ( 1 pin Y:1 )
    <#_ dir$ #$    ( 1 pin ? )
    =d #s          ( 1 0 )
    gpio$ #>Open   ( fs flag)
;

\ wait for direction file to become available
: waitDirFile ( pin fs ? -- pin fs ? )
  begin
    d1           ( pin fs pin ) 
    dirOpen      ( pin fs fs2 flag )
    ==0
    =d           ( pin fs fs2 )
  untilnz
  close          ( pin fs ? )
;

\ export a pin - prepare for gpio use
: exp ( pin -- )
  d= 1             ( pin 1 )
  <#_ exp$ #>Open  ( pin fs flag )
  ==0 
  ifnz
    d1             ( pin fs pin )
    writePin       ( pin fs flag )
    d0 close       ( pin fs ? )
    waitDirFile    ( pin fs ? )
  else
    .fail exp$ type .wrting
  then
  d-2              ( ? )
;

\ select direction string
\ direction  string
\    0         in
\    1        out
: selDir$ ( direction -- addr len )
  ==0
  ifz
    in$     ( addr len )
  else
    out$    ( addr len )
  then
;

\ set direction of a GPIO pin that has been exported
\ if direction is 0 then pin will be input
\ if direction is 1 then pin will be output
: dir ( pin direction --  )
  \ open direction file for writing
  d= d1          ( pin direction pin )
  dirOpen        ( pin direction fs flag )
  ==0 
  ifnz
    d1           ( pin direction fs direction )
    selDir$      ( pin direction fs addr len )
    write        ( pin direction fs flag )
    d0 close     ( pin direction fs ? )
  else
    .fail ." direction" .wrting
  then
  d-3            ( pin direction fs ? )
;

\ Open gpio value file
\ mode: 0 file opened for reading
\ mode: 1 file opened for writing
: valOpen ( mode pin -- fs flag )
  \ open value file for writing
  <#_ value$ #$  ( mode pin ? )
  =d #s          ( mode 0 )
  gpio$ #>Open   ( fs flag)
;

\ write to gpio pin
: pinW ( pin val --  )
  y=d0 d0= 1     ( val 1 Y:pin )
  d= y           ( val 1 pin )
  valOpen        ( val fs flag )
  ==0
  ifnz
    d1           ( val fs val )
    writePin     ( val fs 1 )
  else
    .fail ." value" .wrting
  then
  d0             ( val fs fs )
  close          ( val fs ? )
  d-2            ( ? )
;

\ read from gpio pin
: pinR ( pin -- val )
  y=0 d=y        ( 0 pin ) 
  valOpen        ( fs flag )
  ==0
  ifnz
    inbuf$ read  ( fs buffer count )
    \ convert string val to integer
    1 num        ( fs val flag )
    d1 close     ( fs val ? )
    =d           ( fs val )
  else
    .fail ." value for reading!"
  then
  d-1            ( val )
;

\ setup a GPIO pin for input or output
\ automatically exports the pin 
\ if direction is 0 then pin will be input
\ if direction is 1 then pin will be output
: pin ( pin direction -- )
  d= d1    ( pin direction pin ) 
  exp      ( pin direction ? )
  =d dir   ( ? )
;

\ set pin as output
: output ( pin -- )
  d= 1 pin
;

\ set pin as input
: input ( pin -- )
  d= 0 pin
;

\ turn gpio pin to high state
: high ( pin -- )
  d= 1 pinW
;

\ turn gpio pin to low state
: low ( pin -- )
  d= 0 pinW
;

