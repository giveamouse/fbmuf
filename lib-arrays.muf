@program lib-arrays
1 9999 d
1 i
(*
  Lib-Arrays v1.1
  Author: Chris Brine [Moose/Van]
   Email: ashitaka@home.com
    Date: August 15th, 2000

  Modified by Revar to take advantage of newer MUF primitives, etc.
 
  Note: These were only made for string-list one-dimensional arrays,
        and not dictionaries or any other kind.
  Note: Ansi codes are accepted in these functions.
  
  Lib-Arrays demands either ProtoMUCK v1.00+ or FuzzballMUCK v6.00b2+
  PS: Arrays were originaly constructed in FuzzballMUCK but brought
      over to ProtoMUCK during our update of the FB part of the code.
 
  Functions:
    ArrCommas [ a -- s ]
     - Takes an array of strings and returns a string with them seperated by commas.
    ArrLeft [ a @1 @2 icol schar -- a ]
     - Aligns all text in the given range to the left in the number of
        columns and with the given char.
    ArrRight [ a @1 @2 icol schar -- a ]
     - Same as ArrLeft, but it is aligned to the right instead.
    ArrCenter [ a @1 @2 icol schar -- a ]
     - Same as ArrLeft, but it is aligned to the center instead.
    ArrIndent [ a @1 @2 icol schar -- a ]
     - Indents the text in the given range by the number of columns
       given.
    ArrFormat [ a @1 @2 icol -- a ]
     - Formats the given range in the array to a specific number of columns; however, it will only
       seperate the line at the last space before icol... that way it doesn't cut it off in the
       middle of any word.
    ArrJoinRng [ a @1 @2 schar -- a ]
     - Joins a range of text.  schar is the seperating char.
    ArrList [ d a @1 @2 iBolLineNum -- ]
     - List the contents of the range in the array; if iBolLineNum is not equal to 0 then
       it will display the line numbers as well. 'd' is the object that the list is displayed to.
    ArrSearch [ @ a ? -- i ]
     - Searches through the array for any item containing '?' starting at the given index
    ArrCopy [ a @1 @2 @3 -- a ]
     - Copies the given range to the position of @3.
    ArrMove [ a @1 @2 @3 -- a ]
     - Moves the given range to the position of @3
    ArrPlaceItem [ @ a ? -- a ]
     - Place an item at the exact position, moving the old one that was there down
       [Ie. An object switcheroo after array_insertitem]
    ArrShuffle [ a -- a ]
     - Randomize the array.
    ArrReplace [ a @1 @2 s1 s2 -- a ]
     - Replace any 's1' text with 's2' in the given range for the array.
    ArrSort [ a i -- a ]
     - Sorts the array in order.  i = 1 for forward, i = 0 for reverse
    ArrMPIparse [ d a @1 @2 s i -- a ]
     - Parse the given lines in an array and returns the parsed lines.
      d = Object to apply permission checking to [or use for parseprop under FuzzballMUCKs since they do not have PARSEMPI]
      a = The starting array
     @1 = The first index marker to parse
     @2 = The last index marker to parse
      s = String containing the &how variable's contents
      i = Integer used for {delay} on whether it is shown to the player or room.
    ArrKey? [ a @ -- i ]
     - Checks to see if '@' is an index marker in the given array/dictionary.
*)
 
: ArrCommas ( a -- s )
    dup array_count 2 > if
        array_reverse dup 0 []
        swap 0 array_delitem array_reverse
        ", " array_join
        ", and " strcat
        swap strcat
    else
        ", and " array_join
    then
;
 
: ArrLeft[ arr:oldarr idx:startpos idx:endpos int:col str:char -- arr:newarr ]
    0 array_make var! newarray
    oldarr @
    FOREACH
        swap dup startpos @ >= swap endpos @ <= and if
            begin
                dup ansi_strlen col @ < while
                char @ strcat
            repeat
        then
        newarray @ array_appenditem newarray !
    REPEAT
    newarray @
;
 
: ArrRight[ arr:oldarr idx:startpos idx:endpos int:col str:char -- arr:newarr ]
   0 array_make var! newarray
   oldarr @
   FOREACH
      swap dup startpos @ >= swap endpos @ <= and if
         begin
            dup ansi_strlen col @ < while
            char @ swap strcat
         repeat
      then
      newarray @ array_appenditem newarray !
   REPEAT
   newarray @
;
 
: ArrCenter[ arr:oldarr idx:startpos idx:endpos int:col str:char -- arr:newarr ]
   0            var! idx
   0 array_make var! newarray
   oldarr @
   FOREACH
      swap dup startpos @ >= swap endpos @ <= and if
         begin
            dup ansi_strlen col @ < while
            idx @ if
               char @ swap strcat 0 idx !
            else
               char @ strcat 1 idx !
            then
         repeat
      then
      newarray @ array_appenditem newarray !
   REPEAT
   newarray @
