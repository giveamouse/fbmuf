@prog lib-gui
1 99999 d
1 i
(
 GUI_GENERATE [intDescr listDlogSpec -- dictHandlers strDlogId]
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
  
  
  
 GUI_EVENT_PROCESS [dictGuiHandlers dictOtherHandlers -- dictGuiHandlers' dictOtherHandlers' dictArgs strEvent]
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
        [intDescr strDlogId strCtrlId strGuiEvent -- intExit]
     If the callback returns true, then GUI_EVENT_PROCESS will return.
  
     The second dictionary passed to GUI_EVENT_PROCESS is keyed with the
     names of any other event types that MUF may support.  The values are
     the addresses of the callback functions for each event.  ie:
         {
             "timer.1"  'timer1-callback
             "user.foo" 'foo-callback
         }dict
     This is here for future expansion of the event system.
     Miscellaneous event callbacks have the signature:
        [dictArgs strEvent -- intExit]
     If the callback returns true, then GUI_EVENT_PROCESS will return.
  
     If a callback returns two dictionaries instead of an integer, then it is
     assumed to have a new GUI dialog to watch, or a new event to watch for.
     The first dictionary is for dialogs, and is in the same format as the
     dictGuiHandlers argument to GUI_EVENT_PROCESS.  The second dictionary is
     for miscellaneous events, and is in the format of the dictOtherHandlers
     argument to GUI_EVENT_PROCESS.  IF a value for one of the keys in either
     dictionary is a false value, [ie: 0, null string, etc] then that event or
     dialog is explicitly forgotten about.  You must do this when you use the
     GUI_DLOG_CLOSE primitive in a callback, to let GUI_EVENT_PROCESS know that
     it no longer needs to worry about that dialog.
     
     GUI_EVENT_PROCESS will return when all dialogs have been dismissed, or
     when one of the callbacks returns true, or when an event is received for
     a dialog that this function wasn't told about.  The values returned are:
         1. The dictionary of remaining GUI dialog callbacks.
         2. The dictionary of remaining "other" event callbacks.
         3. The dictionary of data returned by EVENT_WAIT for the event that 
             triggered the exiting.
         4. The event string returned by EVENT_WAIT.
)
  
: list_parse (list -- dictArgs listControls)
    var key "" key !
    var args { }dict args !
    var ctrls { }dict ctrls !
  
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
    args @ ctrls @
;
  
  
: gui_generate_ctrl (strDlogID strPane listControl -- dictHandlers)
    var pane swap pane !
    var dlogid swap dlogid !
    var type dup 0 [] type !
    var id   dup 1 [] id !
  
    type @ string? not if
        "Bad control type: Expected a string"
        abort
    then
    
    id @ string? not if
        "Bad control ID: Expected a string"
        abort
    then
    
    var panes { }list panes !
    var names { }list names !
  
    var args     { "value" "" }dict args !
    var ctrls    { }dict            ctrls !
    var handlers { }dict            handlers !
 
    var multipane
    type @ C_NOTEBOOK stringcmp not multipane !
  
    dup array_count 2 > if
        2 9999 [..] list_parse ctrls ! args !
    else
        pop
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
                "Handlers can only take address artguments."
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
  
  
: gui_generate_simple (intDescr strTitle listDialog -- dictHandlers strDlogID)
    var title swap title !
    var descr swap descr !
  
    descr @ title @ GUI_DLOG_SIMPLE
    var dlogid dlogid !
    var handlers { }dict handlers !
 
    list_parse swap
    var args dup args !
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
    
    args @ array_count if
        "Bad dialog description format: expected control array"
        abort
    then
  
    foreach
        swap pop
        dlogid @ "" rot gui_generate_ctrl
        0 handlers @ array_setrange handlers !
    repeat
  
    handlers @ dlogid @
