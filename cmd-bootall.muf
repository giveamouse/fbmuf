@prog cmd-bootall
1 9999 d
1 i
: bootall
  "Disconnecting: " swap strcat
  "me" match me !
  concount begin
    dup while 1 -
    dup condbref me @ dbcmp not if
      dup 3 pick connotify
      dup conboot
    then
  repeat
  pop "Done." .tell
;
.
c
q
#ifdef NEW
@action bootall=me=tmp/bootall
@link $tmp/bootall=cmd-bootall
#endif