;
 
: ArrIndent[ arr:oldarr idx:startpos idx:endpos int:col str:char -- arr:newarr ]
   0 array_make var! newarray
   oldarr @
   FOREACH
      swap dup startpos @ >= swap endpos @ <= and if
         1 col @ 1 FOR
            pop char @ swap strcat
         REPEAT
      then
      newarray @ array_appenditem newarray !
   REPEAT
   newarray @
;
 
: ArrFormat[ arr:oldarr idx:startpos idx:endpos int:col -- arr:newarr ]
   0 array_make var! newarray
   oldarr @
   FOREACH
      swap dup startpos @ >= swap endpos @ <= and if
         begin
            dup ansi_strlen col @ > while
            col @ ansi_strcut swap " " rsplit rot strcat swap
            newarray @ array_appenditem newarray !
         repeat
      then
      newarray @ array_appenditem newarray !
   REPEAT
   newarray @
;
 
: ArrJoinRng[ arr:oldarr idx:startpos idx:endpos str:char -- arr:newarr ]
    oldarr @ array_count var! insize
    var newarr

    oldarr @ -1 startpos @ -- array_getrange newarr !

    oldarr @ startpos @ endpos @ array_getrange
    char @ array_join newarr @ array_appenditem newarr !

    oldarr @ endpos @ ++ insize @ array_getrange
    newarr @ dup array_count swap array_setrange
;
 
: ArrList ( d a @1 @2 iBolLineNum -- )
   var dbobj var bolnum bolnum ! 4 rotate dbobj !
   over -1 = if pop pop 0 over array_count 1 - then
   3 pick array_count 1 < if pop pop pop exit then
   dup 0 < if pop 0 then
   over 0 < if swap pop 0 swap then
   3 pick array_count 1 - over over > if swap pop dup then
   3 pick over > if rot pop -3 rotate else pop then
   over over > if pop dup then
   array_getrange
   FOREACH
      bolnum @ if
         swap 1 + intostr "\[[1;37m" swap strcat "\[[0m: " strcat
         1 array_make 0 0 5 " " ArrRight array_vals pop
      else
         swap pop ""
      then
      swap strcat
      dbobj @ swap notify
   REPEAT
;
 
: ArrSearch[ idx:start arr:arr any:searchfor -- int:foundat ]
    array_findval
    foreach
        dup start @ >= if
            swap pop exit
        then
        pop pop
    repeat
    -1
;

 
: ArrCopy ( a @1 @2 @3 -- a )
   var! arrpos
   3 pick rot rot array_getrange arrpos @ swap array_insertrange
;
 
: ArrMove ( a @1 @2 @3 -- a )
   var! arrpos
   3 pick 3 pick 3 pick array_getrange -4 rotate array_delrange
   dup array_count arrpos @ < if dup array_count else arrpos @ then rot array_insertrange
;
 
: ArrPlaceItem ( @ a ? -- a )
   3 pick rot swap array_insertitem
   over over swap array_getitem
   3 pick 3 rotate swap array_delitem
   rot array_insertitem
;
 
: ArrShuffle ( a -- a )
   var newarray 0 array_make newarray !
   dup array_count not if exit then
   1 over array_count 1 FOR
      pop
      dup array_count random swap % over over array_getitem rot rot array_delitem swap newarray @ array_appenditem newarray !
   REPEAT
   pop newarray @
;
 
: ArrReplace ( a @1 @2 s1 s2 -- a )
   var oldtext oldtext ! var newtext newtext !
   var endpos endpos ! var firstpos firstpos !
   var newarray 0 array_make newarray !
   FOREACH
      swap dup firstpos @ >= swap endpos @ <= and if
         newtext @ oldtext @ subst
      then
      newarray @ array_appenditem newarray !
   REPEAT
   newarray @
;
 
: ArrMPIparse ( d a @1 @2 s i -- a )
   var imesg imesg ! var stype stype !
   var endpos endpos ! var firstpos firstpos !
   var dbobj swap dbobj !
   var newarray 0 array_make newarray !
   FOREACH
      swap dup firstpos @ >= swap endpos @ <= and if
$ifdef __proto
         dbobj @ swap stype @ imesg @ parsempi
$else
         "@/mpi/" systime intostr strcat dup rot
         dbobj @ rot rot setprop
         dbobj @ over stype @ imesg @ parseprop
         dbobj @ swap remove_prop
$endif
         newarray @ array_appenditem newarray !
      swap
         pop
      then
   REPEAT
   newarray @
;
 
: ArrKey? ( a @ -- i )
   over dictionary? if
      swap array_keys array_make swap dup int? not
      over string? not and if pop pop 0 exit then
      array_findval array_count 0 >
   else
      dup int? not if pop pop 0 exit then
      swap array_count over swap < swap 0 >= and
   then
;
 

