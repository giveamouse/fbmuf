@prog lib-gui
1 99999 d
1 i
(
 GUI_GENERATE[ int:Dscr list:DlogSpec -- dict:Handlers str:DlogID ]
     Given a nested list that describes a dialog, sends all MCP commands
     neccesary to build that dialog, and returns a dictionary of callbacks
     to be called by that dialog's events, and the dialogID of the new
     dialog.  The dialog description list is built like:
         {SIMPLE_DLOG "Dialog Title"
             {LABEL "HelloLblCtrl"
                 "text" "Hello World!"
                 "sticky" "ew"
             }CTRL
             {BUTTON "OkayBtnCtrl"
                 "text" "Done"
                 "width" 6
                 "|buttonpress" 'done-callback
             }CTRL
         }DLOG
     Each control has a controlID [which may be blank, for anonymous controls]
     followed by either name-value pairs, or child controls, in the case of
     containers. [frame and notebook] ie:
         {SIMPLE_DLOG "Buttons!"
             {FRAME "ButtonFr"
                 "text" "Press one"
                 "visible" 1
                 {BUTTON "b1"
                     "text" "One"
                     "newline" 0
                     "|buttonpress" 'first-callback
                 }
                 {BUTTON "b2"
                     "text" "Two"
                     "|buttonpress" 'second-callback
                 }
             }CTRL
         }DLOG
     When an option name starts with a "|", then it is a callback, and
     the value is expected to be the function address to call when the
     named event is received for that control.  For events sent for
     automatically created controls, [ie: for the window close button]
     you can specify the callback by giving the Dialog itself a callback
     argument built from the virtual controlID and the event type. ie:
         {SIMPLE_DLOG "Hello"
             {LABEL ""
                 "text" "Hello World!"
                 "sticky" "ew"
             }CTRL
             "|_closed|buttonpress" 'done-callback
         }DLOG
     The {NOTEBOOK control is special in that it requires the child
     controls to be grouped in named panes.  You can do this like:
         {NOTEBOOK "nb"
             {PANE "pane1" "First Pane"
                 {BUTTON "firstbtn"
                     ...
                 }CTRL
             }PANE
             {PANE "pane2" "Second Pane"
                 {BUTTON "secondbtn"
                     ...
                 }CTRL
             }PANE
         }CTRL
     The supported controls are:
         {LABEL       A static test label.
         {HRULE       A horizontal line
         {VRULE       A vertical line
         {BUTTON      A pushbutton
         {CHECKBOX    A boolean on/off checkbox
         {EDIT        A single line text entry field
         {MULTIEDIT   A multi-line text entry field
         {COMBOBOX    An optionally editable text field with pulldown defaults.
         {SPINNER     An integer entry field with up/down buttons.
         {SCALE       A floating point slider control.
         {LISTBOX     A control for selecting one or more options.
         {FRAME       A box to put other controls in, with optional caption and outline.
         {NOTEBOOK    A notebook container, to organize controls into related panes.
     All controls support some special layout options.  These are:
         "sticky"     The sides of the cell to which this control will
                       stick.  Contains one or more of N, S, E, and W.
         "newline"    If false, next control will be to the right.  If true,
                       then it will be at the start of the next row.
         "colskip"    Number of columns to skip before placing this control.
         "colspan"    Number of columns this control's cell will span across.
         "rowspan"    Number of rows this control's cell will span across.
         "toppad"     Number of pixels to pad above the current row.
         "leftpad"    Number of pixels to pad to the left of the current col.
         "vweight"    Specifies the expansion ratio for the current row.
         "hweight"    Specifies the expansion ratio for the current column.
  
  
  
 GUI_EVENT_PROCESS[ dict:GuiHandlers dict:OtherHandlers -- dict:GuiHandlers' dict:OtherHandlers' dictArgs strEvent ]
     This waits for and processes events as they come in.  If there are
     callbacks available for each event, they will be called.
  
     This function takes two dictionaries as arguments.  The first is keyed
     by dialogID, with values that are themselves dictionaries of callback
     addresses, keyed by by controlID and gui-event type.  ie:
         {
             dlogid1 @ {
                 "OkayBtn|buttonpress"   'okaybtn-callback
                 "CancelBtn|buttonpress" 'cancel-callback
             }dict
             dlogid2 @ {
                 "_ok|buttonpress"     'okaybtn-callback
                 "_apply|buttonpress"  'okaybtn-callback
                 "_closed|buttonpress" 'cancel-callback
             }dict
         }dict
     This will let it deal with more than one dialog at a time if needed.
     Gui callbacks have the signature:
        [ int:Dscr str:DlogID str:CtrlID str:GuiEventType -- int:ExitRequested ]
     If the callback returns true, then GUI_EVENT_PROCESS will return.
  
     The second dictionary passed to GUI_EVENT_PROCESS is keyed with the
     names of any other event types that MUF may support.  The values are
     the addresses of the callback functions for each event.  ie:
         {
             "TIMER.1"  'timer1-callback
             "USER.foo" 'foo-callback
         }dict
     This is here for future expansion of the event system.
     Miscellaneous event callbacks have the signature:
        [ dict:Args str:EventType -- int:ExitRequested ]
     or
        [ dict:Args str:EventType -- dict:GuiHandlers dict:OtherHandlers ]
 
     In the first form, if the callback returns true, then GUI_EVENT_PROCESS
     will return.
  
     In the second form, the callback is requesting a change to the set of
     handlers that GUI_EVENT_PROCESS should deal with.  The GuiHandlers
     dictionary is for dialogs, and is in the same format as the GuiHandlers
     dictionary argument passed to GUI_EVENT_PROCESS.  The OtherHandlers
     dictionary is for miscellaneous events, and is in the format of the
     OtherHandlers dictionary argument passed to GUI_EVENT_PROCESS.  If the
     value associated with one of the keys in either dictionary is a false
     value, [ie: 0, null string, etc] then that event or dialog is explicitly
     forgotten about.  You must do this when you use the GUI_DLOG_CLOSE
     primitive in a callback, to let GUI_EVENT_PROCESS know that it no longer
     needs to worry about that dialog.
     
     GUI_EVENT_PROCESS will return when all dialogs have been dismissed, or
     when one of the callbacks returns true, or when an event is received for
     a dialog that this function wasn't told about.  The values returned are:
         1. The dictionary of remaining GUI dialog callbacks.
         2. The dictionary of remaining "other" event callbacks.
         3. The dictionary of data returned by EVENT_WAIT for the event that 
             triggered the exiting.
         4. The event string returned by EVENT_WAIT.
)
  
: list_parse[ list:spec -- dict:args list:ctrls ]
    ""      var! key
    { }dict var! args
    { }dict var! ctrls
  
    spec @
    foreach
        swap pop
        key @ if
            args @ key @ array_setitem args !
            "" key !
        else
            dup string? if
                key !
            else
                dup array? if
                    ctrls @ dup array_count array_setitem ctrls !
                else
                    "Bad dialog description format"
                    abort
                then
            then
        then
    repeat
    key @ if
        "Bad dialog description format: option is missing its value"
        abort
    then
    args @ ctrls @
;
  
  
: gui_generate_ctrl[ str:dlogid str:pane list:ctrlspec -- dictHandlers ]
    ctrlspec @ 0 []
    var! type

    ctrlspec @ 1 []
    var! id
  
    type @ string? not if
        "Bad control type: Expected a string"
        abort
    then
    
    id @ string? not if
        "Bad control ID: Expected a string"
        abort
    then
    
    { }list var! panes
    { }list var! names
  
    { "value" "" }dict var! args
    {            }dict var! ctrls
    {            }dict var! handlers
 
    type @ C_NOTEBOOK stringcmp not
    var! multipane
  
    ctrlspec @ array_count 2 > if
        ctrlspec @ 2 9999 [..] list_parse
        ctrls ! args !
    then
  
    ctrls @ array_count if
        id @ not if
            "Cannot embed controls in anonymous container"
            abort
        then
    then
  
    args @
    foreach
        over "|" 1 strncmp not if
            id @ not if
                "Cannot assign handlers to anonymous controls"
                abort
            then
            args @ 3 pick array_delitem args !
            swap 1 strcut swap pop
            id @ "|" strcat swap strcat
            over address? not if
                "Handlers can only take address arguments."
                abort
            then
            handlers @ swap array_setitem handlers !
        else
            pop pop
        then
    repeat
    
    multipane @ if
        ctrls @ foreach
            swap pop
            dup 0 [] "notebook_pane" stringcmp if
                "Notebooks can only contain panes."
                abort
            else
                dup 1 []
                dup string? not if
                    "Bad pane ID: Expected a string"
                    abort
                then
                panes @ dup array_count array_setitem panes !
                
                2 []
                dup string? not if
                    "Bad pane name: Expected a string"
                    abort
                then
                names @ dup array_count array_setitem names !
            then
        repeat
        panes @ args @ "panes" array_setitem args !
        names @ args @ "names" array_setitem args !
    then
 
    pane @ args @ "pane" array_setitem args !
    dlogid @ type @ id @ args @ GUI_CTRL_CREATE
  
    multipane @ if
        ctrls @ foreach
            swap pop
            var newpane dup 1 [] newpane !
            3 9999 [..] list_parse
            swap array_count if
                "Bad dialog description format: expected control array"
                abort
            then
            foreach
                swap pop
                dlogid @ newpane @ rot gui_generate_ctrl
                0 handlers @ array_setrange handlers !
            repeat
        repeat
    else
        ctrls @ foreach
            swap pop
            dlogid @ id @ rot gui_generate_ctrl
            0 handlers @ array_setrange handlers !
        repeat
    then
    handlers @
;
  
  
: gui_generate_simple[ int:dscr str:dlogtype str:title list:dlogspec --
                       dict:handlers str:dlogid ]
  
    { }dict var! handlers
 
    dlogspec @ list_parse swap
    dup var! args
    foreach
        over "|" 1 strncmp not if
            args @ 3 pick array_delitem args !
            swap 1 strcut swap pop
            over address? not if
                "Handlers can only take address artguments."
                abort
            then
            handlers @ swap array_setitem handlers !
        else
            pop pop
        then
    repeat
    
    dscr @ dlogtype @ title @ args @ GUI_DLOG_CREATE
    var dlogid dlogid !
  
    foreach
        swap pop
        dlogid @ "" rot gui_generate_ctrl
        0 handlers @ array_setrange handlers !
    repeat
  
    handlers @ dlogid @
;
  
  
: gui_generate_paned[ int:dscr str:dlogtype str:title list:dlogspec --
                      dict:handlers str:dlogid ]
    { }list var! panes
    { }list var! names
  
    dlogspec @ list_parse
    var! ctrls
    var! args
    { }dict var! handlers
  
    args @
    foreach
        over "|" 1 strncmp not if
            args @ 3 pick array_delitem args !
            swap 1 strcut swap pop
            over address? not if
                "Handlers can only take address arguments."
                abort
            then
            handlers @ swap array_setitem handlers !
        else
            pop pop
        then
    repeat
    
    ctrls @ foreach
        swap pop
        dup 0 [] "notebook_pane" stringcmp if
            "This dialog type can only directly contain panes."
            abort
        else
            dup 1 [] (pane)
            panes @ array_appenditem panes !
            swap 2 [] (name)
            names @ array_appenditem names !
        then
    repeat
  
    panes @ args @ "panes" array_setitem args !
    names @ args @ "names" array_setitem args !
  
    dscr @ dlogtype @ title @ args @ GUI_DLOG_CREATE
    var dlogid dlogid !
  
    ctrls @ foreach
        swap pop
        var newpane dup 1 [] newpane !
        3 9999 [..] list_parse
        swap array_count if
            "Bad dialog description format: expected control array"
            abort
        then
        foreach
            swap pop
            dlogid @ newpane @ rot gui_generate_ctrl
            0 handlers @ array_setrange handlers !
        repeat
    repeat
  
    handlers @ dlogid @
;
  
  
: gui_generate[ int:Dscr list:DlogSpec -- dict:Handlers str:DlogID ]
    DlogSpec @ 0 [] var! type
    DlogSpec @ 1 [] var! title
  
    Dscr @ type @ title @
    DlogSpec @ 2 9999 [..]

    type @ D_TABBED stringcmp not
    type @ D_HELPER stringcmp not or if
        gui_generate_paned
    else
        gui_generate_simple
    then
;
PUBLIC gui_generate
 
 
(--------------------------------------------------------------)
( Gui Dispatcher                                               )
(--------------------------------------------------------------)
: dispatch ( ... strValue dictDests -- ... intSuccess)
    dup rot []
    dup not if
        pop " default" []
        dup not if
            pop 0 exit
        else
            execute
        then
    else
        swap pop
        execute
    then
    1
;
  
: gui_dict_add (dict1 dict2 -- dict3)
    ( adds all items from dict2 to dict1, removing those items with false values )
    foreach
        dup not if
            pop array_delitem
        else
            rot rot array_setitem
        then
    repeat
;
  
: gui_event_process[ dict:GuiHandlers dict:OtherHandlers --
                     dict:GuiHandlers dict:Args str:Event ]
    begin
        EVENT_WAIT
        var event event !
        var args args !
        event @ "GUI." 4 strncmp not if
            event @ 4 strcut swap pop
            GuiHandlers @ swap []
            var dests dests !
            dests @ not if
                (If no callbacks for this dialog, return.)
                GuiHandlers @ OtherHandlers @ args @ event @
                break
            then
            
            var dscr     args @ "descr"     [] dscr !
            var dlogid   args @ "dlogid"    [] dlogid !
            var id       args @ "id"        [] id !
            var guievent args @ "event"     [] guievent !
            var dismiss  args @ "dismissed" [] dismiss !
 
            dscr @ dlogid @ id @ guievent @
            id @ "|" strcat guievent @ strcat dests @ dispatch
  
            not if
                pop pop pop pop
            else
                dup int? if
                    if
                        (The callback wants us to exit.)
                        GuiHandlers @ OtherHandlers @ args @ event @
                        break
                    then
                else
                    dup array? if
                        OtherHandlers @ gui_dict_add OtherHandlers !
                        GuiHandlers @ gui_dict_add GuiHandlers !
                    else
                        pop "Invalid return type from callback function." abort
                    then
                then
            then
            dismiss @ if
                (The dialog was dismissed.  Forget that dialog.)
                GuiHandlers @ dlogid @ array_delitem GuiHandlers !
            then
            GuiHandlers @ array_count not if
                (No more dialogs left.  Time to exit)
                GuiHandlers @ OtherHandlers @ args @ event @
                break
            then
        else
            args @ event @ dup OtherHandlers @ dispatch
            not if
                pop pop pop pop
            else
                dup int? if
                    if
                        (The callback wants us to exit.)
                        GuiHandlers @ OtherHandlers @ args @ event @
                        break
                    then
                else
                    dup array? if
                        OtherHandlers @ gui_dict_add OtherHandlers !
                        GuiHandlers @ gui_dict_add GuiHandlers !
                    else
                        pop "Invalid return type from callback function." abort
                    then
                then
            then
        then
    repeat
;
PUBLIC gui_event_process
 
: gui_process_single_dlog[ str:dlogid -- dict:context str:ctrlid ]
    begin
        event_wait
        "GUI." dlogid @ strcat strcmp not if
            dup "id" []
            break
        else
            pop
        then
    repeat
;
PUBLIC gui_process_single_dlog
.
c
q
@register lib-gui=lib/gui
@register #me lib-gui=tmp/prog1
@set $tmp/prog1=S
@set $tmp/prog1=H
@set $tmp/prog1=3
@propset $tmp/prog1=str:/_defs/GUI_EVENT_PROCESS:"$lib/gui" match "gui_event_process" call
@propset $tmp/prog1=str:/_defs/GUI_GENERATE:"$lib/gui" match "gui_generate" call
@propset $tmp/prog1=str:/_defs/{BUTTON:{ C_BUTTON
@propset $tmp/prog1=str:/_defs/{CHECKBOX:{ C_CHECKBOX
@propset $tmp/prog1=str:/_defs/{COMBOBOX:{ C_COMBOBOX
@propset $tmp/prog1=str:/_defs/{DATUM:{ C_DATUM
@propset $tmp/prog1=str:/_defs/{EDIT:{ C_EDIT
@propset $tmp/prog1=str:/_defs/{FRAME:{ C_FRAME
@propset $tmp/prog1=str:/_defs/{HELPER_DLOG:{ D_HELPER
@propset $tmp/prog1=str:/_defs/{HRULE:{ C_HRULE
@propset $tmp/prog1=str:/_defs/{LABEL:{ C_LABEL
@propset $tmp/prog1=str:/_defs/{LISTBOX:{ C_LISTBOX
@propset $tmp/prog1=str:/_defs/{MULTIEDIT:{ C_MULTIEDIT
@propset $tmp/prog1=str:/_defs/{NOTEBOOK:{ C_NOTEBOOK
@propset $tmp/prog1=str:/_defs/{PANE:{ "notebook_pane"
@propset $tmp/prog1=str:/_defs/{SCALE:{ C_SCALE
@propset $tmp/prog1=str:/_defs/{SIMPLE_DLOG:{ D_SIMPLE
@propset $tmp/prog1=str:/_defs/{SPINNER:{ C_SPINNER
@propset $tmp/prog1=str:/_defs/{TABBED_DLOG:{ D_TABBED
@propset $tmp/prog1=str:/_defs/{VRULE:{ C_VRULE
@propset $tmp/prog1=str:/_defs/}CTRL:}list
@propset $tmp/prog1=str:/_defs/}DLOG:}list
@propset $tmp/prog1=str:/_defs/}PANE:}list
