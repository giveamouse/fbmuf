@prog cmd-@image
1 99999 d
1 i
$include $lib/match
$include $lib/strings
  
lvar count
: list-imagers
    preempt
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
;
  
  
: cmd-@image
    dup tolower "#help" stringcmp not if
        "@Image ver. 1.1                        Copyright 7/10/1994 by Revar" .tell
        "-------------------------------------------------------------------" .tell
        "@image <object>            To see where to find a gif of the object" .tell
        "@image <obj>=<URL>         To specify where one can find a gif of  " .tell
        "                             that object.  The URL is the WWW URL  " .tell
        "                             format for specifying where on the net" .tell
        "                             a file is.                            " .tell
        "@image <obj>=clear         To clear the image reference.           " .tell
        "-------------------------------------------------------------------" .tell
        "URL's have the following format:   type://machine.name/path/file   " .tell
        "For 95% of you on Furry, your gifs will be on avatar, available for" .tell
        "anonymous ftp.  The type for that would be 'file', and the machine " .tell
        "name, obviously, would be avatar.snc.edu.  So, if I wanted to show " .tell
        "that people can find an image of Revar on avatar, I'd just do:     " .tell
        "@image Revar=file://avatar.snc.edu/pub/furry/images/downloads/r/Revar-1-gw.gif" .tell
        "  " .tell
        "Those of you who have used Mosaic or lynx to access WWW might find " .tell
        "this URL format familiar.  It's because it's the same exact format." .tell
        "Please keep your info in this format, since it makes it easier, if," .tell
        "sometime in the future, someone were to write a graphical front end" .tell
        "for furryMUCK, then they could automatically get a picture of what " .tell
        "they looked at.  Anyone want to write said client program?         " .tell
        pop exit
    then
    dup not if
        pop list-imagers
        exit
    then
    "=" .split strip swap strip
    dup not if
        "Usage: @image <object>    or    @image <object>=<URL>" .tell
        pop pop exit
    then
    .noisy_match
    dup not if pop pop exit then
    swap dup not if
        ( @image <object> )
        pop "_/image" getpropstr
        dup not if
            pop "No image available."
        then
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
    else
        ( @image <object>=<URL> )
        "me" match 3 pick controls not if
            "Permission denied." .tell
            pop pop exit
        then
        dup "clear" stringcmp not if
            pop "_/image" "" 0 addprop
            "Image unset." .tell
            exit
        then
        "://" .split strip swap strip
        dup "file" stringcmp
        over "http" stringcmp and
        over "ftp" stringcmp and if
            pop pop pop
            "Unknown URL service type.  The acceptable types are ftp, http, and file." .tell
            "Example:  file://avatar.snc.edu/pub/furry/images/downloads/r/Revar-1-gw.gif" .tell
            exit
        then
        "://" strcat swap
        "/" .split swap
        dup "*[^-:.a-z0-9_]*" smatch if
            "Invalid character in machine name.  Valid chars are a-z, 0-9, _, period, and -." .tell
            pop pop pop pop exit
        then
        "/" strcat swap
        strcat strcat
        "_/image" swap 0 addprop
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