(dir = 1 for forward, dir = 0 for reverse)
: ArrSort[ arr:oldarr int:dir -- arr:newarr ]
    (FIXME: allow for lexical-numerical sorting)
    if SORTTYPE_CASE_ASCEND else SORTTYPE_CASE_DESCEND then
    array_sort
;

public ArrCommas ( a -- s )
public ArrLeft ( a @1 @2 icol schar -- a )
public ArrRight ( a @1 @2 icol schar -- a )
public ArrCenter ( a @1 @2 icol schar -- a )
public ArrIndent ( a @1 @2 icol schar -- a )
public ArrFormat ( a @1 @2 icol -- a )
public ArrJoinRng ( a @1 @2 schar -- a )
public ArrList ( d a @1 @2 iBolLineNum -- )
public ArrSearch ( @ a ? -- i )
public ArrCopy ( a @1 @2 @3 -- a )
public ArrMove ( a @1 @2 @3 -- a )
public ArrPlaceItem ( @ a ? -- a )
public ArrShuffle ( a -- a )
public ArrReplace ( a @1 @2 s1 s2 -- a )
public ArrSort ( a i -- a )
public ArrMPIparse ( d a @1 @2 s i -- a )
public ArrKey? ( a @ -- i )
.
c
q
@register lib-arrays=lib/arrays
@set $lib/arrays=_lib-version:1.1
@set $lib/arrays=l
@set $lib/arrays=m3
@set $lib/arrays=v
@set $lib/arrays=_Defs/ArrCommas:"$lib/arrays" match "ArrCommas" call
@set $lib/arrays=_Defs/ArrLeft:"$lib/arrays" match "ArrLeft" call
@set $lib/arrays=_Defs/ArrRight:"$lib/arrays" match "ArrRight" call
@set $lib/arrays=_Defs/ArrCenter:"$lib/arrays" match "ArrCenter" call
@set $lib/arrays=_Defs/ArrIndent:"$lib/arrays" match "ArrIndent" call
@set $lib/arrays=_Defs/ArrFormat:"$lib/arrays" match "ArrFormat" call
@set $lib/arrays=_Defs/ArrJoinRng:"$lib/arrays" match "ArrJoinRng" call
@set $lib/arrays=_Defs/ArrList:"$lib/arrays" match "ArrList" call
@set $lib/arrays=_Defs/ArrSearch:"$lib/arrays" match "ArrSearch" call
@set $lib/arrays=_Defs/ArrCopy:"$lib/arrays" match "ArrCopy" call
@set $lib/arrays=_Defs/ArrMove:"$lib/arrays" match "ArrMove" call
@set $lib/arrays=_Defs/ArrPlaceItem:"$lib/arrays" match "ArrPlaceItem" call
@set $lib/arrays=_Defs/ArrShuffle:"$lib/arrays" match "ArrShuffle" call
@set $lib/arrays=_Defs/ArrReplace:"$lib/arrays" match "ArrReplace" call
@set $lib/arrays=_Defs/ArrSort:"$lib/arrays" match "ArrSort" call
@set $lib/arrays=_Defs/ArrMPIparse:"$lib/arrays" match "ArrMPIparse" call
@set $lib/arrays=_Defs/ArrKey?:"$lib/arrays" match "ArrKey?" call
@set $lib/arrays=_Defs/Array_Commas:"$lib/arrays" match "ArrCommas" call
@set $lib/arrays=_Defs/Array_Left:"$lib/arrays" match "ArrLeft" call
@set $lib/arrays=_Defs/Array_Right:"$lib/arrays" match "ArrRight" call
@set $lib/arrays=_Defs/Array_Center:"$lib/arrays" match "ArrCenter" call
@set $lib/arrays=_Defs/Array_Indent:"$lib/arrays" match "ArrIndent" call
@set $lib/arrays=_Defs/Array_Format:"$lib/arrays" match "ArrFormat" call
@set $lib/arrays=_Defs/Array_JoinRng:"$lib/arrays" match "ArrJoinRng" call
@set $lib/arrays=_Defs/Array_List:"$lib/arrays" match "ArrList" call
@set $lib/arrays=_Defs/Array_Search:"$lib/arrays" match "ArrSearch" call
@set $lib/arrays=_Defs/Array_Copy:"$lib/arrays" match "ArrCopy" call
@set $lib/arrays=_Defs/Array_Move:"$lib/arrays" match "ArrMove" call
@set $lib/arrays=_Defs/Array_PlaceItem:"$lib/arrays" match "ArrPlaceItem" call
@set $lib/arrays=_Defs/Array_Shuffle:"$lib/arrays" match "ArrShuffle" call
@set $lib/arrays=_Defs/Array_Replace:"$lib/arrays" match "ArrReplace" call
@set $lib/arrays=_Defs/Array_Sort:"$lib/arrays" match "ArrSort" call
@set $lib/arrays=_Defs/Array_MPIparse:"$lib/arrays" match "ArrMPIparse" call
