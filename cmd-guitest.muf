@prog cmd-guitest
1 99999 d
1 i
$include $lib/gui
$def tell descrcon swap connotify
  
: dlog1-okaybtn-handler (intDescr strDlogID strCtrlID strEvent -- intExit)
    var guievent guievent !
    var ctrlid ctrlid !
    var dlogid dlogid !
    var dscr dscr !
    var vals dlogid @ GUI_VALUES_GET vals !
    
    guievent @ ctrlid @ "%s recieved %s event!" fmtstring dscr @ tell 
  
    vals @ foreach
        swap "=" strcat dscr @ tell
        foreach
            "    " swap strcat dscr @ tell
            pop
        repeat
    repeat
    0
;
  
: dlog1-cancelbtn-handler (intDescr strDlogID strCtrlId strEvent -- intExit)
    pop pop pop "Dialog cancelled!" swap tell
    0
;
  
: gui-test
    pop
    DESCR GUI_AVAILABLE 0.0 > if
        background
        {TABBED_DLOG "Post Message"
            {PANE "one" "Page One"
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
                    "width" 60
                    "height" 12
                    "colspan" 2
                    }CTRL
            }PANE
            {PANE "two" "Page Two"
                {COMBOBOX "combo"
                    "value" "First option"
                    "options" {
                            "First option"
                            "Second option"
                            "Third option"
                            "Fourth option"
                        }list
                    "hweight" 0
                    "colspan" 4
                    "sticky" "ew"
                    }CTRL
                {HRULE ""
                    "colspan" 4
                    }CTRL
                {CHECKBOX "cbox"
                    "text" "Request reciept"
                    "value" 0
                    "sticky" "w"
                    "newline" 0
                    }CTRL
                {VRULE ""
                    "rowspan" 3
                    "newline" 0
                    }CTRL
                {SPINNER "spin"
                    "value" 10
                    "sticky" "w"
                    "newline" 0
                    }CTRL
                {FRAME ""
                    "hweight" 1
                    }CTRL
            }PANE
        }DLOG
        DESCR swap GUI_GENERATE
        var dlog dlog !
        dlog @ GUI_DLOG_SHOW
        {
            dlog @ {
                "_ok|buttonpress" 'dlog1-okaybtn-handler
                "_apply|buttonpress" 'dlog1-okaybtn-handler
                "_cancel|buttonpress" 'dlog1-cancelbtn-handler
                "_closed|buttonpress" 'dlog1-cancelbtn-handler
            }dict
        }dict
        { }dict
        gui_event_process
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

