@prog cmd-@wall
1 9999 d
1 i
: wallit
    preempt
    "me" match "w" flag? not if
        pop me @ "Permission denied."
        notify exit
    then

    "You shout, \"" over strcat "\"" strcat
    me @ swap notify

    "me" match name " shouts, \"" strcat swap strcat "\"" strcat

    1 condescr
    begin
	over 0 > while over
	dup descrcon condbref me @ dbcmp if pop continue then
	descrcon over connotify
	nextdescr
    repeat
    pop pop
;
.
c
q
@set cmd-@wall=W
