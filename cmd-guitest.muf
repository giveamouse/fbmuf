@prog cmd-guitest
1 99999 d
1 i
$include $lib/gui
$def tell descrcon swap connotify
  
: generic_handler[ int:dscr str:dlogid str:ctrlid str:guievent --
                   int:ExitRequest ]
  
    dlogid @ GUI_VALUES_GET
    var! vals
    
    guievent @ ctrlid @ "%s sent %s event!" fmtstring dscr @ tell 
  
    vals @ foreach
        swap "=" strcat dscr @ tell
        foreach
            "    " swap strcat dscr @ tell
            pop
        repeat
    repeat
    0
;
  
  
: gen_yesno_dlog[ str:Data str:Title str:Text addr:YesCB addr:NoCB --
                  dict:Handlers str:DlogId ]
  
    {SIMPLE_DLOG title @
        {DATUM "data"
            "value" data @
            }CTRL
        {LABEL ""
            "value" text @
            "colspan" 2
            }CTRL
        {BUTTON "yesbtn"
            "text" "Yes"
            "width" 8
            "newline" 0
            yescb @ address? if
                "|buttonpress" yescb @
            then
            }CTRL
        {BUTTON "nobtn"
            "text" "No"
            "width" 8
            nocb @ address? if
                "|buttonpress" nocb @
            then
            }CTRL
    }DLOG
    DESCR swap GUI_GENERATE
    dup GUI_DLOG_SHOW
;
  
  
: postyes_callback[ int:Dscr str:DlogID str:CtrlId str:Event --
                    int:ExitRequest ]
  
    dlogid @ GUI_VALUES_GET
    var! vals
 
    "This is where I would post the message." dscr @ tell
    vals @ foreach
        swap "=" strcat dscr @ tell
        foreach
            "    " swap strcat dscr @ tell
            pop
        repeat
    repeat
    0
;
  
  
: writecancelyes_cb[ int:Dscr str:DlogID str:CtrlId str:Event --
                     dict:GuiHandlerChanges dict:OtherHandlerChanges ]
  
    dlogid @ GUI_VALUES_GET "data" [] 0 []
    var! write_dlog
  
    write_dlog @ GUI_DLOG_CLOSE
    { write_dlog @ 0 }dict         (Tell caller to forget this dialog.)
    { }dict
;
  
  
: gui_cancelwrite_cb[ int:Dscr str:DlogID str:CtrlId str:Event --
                     dict:GuiHandlerChanges dict:OtherHandlerChanges ]
  
    {
        dlogid @ "Cancel new message"
        "Are you sure you want to cancel this new message?"
        'writecancelyes_cb 0 gen_yesno_dlog swap
    }dict
    { }dict
