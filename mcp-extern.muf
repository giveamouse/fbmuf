@prog mcp-extern.muf
1 99999 d
1 i
$def AUTHTOKEN "PASSWORD_HERE"

: check_auth[ dict:args -- int:is_ok ]
    args @ "auth" [] 0 []
    AUTHTOKEN strcmp not
;
 
: do_wall[ int:dscr dict:args -- ]
    args @ check_auth not if exit then
    online_array { }list array_union var! whoall
    { }list var! out
    args @ "mesg" []
    foreach swap pop
        "# " swap strcat
        out @ array_appenditem out !
    repeat
    out @ whoall @ array_notify
;
 
: main[ str:args -- ]
    "org-fuzzball-extern" 1.0 1.0 MCP_REGISTER_EVENT
    begin
        {
            "MCP.org-fuzzball-extern-wall"
        }list
        event_waitfor var! event var! ctx
        
        {
            "MCP.org-fuzzball-extern-wall" 'do_wall
        }dict
        event @ [] dup if
            ctx @ "descr" []
            ctx @ "args" []
            rot execute
        else
            pop
        then
    repeat
;
.
c
q
@register #me mcp-extern.muf=tmp/prog1
@set $tmp/prog1=W
@set $tmp/prog1=A
@set $tmp/prog1=3

