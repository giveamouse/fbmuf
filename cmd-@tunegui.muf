@prog cmd-@tunegui
1 99999 d
1 i
$include $lib/case
$include $lib/gui
 
lvar parmsitems
 
: parms_init[ -- ]
    "" sysparm_array
    SORTTYPE_CASEINSENS "name"  array_sort_indexed
    SORTTYPE_CASEINSENS "type"  array_sort_indexed
    SORTTYPE_CASEINSENS "group" array_sort_indexed
    parmsitems !
;
 
: filter_my_array[ list:arr str:field str:val -- list:arr ]
    { }list var! out
    arr @ foreach swap pop
        dup field @ []
        val @ stringcmp not if
            out @ array_appenditem out !
        else pop
        then
    repeat
    out @
;
 
: process_results[ dict:context str:dlogid str:ctrlid str:event -- int:exit ]
    0 var! ctrlval
    "" var! errs
    context @ "values" [] var! vals
    vals @ "ctrl_cnt" [] 0 [] atoi
    0 swap -- 1 for var! cnt
        ( FIXME: do something with the data here. )
        vals @ cnt @ "type_%03i" fmtstring [] 0 [] var! ctrltype
        vals @ cnt @ "name_%03i" fmtstring [] 0 [] var! ctrlname
        ctrltype @ case
            "timespan" stringcmp not when
                vals @ cnt @ "value_days_%03i" fmtstring [] 0 [] atoi 24 *
                vals @ cnt @ "value_hrs_%03i"  fmtstring [] 0 [] atoi + 60 *
                vals @ cnt @ "value_mins_%03i" fmtstring [] 0 [] atoi + 60 *
                vals @ cnt @ "value_secs_%03i" fmtstring [] 0 [] atoi +
                intostr "s" strcat ctrlval !
            end
            "string" stringcmp not when
                vals @ cnt @ "value_%03i" fmtstring [] 0 [] ctrlval !
            end
            "integer" stringcmp not when
                vals @ cnt @ "value_%03i" fmtstring [] 0 [] ctrlval !
            end
            "float" stringcmp not when
                vals @ cnt @ "value_%03i" fmtstring [] 0 [] ctrlval !
            end
            "dbref" stringcmp not when
                vals @ cnt @ "value_%03i" fmtstring [] 0 []
                match dup int 0 < if
                    pop "*BAD*"
                else
                    "%d" fmtstring
                then
                ctrlval !
            end
            "boolean" stringcmp not when
                vals @ cnt @ "value_%03i" fmtstring [] 0 [] atoi
                if "yes" else "no" then ctrlval !
            end
            default
                "Invalid control type!" abort
            end
        endcase
        0 try
            ctrlname @ ctrlval @ setsysparm
        catch
            pop
            errs @
            dup if "\n" strcat then
            ctrlname @ swap "%sBad value for %s." fmtstring
            errs !
        endcatch 
    repeat
    errs @ if
        dlogid @ "errtext" errs @ gui_value_set
    else
        dlogid @ gui_dlog_deregister
        dlogid @ gui_dlog_close
    then
    0
;
 
