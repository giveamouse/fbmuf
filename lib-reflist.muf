@prog lib-reflist
1 99999 d
1 i
( DBref list manager -- REF
  A reflist is a property on an object that contains a string with
  a series of space and # delimited dbrefs in it.  ie:
    reflist:#1234 #9364 #21 #6466 #37
  A reflist only will contain one copy of any one dbref within it.
  A reflist can be no longer than 4096 characters long.  Generally,
    this means around 500+ refs.
  
  REF-add  [objref reflistname dbreftoadd -- ]
    Adds a dbref to the dbreflist.  If the given dbref is already in
    the reflist, it moves it to the end of the reflist.
  
  REF-delete  [objref reflistname dbreftokill -- ]
    Removes a dbref from the dbreflist.
  
  REF-first [objref reflistname -- firstdbref]
    Returns the first dbref in the reflist.
  
  REF-next  [objref reflistname currdbref -- nextdbref]
    Returns the next dbref in the list after the one you give it.
    Returns #-1 at the end of the list.

  REF-inlist? [objref reflistname dbreftocheck -- inlist?]
    Returns whether or not the given dbref is in the dbreflist.
  
  REF-list  [objref reflistname -- liststr]
    Returns a comma delimited string with the names of all the objects
    in the given reflist.
  
  REF-allrefs [objref reflistname -- refx...ref1 refcount]
    Returns a range on the stack containing all the refs in the list,
    with the count of them on top.

  REF-filter [address objref reflistname -- refx...ref1 refcount]
    Returns a range of dbrefs on the stack, filtered from the given reflist.
    The filtering is done by a function that you pass the address of.  The
    filter routine is [d -- i].  It takes a dbref and returns a boolean int.
    If the integer is 0, the ref is not included in the returned list.  If
    the integer is not 0, the it is in the returned list.

  REF-editlist  [players? objref reflistname -- ]  
    Enters the user into an interactive editor that lets them add and remove
    objects from the given reflist.  'players?' is an integer boolean value,
    where if it is true, the list only lets you add players to it.  Otherwise
    it lets you add regular objects to it.
)
  
$include $lib/strings
$include $lib/props
$include $lib/look
$include $lib/match
  
: REF-delete (obj reflist killref -- )
  var ref ref !
  over over array_get_reflist
  ref @ array_excludeval
  array_put_reflist
;
  
: REF-add (obj reflist addref -- )
  var ref ref !
  over over array_get_reflist
  ref @ array_excludeval
  ref @ swap array_appenditem
  array_put_reflist
;
  
: REF-first (obj reflist -- firstref)
  array_get_reflist 0 []
;
  
: REF-next (obj reflist currref -- nextref)
  rot rot array_get_reflist
  dup rot array_findval
  0 [] array_next
  not if pop #-1 then
;

: REF-inlist? (objref reflistname dbreftocheck -- inlist?)
  rot rot array_get_reflist
  swap array_findval array_count
;
  
: REF-array (d s -- a)
  array_get_reflist
;

: REF-allrefs (d s -- dx...d1 i)
  array_get_reflist
  array_vals
;

: REF-list  (objref reflistname -- liststr)
  REF-allrefs .short-list
;

: REF-filter (a d s -- dx...d1 i)
  array_get_reflist
  0 array_make swap
  foreach
    swap pop
    dup 4 pick execute if
      array_appenditem
    else pop
    then
  repeat
  swap pop array_vals
;


: REF-editlist-help
  if
    "To add a player, enter their name.  To remove a player, enter their name"
    "with a ! in front of it.  ie: '!guest'.  To display the list, enter '*'"
    "on a line by itself.  To clear the list, enter '#clear'.  To finish"
    "editing and exit, enter '.' on a line by itself.  Enter '#help' to see"
    "these instructions again."
    strcat strcat strcat strcat .tell
  else
    "To add an object, enter its name or dbref.  To remove an object, enter"
    "its name or dbref with a ! in front of it.  ie: '!button'.  To display"
    "the list, enter '*' on a line by itself.  To clear the list, enter"
    "'#clear'.  To finish editing and exit, enter '.' on a line by itself."
    "Enter '#help' to see these instructions again."
    strcat strcat strcat strcat .tell
  then
;

: REF-editlist  (players? objref reflistname -- )
  3 pick REF-editlist-help
  "The object list currently contains:" .tell
  over over REF-list .tell
  begin
    read
    dup "." strcmp not if
      pop pop pop
      "Done." .tell break
    then
    dup "#list" stringcmp not
    over "*" strcmp not or if
      pop "The object list currently contains:" .tell
      over over REF-list .tell continue
    then
    dup "#clear" stringcmp not if
      pop over over remove_prop
      "Object list cleared." .tell continue
    then
    dup "#help" stringcmp not if
      pop 3 pick REF-editlist-help
      continue
    then
    dup "!" 1 strncmp not if
      1 strcut swap pop 1
    else 0
    then
    swap 5 pick if .noisy_pmatch else .noisy_match then
    dup ok? not if pop pop continue then
    4 pick 4 pick rot 4 rotate if
      3 pick 3 pick 3 pick REF-inlist? if
        REF-delete "Removed." .tell
      else
        pop pop pop
        "Not in object list." .tell
      then
    else
      REF-add "Added." .tell
    then
  repeat
;


PUBLIC REF-add
PUBLIC REF-delete
PUBLIC REF-first
PUBLIC REF-next
PUBLIC REF-list
PUBLIC REF-inlist?
PUBLIC REF-array
PUBLIC REF-allrefs
PUBLIC REF-filter (address objref reflistname -- refx...ref1 refcount)
PUBLIC REF-editlist  (players? objref reflistname -- )
.
c
q
@register lib-reflist=lib/reflist
@register #me lib-reflist=tmp/prog1
@set $tmp/prog1=L
@set $tmp/prog1=H
@set $tmp/prog1=S
@set $tmp/prog1=B
@set $tmp/prog1=2
@set $tmp/prog1=/_/de:A scroll containing a spell called lib-reflist
@set $tmp/prog1=/_defs/REF-add:"$lib/reflist" match "REF-add" call
@set $tmp/prog1=/_defs/REF-delete:"$lib/reflist" match "REF-delete" call
@set $tmp/prog1=/_defs/REF-first:"$lib/reflist" match "REF-first" call
@set $tmp/prog1=/_defs/REF-next:"$lib/reflist" match "REF-next" call
@set $tmp/prog1=/_defs/REF-inlist?:"$lib/reflist" match "REF-inlist?" call
@set $tmp/prog1=/_defs/REF-list:"$lib/reflist" match "REF-list" call
@set $tmp/prog1=/_defs/REF-allrefs:"$lib/reflist" match "REF-allrefs" call
@set $tmp/prog1=/_defs/REF-array:"$lib/reflist" match "REF-array" call
@set $tmp/prog1=/_defs/REF-filter:"$lib/reflist" match "REF-filter" call
@set $tmp/prog1=/_defs/REF-editlist:"$lib/reflist" match "REF-editlist" call
@set $tmp/prog1=/_docs:@list $lib/reflist=1-46