;
  
  
: gui_generate_tabbed (intDescr strTitle listDialog -- dictHandlers strDlogID)
    var title swap title !
    var descr swap descr !
    var panes { }dict panes !
  
    list_parse
    var ctrls ctrls !
    var args args !
    var handlers { }dict handlers !
  
    args @
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
    
    args @ array_count if
        "Bad dialog description format: expected control array"
        abort
    then
  
    ctrls @ foreach
        swap pop
        dup 0 [] "notebook_pane" stringcmp if
            "Notebooks can only contain panes."
            abort
        else
            dup 1 [] (pane)
            swap 2 [] (name)
            panes @ rot array_setitem panes !
        then
    repeat
  
    descr @ title @ panes @ GUI_DLOG_TABBED
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
  
  
: gui_generate_helper (intDescr strTitle listDialog -- dictHandlers strDlogID)
    var title swap title !
    var descr swap descr !
    var panes { }dict panes !
  
    list_parse
    var ctrls ctrls !
    var args args !
    var handlers { }dict handlers !
  
    args @
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
  
    args @ array_count if
        "Bad dialog description format: expected control array"
        abort
    then
  
    ctrls @ foreach
        swap pop
        dup 0 [] "notebook_pane" stringcmp if
            "Notebooks can only contain panes."
            abort
        else
            dup 0 [] (pane)
            swap 1 [] (name)
            panes @ rot array_setitem panes !
        then
    repeat
  
    descr @ title @ panes @ GUI_DLOG_HELPER
    var dlogid dlogid !
  
    ctrls @ foreach
        swap pop
        var newpane dup 0 [] newpane !
        2 9999 [..] list_parse
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
  
  
: gui_generate (intDescr listDlogSpec -- dictHandlers strDlogId)
    var descr swap descr !
    var type dup 0 [] type !
    var title dup 1 [] title !
  
    type @ "simple_dlog" stringcmp not if
        descr @ title @
        rot 2 9999 [..]
        gui_generate_simple
    else
        type @ "tabbed_dlog" stringcmp not if
            descr @ title @
            rot 2 9999 [..]
            gui_generate_tabbed
        else
            type @ "helper_dlog" stringcmp not if
                descr @ title @
                rot 2 9999 [..]
                gui_generate_helper
            then
        then
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
  
: gui_event_process (dictGuiHandlers dictOtherHandlers -- dictGuiHandlers dictArgs strEvent)
    var others others !
    var guis guis !
    begin
        EVENT_WAIT
        var event event !
        var args args !
        event @ "GUI." 4 strncmp not if
            event @ 4 strcut swap pop
            guis @ swap []
            var dests dests !
            dests @ not if
                (If no callbacks for this dialog, return.)
                guis @ others @ args @ event @
                break
            then
            
            var dscr     args @ "descr"     [] dscr !
            var dlogid   args @ "dlogid"    [] dlogid !
            var id       args @ "id"        [] id !
            var guievent args @ "event"     [] guievent !
            var dismiss  args @ "dismissed" [] dismiss !
 
            dscr @ dlogid @ id @ guievent @
            id @ "|" strcat guievent @ strcat dests @ dispatch
  
            pop (if we don't have a callback for it, we ignore it.)
            dup int? if
                if
                    (The callback wants us to exit.)
                    guis @ others @ args @ event @
                    break
                then
            else
                dup array? if
                    others @ gui_dict_add others !
                    guis @ gui_dict_add guis !
                else
                    pop "Invalid return type from callback function." abort
                then
            then
            dismiss @ if
                (The dialog was dismissed.  Forget that dialog.)
                guis @ dlogid @ array_delitem guis !
            then
            guis @ array_count not if
                (No more dialogs left.  Time to exit)
                guis @ others @ args @ event @
                break
            then
        else
            args @ event @ dup others @ dispatch
            pop (if we don't have a callback for it, we ignore it.)
            dup int? if
                if
                    (The callback wants us to exit.)
                    guis @ others @ args @ event @
                    break
                then
            else
                dup array? if
                    others @ gui_dict_add others !
                    guis @ gui_dict_add guis !
                else
                    pop "Invalid return type from callback function." abort
                then
            then
        then
    repeat
;
PUBLIC gui_event_process
 
: gui_process_single_dlog (strDlogID -- dictContext strCtrlId )
    var dlogid dlogid !
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
@propset $tmp/prog1=str:/_defs/{HELPER_DLOG:{ "helper_dlog"
@propset $tmp/prog1=str:/_defs/{HRULE:{ C_HRULE
@propset $tmp/prog1=str:/_defs/{LABEL:{ C_LABEL
@propset $tmp/prog1=str:/_defs/{LISTBOX:{ C_LISTBOX
@propset $tmp/prog1=str:/_defs/{MULTIEDIT:{ C_MULTIEDIT
@propset $tmp/prog1=str:/_defs/{NOTEBOOK:{ C_NOTEBOOK
@propset $tmp/prog1=str:/_defs/{PANE:{ "notebook_pane"
@propset $tmp/prog1=str:/_defs/{SCALE:{ C_SCALE
@propset $tmp/prog1=str:/_defs/{SIMPLE_DLOG:{ "simple_dlog"
@propset $tmp/prog1=str:/_defs/{SPINNER:{ C_SPINNER
@propset $tmp/prog1=str:/_defs/{TABBED_DLOG:{ "tabbed_dlog"
@propset $tmp/prog1=str:/_defs/{VRULE:{ C_VRULE
@propset $tmp/prog1=str:/_defs/}CTRL:}list
@propset $tmp/prog1=str:/_defs/}DLOG:}list
@propset $tmp/prog1=str:/_defs/}PANE:}list