: gui_dlog_generic[ str:title arr:descript -- dict:Handlers str:DlogId ]
    {SIMPLE_DLOG title @
        {LABEL "errtext"
            "value"   "Edit the following data and click on 'Save' to commit the changes."
            "colspan" 2
            "newline" 1
            "sticky"  "w"
        }CTRL
        descript @
        foreach var! item var! cnt
            {DATUM cnt @ "type_%03i" fmtstring
                "value" item @ "type" []
            }CTRL
            {DATUM cnt @ "name_%03i" fmtstring
                "value" item @ "name" []
            }CTRL
            item @ "type" []
            case
                "string" stringcmp not when
                    {LABEL ""
                        "value"  item @ "name" []
                        "newline" 0
                        "sticky" "w"
                    }CTRL
                    {EDIT cnt @ "value_%03i" fmtstring
                        "value" item @ "value" []
                        "sticky" "ew"
                        "width"  60
                        "hweight" 1
                        "newline" 1
                    }CTRL
                end
                "integer" stringcmp not when
                    {LABEL ""
                        "value"  item @ "name" []
                        "newline" 0
                        "sticky" "w"
                    }CTRL
                    {SPINNER cnt @ "value_%03i" fmtstring
                        "value" item @ "value" []
                        "maxval"  999999999
                        "sticky" "w"
                        "width"  11
                        "hweight" 1
                        "newline" 1
                    }CTRL
                end
                "float" stringcmp not when
                    ( FIXME: Must implement this sometime. )
                end
                "dbref" stringcmp not when
                    {LABEL ""
                        "value"  item @ "name" []
                        "newline" 0
                        "sticky" "w"
                    }CTRL
                    {EDIT cnt @ "value_%03i" fmtstring
                        "value" item @ "value" []
                        "sticky" "w"
                        "width"  30
                        "hweight" 1
                        "newline" 1
                    }CTRL
                end
                "timespan" stringcmp not when
                    {LABEL ""
                        "value"  item @ "name" []
                        "newline" 0
                        "sticky" "w"
                    }CTRL
                    {FRAME cnt @ "timefr_%03i" fmtstring
                        "sticky" "w"
                        {SPINNER cnt @ "value_days_%03i" fmtstring
                            "value" item @ "value" [] 86400 /
                            "maxval"  9999
                            "sticky" "w"
                            "width"   4
                            "hweight" 0
                            "newline" 0
                        }CTRL
                        {LABEL ""
                            "value" "Days"
                            "newline" 0
                            "leftpad" 2
                            "sticky" "w"
                        }CTRL
                        {SPINNER cnt @ "value_hrs_%03i" fmtstring
                            "value" item @ "value" [] 3600 / 24 %
                            "maxval"  23
                            "sticky" "w"
                            "width"   2
                            "hweight" 0
                            "newline" 0
                        }CTRL
                        {LABEL ""
                            "value" "Hrs"
                            "newline" 0
                            "leftpad" 2
                            "sticky" "w"
                        }CTRL
                        {SPINNER cnt @ "value_mins_%03i" fmtstring
                            "value" item @ "value" [] 60 / 60 %
                            "maxval"  59
                            "sticky" "w"
                            "width"   2
                            "hweight" 0
                            "newline" 0
                        }CTRL
                        {LABEL ""
                            "value" "Min"
                            "newline" 0
                            "leftpad" 2
                            "sticky" "w"
                        }CTRL
                        {SPINNER cnt @ "value_secs_%03i" fmtstring
                            "value" item @ "value" [] 60 %
                            "maxval"  59
                            "sticky" "w"
                            "width"   2
                            "hweight" 0
                            "newline" 0
                        }CTRL
                        {LABEL ""
                            "value" "Sec"
                            "newline" 1
                            "leftpad" 2
                            "sticky" "w"
                            "hweight" 1
                        }CTRL
                    }CTRL
                end
                "boolean" stringcmp not when
                    {CHECKBOX cnt @ "value_%03i" fmtstring
                        "text"  item @ "name" []
                        "value" item @ "value" []
                        "sticky" "w"
                        "colspan" 2
                        "newline" 1
                    }CTRL
                end
                default
                    "Unknown dlog item type!" abort
                end
            endcase
        repeat
        {DATUM "ctrl_cnt"
            "value" cnt @ ++
        }CTRL
        {HRULE "hrule1"
            "sticky"  "ew"
            "colspan" 2
        }CTRL
        {FRAME "btnfr"
            "sticky"  "ew"
            "colspan" 2
            {BUTTON "save"
                "text"    "&Save"
                "dismiss" 0
                "sticky"  "e"
                "width"   6
                "hweight" 1
                "newline" 0
                "dismiss" 0
                "|buttonpress" 'process_results
            }CTRL
            {BUTTON "cancel"
                "text"    "&Cancel"
                "width"   6
                "sticky"  "e"
            }CTRL
        }CTRL
    }DLOG
    DESCR swap GUI_GENERATE
    dup GUI_DLOG_SHOW
;
 
: make_group_specific_dlog[ str:group -- ]
    parms_init
    "Tunable System Parameters: " group @ strcat
    parmsitems @ "group" group @ filter_my_array
    gui_dlog_generic
    swap gui_dlog_register
;
 
: open_group_dlog_cb[ dict:context str:dlogid str:ctrlid str:event -- int:exit ]
    ctrlid @ "groupbtn_" strlen strcut swap pop
    "group_" swap strcat
    context @ "values" [] swap [] 0 []
    make_group_specific_dlog
    0
;
 
: make_groups_dlog[ -- ]
    "" var! lastgroup
    0 var! colnum
    4 var! maxcols
 
    {SIMPLE_DLOG "Tunable System Parameters"
        {LABEL "errtext"
            "value"   "Select the parameters group you with to edit."
            "colspan" maxcols @
            "newline" 1
            "sticky"  "w"
        }CTRL
        parmsitems @
        foreach swap var! cnt
            "group" []
            dup lastgroup @ stringcmp if
                lastgroup !
                {DATUM cnt @ "group_%03i" fmtstring
                    "value" lastgroup @
                }CTRL
                {BUTTON cnt @ "groupbtn_%03i" fmtstring
                    "text"    lastgroup @
                    "dismiss" 0
                    "sticky"  "nsew"
                    "width"   10
                    "hweight" 1
                    "newline"
                        colnum ++ colnum @
                        maxcols @ % not if
                            1 0 colnum !
                        else 0
                        then
                    "|buttonpress" 'open_group_dlog_cb
                }CTRL
            else
                pop
            then
        repeat
        colnum @ maxcols @ % if
        {FRAME "filler1"
            "newline" 1
        }CTRL
        then
        {HRULE "hrule1"
            "sticky"  "ew"
            "colspan" maxcols @
        }CTRL
        {FRAME "btnfr"
            "sticky"  "ew"
            "colspan" maxcols @
            {BUTTON "done"
                "text"    "&Done"
                "sticky"  "e"
                "width"   6
                "default" 1
                "hweight" 1
            }CTRL
        }CTRL
    }DLOG
    DESCR swap GUI_GENERATE
    dup GUI_DLOG_SHOW
    swap gui_dlog_register
;
 
: main[ str:args -- ]
    me @ "wizard" flag? not if
        me @ "Permission denied." notify
        exit
    then
    descr gui_available 1.0 < if
        me @ "Your client doesn't support MCP-GUI dialogs.  Use @tune instead." notify
        exit
    then
    parms_init
    make_groups_dlog
    background
    gui_event_process
;
 
.
c
q
@register #me cmd-@tunegui=tmp/prog1
@register #me cmd-@tunegui=tmp/prog1
@set $tmp/prog1=W
@set $tmp/prog1=3
@propset $tmp/prog1=str:/_/de:A scroll containing a spell called cmd-@tunegui
@action @tunegui;@tunegu;@tuneg;@tg=#0=tmp/exit1
@link $tmp/exit1=$tmp/prog1