;
  
  
: gen_writer_dlog[ -- dict:Handlers str:DlogId ]
    {SIMPLE_DLOG "Post Message"
        {LABEL ""
            "value" "Subject"
            "newline" 0
            }CTRL
        {EDIT "subj"
            "value" "This is a subject"
            "sticky" "ew"
            }CTRL
        {LABEL ""
            "value" "Keywords"
            "newline" 0
            }CTRL
        {EDIT "keywd"
            "value" "Default keywords"
            "sticky" "ew"
            "hweight" 1
            }CTRL
        {MULTIEDIT "body"
            "value" ""
            "width" 80
            "height" 20
            "colspan" 2
            }CTRL
        {FRAME "bfr"
            "sticky" "ew"
            "colspan" 2
            {BUTTON "PostBtn"
                "text" "Post"
                "width" 8
                "sticky" "e"
                "hweight" 1
                "newline" 0
                "|buttonpress" 'generic_handler
                }CTRL
            {BUTTON "CancelBtn"
                "text" "Cancel"
                "width" 8
                "sticky" "e"
                "dismiss" 0
                "|buttonpress" 'gui_cancelwrite_cb
                }CTRL
        }CTRL
        ( "|_closed|buttonpress" 'gui_cancelwrite_cb )
    }DLOG
    DESCR swap GUI_GENERATE
    dup GUI_DLOG_SHOW
;
  
  
: gui_write_new_cb[ int:Dscr str:DlogID str:CtrlId str:Event --
                     dict:GuiHandlerChanges dict:OtherHandlerChanges ]
  
    { gen_writer_dlog swap }dict
    { }dict
;
  
  
: protyes_callback[ int:dscr str:dlogid str:ctrlid str:guievent --
                   int:ExitRequest ]
  
    dlogid @ GUI_VALUES_GET "data" [] 0 []
    "Message %s would have it's protection flag toggled here." fmtstring
    dscr @ tell
    0
;
  
  
: gui_protectmsg_cb[ int:Dscr str:DlogID str:CtrlId str:Event --
                     dict:GuiHandlerChanges dict:OtherHandlerChanges ]
  
    dlogid @ GUI_VALUES_GET "msgs" [] 0 [] atoi
    var! msgnum
    {
        msgnum @ intostr
        "Message protection"
        msgnum @
        "Are you sure you want to toggle message #%i's protection flag?"
        fmtstring
        'protyes_callback 0
        gen_yesno_dlog swap
    }dict
    { }dict
;
  
  
: delyes_callback[ int:dscr str:dlogid str:ctrlid str:guievent --
                   int:ExitRequest ]
  
    dlogid @ GUI_VALUES_GET "data" [] 0 []
    "Message %s would be deleted here." fmtstring
    dscr @ tell
    0
;
  
  
: gui_deletemsg_cb[ int:Dscr str:DlogID str:CtrlId str:Event --
                     dict:GuiHandlerChanges dict:OtherHandlerChanges ]
  
    dlogid @ GUI_VALUES_GET "msgs" [] 0 [] atoi
    var! msgnum
    {
        msgnum @ intostr "Delete message?" msgnum @
        "Are you sure you want to delete message #%i?"
        fmtstring 'delyes_callback 0 gen_yesno_dlog swap
    }dict
    { }dict
;
  
  
: gen_reader_dlog[ -- dict:Handlers str:DlogId ]
    {SIMPLE_DLOG "Read Messages"
        {LISTBOX "msgs"
            "value" "0"
            "sticky" "nswe"
            "options" {
                "Revar       Writing Gui Programs in MUF"
                "Fre'ta      Scripting in Trebuchet"
                "Points      Floating point error checking in MUF"
            }list
            "font" "fixed"
            "report" 1
            "height" 5
            "newline" 0
            }CTRL
        {FRAME "bfr"
            "sticky" "nsew"
            {BUTTON "WriteBtn"
                "text" "Write New"
                "width" 8
                "sticky" "n"
                "dismiss" 0
                "|buttonpress" 'gui_write_new_cb
                }CTRL
            {BUTTON "DelBtn"
                "text" "Delete"
                "width" 8
                "sticky" "n"
                "dismiss" 0
                "|buttonpress" 'gui_deletemsg_cb
                }CTRL
            {BUTTON "ProtectBtn"
                "text" "Protect"
                "width" 8
                "sticky" "n"
                "vweight" 1
                "dismiss" 0
                "|buttonpress" 'gui_protectmsg_cb
                }CTRL
            }CTRL
        {FRAME "header"
            "sticky" "ew"
            "colspan" 2
            {LABEL "from"
                "value" "Revar"
                "sticky" "w"
                "width" 16
                "newline" 0
                }CTRL
            {LABEL "subj"
                "value" "This is a subject."
                "sticky" "w"
                "newline" 0
                "hweight" 1
                }CTRL
            {LABEL "date"
                "value" "Fri Dec 24 15:52:30 PST 1999"
                "sticky" "e"
                "hweight" 1
                }CTRL
            }CTRL
        {MULTIEDIT "body"
            "value" ""
            "width" 80
            "height" 20
            "readonly" 1
            "hweight" 1
            "toppad" 0
            "colspan" 2
            }CTRL
    }DLOG
    DESCR swap GUI_GENERATE
    dup GUI_DLOG_SHOW
;
  
  
: gui_test[ str:cmdline -- ]
    DESCR GUI_AVAILABLE 0.0 > if
        background
        {
            gen_reader_dlog swap
        }dict
        {
            (no other events to watch for)
        }dict
        gui_event_process
        pop pop pop pop
    else
        ( Put in old-style config system here. )
        DESCR descrcon "Gui not supported!" connotify
    then
;
.
c
q
@register #me cmd-guitest=tmp/prog1
@set $tmp/prog1=3
