@prog lib-install=tmp/prog1
1 19999 d
i
( Common MUF Interface -- Installation/Upgrade Component )
( Designed 3/98 by Triggur )

( V1.0 : {04/04/98} Inception - Triggur )
( V1.1 : {01/21/02} Wizbit check fix - Nightwind )
( V1.2 : {06/03/04} Wizbit check REAL fix, and bootstrap fix - Winged )

$define VERSION "1.1" $enddef 

$define INSTALLCMD "@install;@uninstall" $enddef

$define INSTALLLIB "install" $enddef

$define INSTALLREG "install" $enddef

($define FUNCTION-WIZ-CHECK me @ "W" flag? not caller "W" flag? not or if me @ "ERROR: Only a wizard can use this function." notify exit then $enddef)
( This was apparently hanging things up before... the wizcheck's not working on modern mucks.  Instead, @lock the @install command to be run ONLY by #1 Wizard )
( $define FUNCTION-WIZ-CHECK 1 pop $enddef )

lvar tstr1
lvar tstr2
lvar tstr3
lvar tdb1
lvar tdb2
lvar tint1

lvar ltstr1
lvar ltstr2
lvar ltstr3
lvar ltdb1
lvar ltdb2
lvar ltint1

( ------------------------------------------------------------------- )
( WIZ-CHECK: Check to see if wizard permissions exist                 )
( ------------------------------------------------------------------- )

: WIZ-CHECK ( -- )
  me @ "wizard" flag? ( -- i1 ) ( person running has a wizard flag )
  caller "wizard" flag? ( -- i1 i2 ) ( caller has a wizard flag )
  caller owner "truewizard" flag? and ( -- i1 i2 )
    ( caller has wiz flag AND owner of caller is a wizard )
  dup if ( if caller has wizard flag... )
    caller "setuid" flag? ( -- i1 i2 ics )
      ( does the caller have a setuid flag? )
    caller "harduid" flag? ( -- i1 i2 ics ich )
      ( does the caller have a harduid flag? )
    and ( -- i1 i2 icsh ) not ( if caller both SH, caller has no wizbit )
    and ( -- i1 iwizperm )
  then
  or ( -- i )  ( one of the two has a wizbit flag )
  not if
    "ERROR: This function may only be called by a wizard!" me @ swap notify
    exit
  then 
;

: FUNCTION-WIZ-CHECK
  WIZ-CHECK
;

: INSTALL-WIZ-CHECK
  WIZ-CHECK
;

: UNINSTALL-WIZ-CHECK
  WIZ-CHECK
;

( ------------------------------------------------------------------- )
( add {or update} a global command {WIZ ONLY}                         )
( ------------------------------------------------------------------- )
: add-global-command ( d s -- )
  tstr1 ! tdb1 !

  FUNCTION-WIZ-CHECK

  tstr1 @ ";" instr dup 0 if
    tstr1 @ swap 1 - strcut pop tstr2 !
  else
    pop tstr1 @ swap strcut swap pop tstr2 !
  then                               ( tstr2 = first command in list )

  #0 tstr2 @ rmatch int 0 < if  (create exit if it doesnt exist )
    me @ "Installing global '" tstr1 @ strcat "'..." strcat notify
    #0 tstr1 @ newexit
  then

  #0 tstr2 @ rmatch name tstr1 @ stringcmp if    ( update command list )
    #0 tstr2 @ rmatch dup tstr1 @ setname
  then

  #0 tstr2 @ rmatch getlink tdb1 @ dbcmp not if (update destination )
    #0 tstr2 @ rmatch #-1 setlink
    #0 tstr2 @ rmatch tdb1 @ setlink
  then
;

( ------------------------------------------------------------------- )
( remove a global command from #0 {WIZ ONLY}                          )
( ------------------------------------------------------------------- )
: remove-global-command ( s -- )
  tstr1 !

  FUNCTION-WIZ-CHECK

  tstr1 @ ";" instr dup 0 if
    tstr1 @ swap 1 - strcut pop tstr2 !
  else
    pop tstr1 @ tstr2 !
  then                               ( tstr2 = first command in list )

  #0 tstr2 @ rmatch int 0 < not if  (delete it only if it exists, of course)
    me @ "Removing global '" tstr1 @ strcat "'..." strcat notify
    #0 tstr2 @ rmatch recycle
  then
;


( ------------------------------------------------------------------- )
( add {or update} a global library entry {WIZ ONLY}                   )
( THIS COMMAND MUST BE RUN BEFORE ANY CALLS TO export-* !!!           )
( ------------------------------------------------------------------- )
: add-global-library ( d s -- )
  tstr1 ! tdb1 !

  FUNCTION-WIZ-CHECK

  me @ "Registering library '" tstr1 @ strcat "'..." strcat notify
  #0 "_reg/lib/" tstr1 @ strcat tdb1 @ setprop

  caller "_lib-name" tstr1 @ 0 addprop
;

( ------------------------------------------------------------------- )
( Remove a global library entry {WIZ ONLY}                            )
( THIS COMMAND CAN ONLY BE RUN AFTER ANY CALLS TO LIBRARY FUNCTIONS!  )
( ------------------------------------------------------------------- )
: remove-global-library ( s -- )
  tstr1 !

  FUNCTION-WIZ-CHECK

  me @ "Deregistering library '" tstr1 @ strcat "'..." strcat notify
  #0 "_reg/lib/" tstr1 @ strcat remove_prop
;

( ------------------------------------------------------------------- )
( add {or update} a global registry entry {WIZ ONLY}                  )
( ------------------------------------------------------------------- )
: add-global-registry ( d s -- )
  tstr1 ! tdb1 !

  FUNCTION-WIZ-CHECK

  me @ "Registering '" tstr1 @ strcat "'..." strcat notify
  #0 "_reg/" tstr1 @ strcat tdb1 @ setprop
;

( ------------------------------------------------------------------- )
( remove a global registry entry {WIZ ONLY}                           )
( ------------------------------------------------------------------- )
: remove-global-registry ( s -- )
  tstr1 !

  FUNCTION-WIZ-CHECK

  me @ "Deregistering '" tstr1 @ strcat "'..." strcat notify
  #0 "_reg/" tstr1 @ strcat remove_prop
;

( ------------------------------------------------------------------- )
( Create the _defs text to export a library function {WIZ ONLY}       )
( ------------------------------------------------------------------- )
: export-function ( d s -- )
  tstr1 ! tdb1 !

  FUNCTION-WIZ-CHECK
( ALSO CAUSING PROBLEMS?
  tdb1 @ "_lib-name" getpropstr "" strcmp not if
    me @ "$LIB/INSTALL: CONFIGURATION ERROR: export-function cannot "
         "be called until after export-global-library is called!" strcat
    notify
    exit
  then
)
  me @ "Exporting " tdb1 @ name strcat " function '" strcat tstr1 @ strcat
      "'..." strcat notify

  tdb1 @ "_defs/" tstr1 @ strcat "\"$lib/" tdb1 @ "_lib-name" getpropstr
      strcat  "\" match \"" strcat tstr1 @ strcat "\" call" strcat 0 addprop
;

( ------------------------------------------------------------------- )
( Create the _defs text to export a library macro {WIZ ONLY}          )
( ------------------------------------------------------------------- )
: export-macro ( d s s -- )
  tstr2 ! tstr1 ! tdb1 !

  FUNCTION-WIZ-CHECK

  me @ "Exporting " tdb1 @ name strcat " macro '" strcat tstr1 @ strcat
      "'..." strcat notify

  tdb1 @ "_defs/" tstr1 @ strcat tstr2 @ 0 addprop
;

( ------------------------------------------------------------------- )
( declare the version of a library {WIZ ONLY}                         )
( ------------------------------------------------------------------- )
: set-library-version ( d s -- )
  tstr1 ! tdb1 !

  FUNCTION-WIZ-CHECK

  me @ "Setting library " tdb1 @ name strcat " version to '" strcat
      tstr1 @ strcat "'." strcat notify
  tdb1 @ "_lib-version" tstr1 @ 0 addprop
;

( ------------------------------------------------------------------- )
( fetch the version of a library                                      )
( ------------------------------------------------------------------- )
: get-library-version ( d -- s )
  tdb1 !

  tdb1 @ "_lib-version" getpropstr
;

( ------------------------------------------------------------------- )
( call a MUF program's do-install function                            )
( ------------------------------------------------------------------- )
: perform-install ( s -- )
  ltstr1 !

  FUNCTION-WIZ-CHECK

  #-1 ltdb1 !

  ltstr1 @ 1 strcut pop "#" stringcmp not if (is a dbref)
    ltstr1 @ 1 strcut swap pop atoi dbref dup ltdb1 ! name ltstr1 !
  else
    #0 "_ver/" tstr1 @ strcat "/prog" strcat getpropstr dup "" strcmp not if
      me @ "ERROR: Unknown program.  Use MUF name or dbref." notify
      pop exit
    then
    int dbref name ltstr1 !
  then

  ltdb1 @ #-1 dbcmp if
    #0 "_ver/" ltstr1 @ strcat "/prog" strcat getprop dbref ltdb1 !
  then
  #0 "_ver/" ltstr1 @ strcat "/vers" strcat getpropstr ltstr2 !

  ltdb1 @ program? not if
    me @ "@INSTALL ERROR: Dbref #" ltdb1 @ intostr strcat " is not a program."
        strcat notify
    exit
  then

  ltstr2 @ ltdb1 @ "do-install" call ltstr3 !   ( call the program's installer )

  ltstr3 @ "" stringcmp not if
    me @ "WARNING: Installation not completed." notify
    exit
  then

  ltstr3 @ ltstr2 @ stringcmp not if
    me @ "@INSTALL: " ltstr1 @ strcat " reports version " strcat ltstr2 @ strcat
        " already installed." strcat notify
  else
    me @ "@INSTALL: Upgraded " ltstr1 @ strcat " to version " strcat ltstr3 @
        strcat "." strcat notify
  then

  #0 "_ver/" ltstr1 @ strcat "/prog" strcat ltdb1 @ setprop
  #0 "_ver/" ltstr1 @ strcat "/vers" strcat ltstr3 @ 0 addprop
;

( ------------------------------------------------------------------- )
( call a MUF program's do-uninstall function                          )
( ------------------------------------------------------------------- )
: perform-uninstall ( s -- )
  ltstr1 !

  FUNCTION-WIZ-CHECK
 
  ltstr1 @ 1 strcut pop "#" stringcmp not if (is a dbref)
    ltstr1 @ 1 strcut swap pop atoi dbref dup ltdb1 ! name ltstr1 !
  else
    #0 "_ver/" ltstr1 @ strcat "/prog" strcat getpropstr dup "" strcmp not if
      me @ "ERROR: Unknown program.  Use MUF name or dbref." notify
      pop exit
    then
    int dbref name ltstr1 !
  then

  ltdb1 @ #-1 dbcmp if
    #0 "_ver/" ltstr1 @ strcat "/prog" strcat getprop dbref ltdb1 !
  then
  #0 "_ver/" ltstr1 @ strcat "/vers" strcat getpropstr ltstr2 !

  ltdb1 @ program? not if
    me @ "@INSTALL ERROR: Dbref #" ltdb1 @ intostr strcat " is not a program."
        strcat notify
    exit
  then

  ltstr2 @ ltdb1 @ "do-uninstall" call ltstr3 ! (call program's uninstaller )

  ltstr3 @ "" stringcmp not if
    me @ "WARNING: Installation not completed." notify
    exit
  then

  #0 "_ver/" ltstr1 @ strcat remove_prop

  me @ "@UNINSTALL: Removed " ltstr1 @ strcat " from the system." strcat notify
;

( ------------------------------------------------------------------- )
( PUBLIC: Perform installation/upgrade of this command                )
( ------------------------------------------------------------------- )
: do-install ( s -- s )

  INSTALL-WIZ-CHECK

  prog "W" flag? not if 
    me @ "ADMIN: Do @SET #" prog intostr strcat "=W" strcat notify
    me @ "ADMIN: Then re-run " command @ strcat " #" strcat prog intostr strcat
        notify
    "" exit
  then

  prog "L" set  ( make it publically linkable )

  prog INSTALLCMD add-global-command
  prog INSTALLLIB add-global-library 
  prog INSTALLREG add-global-registry 

  prog "add-global-command" export-function
  prog "add-global-library" export-function
  prog "add-global-registry" export-function
  prog "export-function" export-function
  prog "export-macro" export-function
  prog "set-library-version" export-function
  prog "get-library-version" export-function
  prog "remove-global-command" export-function
  prog "remove-global-library" export-function
  prog "remove-global-registry" export-function

(  prog "INSTALL-WIZ-CHECK" "me @ \"W\" flag? not caller \"W\" flag? not or if me @ \"ERROR: Only a wizard can use this function.\" notify \"\" exit then"
      export-macro

  prog "UNINSTALL-WIZ-CHECK" "me @ \"W\" flag? not caller \"W\" flag? not or if me @ \"ERROR: Only a wizard can use this function.\" notify \"\" exit then"
      export-macro )
  prog "INSTALL-WIZ-CHECK" export-function
  prog "UNINSTALL-WIZ-CHECK" export-function
  prog "FUNCTION-WIZ-CHECK" export-function

  prog VERSION set-library-version

  VERSION 
; 

( ------------------------------------------------------------------- )
( PUBLIC: Perform uninstallation of this command                      )
( ------------------------------------------------------------------- )
: do-uninstall ( s -- s )
  pop

  UNINSTALL-WIZ-CHECK

  prog INSTALLCMD remove-global-command
  prog INSTALLLIB remove-global-library 
  prog INSTALLREG remove-global-registry 

  me @ "The program can now be removed entirely by typing @rec #" prog intostr
      strcat notify

  VERSION 
; 

: main ( s -- )

  dup "" stringcmp not if
    me @ "USAGE:  @install #<program or library dbref>" notify
    0 exit
  then

  command @ "@install" stringcmp not if
    perform-install
    0 exit
  then

  command @ "@uninstall" stringcmp not if
    perform-uninstall
    0 exit
  then
  
  me @ "Unknown CMI call " command @ strcat "." strcat notify
;

PUBLIC add-global-command
PUBLIC add-global-library
PUBLIC add-global-registry
PUBLIC export-function
PUBLIC export-macro
PUBLIC set-library-version
PUBLIC get-library-version
PUBLIC remove-global-command
PUBLIC remove-global-library
PUBLIC remove-global-registry
PUBLIC INSTALL-WIZ-CHECK
PUBLIC UNINSTALL-WIZ-CHECK
PUBLIC FUNCTION-WIZ-CHECK

PUBLIC do-install
PUBLIC do-uninstall
.
c
q
@set lib-install=w
@action @install;@uninstall=me
@link @install=lib-install
@install $tmp/prog1
