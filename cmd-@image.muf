@prog cmd-@image
1 99999 d
1 i
$include $lib/match
$include $lib/strings
  
lvar count
: list-imagers
    preempt
	descr "dns-org-fuzzball-image" mcp_supports
	0.0 > if
		var targrefs { }list targrefs !
		var urls { }list urls !
		me @ location contents
		begin
			dup while
			dup room? if next continue then
			count @ 1 + dup count ! 150 > if
				break
			then
			dup "_/image" getpropstr if
				dup targrefs @ array_append targrefs !
				"_/image" getpropstr
				urls @ array_append urls !
			then
			next
		repeat pop
		descr "dns-org-fuzzball-image" "viewable"
		{
			"refs"  targrefs @
			"urls"  urls @
		}dict
		mcp_send
	else
		"(@imaged objects)" .tell
		me @ location contents
		begin
			dup while
			dup room? if next continue then
			count @ 1 + dup count ! 50 > if
				"(Too many objects in this room.  Skipping the remainder.)"
				.tell break
			then
			dup "_/image" getpropstr if
				dup name .tell
			then
			next
		repeat pop
		"(Done.)" .tell
	then
;
  
  
$def }tell }list { me @ }list array_notify
 
: cmd-@image
    dup tolower "#help" stringcmp not if
		pop
		{
        "@Image ver. 2.0                        Copyright 7/10/1994 by Revar"
        "-------------------------------------------------------------------"
        "@image <object>            To see where to find a gif of the object"
        "@image <obj>=<URL>         To specify where one can find a gif of  "
        "                             that object.  The URL is the WWW URL  "
        "                             format for specifying where on the net"
        "                             a file is.                            "
        "@image <obj>=clear         To clear the image reference.           "
        "-------------------------------------------------------------------"
        "URLs have the following format:   type://machine.name/path/file"
        "If I wanted to show that people can find an image of Revar on"
		"www.belfry.com, via the web, I'd just do:"
        "    @image Revar=http://www.belfry.com/pics/revar-cw3.jpg"
        "  "
        "Those of you who have used the web should find URLs familiar."
		}tell
        exit
    then
    dup not if
        pop list-imagers
        exit
    then
    "=" split strip swap strip
    dup not if
		pop pop
        "Usage: @image <object>    or    @image <object>=<URL>" .tell
        exit
    then
    .noisy_match
	var targref targref !
	var newurl newurl !
    targref @ not if exit then
    newurl @ not if
        ( @image <object> )
        targref @ "_/image" getpropstr
		var currurl currurl !
		currurl @ not if
			"No image available." .tell
			pop exit
        then
		descr "dns-org-fuzzball-image" mcp_supports
		0.0 > if
		    descr "dns-org-fuzzball-image" "view"
			{
				"name" targref @ name
				"ref"  targref @
				"url"  currurl @
			}dict
			mcp_send
		else
			"?" ";" subst
			"?" "<" subst
			"?" ">" subst
			"?" "|" subst
			"?" "&" subst
			"?" "!" subst
			"?" "(" subst
			"?" ")" subst
			"?" "`" subst
			"?" "\"" subst
			"(@image) " swap strcat .tell
		then
    else
        ( @image <object>=<URL> )
        "me" match targref @ controls not if
            "Permission denied." .tell
            exit
        then
        newurl @ "clear" stringcmp not if
            targref @ "_/image" "" 0 addprop
            "Image unset." .tell
            exit
        then
        newurl @ "://" split strip swap strip
        dup "file" stringcmp
        over "http" stringcmp and
        over "ftp" stringcmp and if
            pop pop
            "Unknown URL service type.  The acceptable types are ftp, http, and file." .tell
            "Example:  http://www.furry.com/pics/revar-cw3.jpg" .tell
            exit
        then
        "://" strcat swap
        "/" split swap
        dup "*[^-:.a-z0-9_]*" smatch if
            "Invalid character in machine name.  Valid chars are a-z, 0-9, _, period, colon, and -." .tell
            pop pop pop exit
        then
        "/" strcat swap
        strcat strcat
        targref @ "_/image" rot 0 addprop
        "Image set." .tell
    then
;
.
c
q
@register #me cmd-@image=tmp/prog1
@set $tmp/prog1=L
@set $tmp/prog1=3
@action @image;@imag;@ima;@im=#0=tmp/exit1
@link $tmp/exit1=$tmp/prog1
