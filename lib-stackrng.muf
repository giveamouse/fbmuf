@prog lib-stackrng
1 99999 d
1 i
( ***** Stack based range handling object -- SRNG ****                 
         offset is how many stack items are between range and parms    
         pos is the position within the range you wish to deal with.   
         num is the number of range items to deal with.                
  
  A 'range' is defines as a set of related items on the stack with an
  integer 'count' of them on the top.  ie:  "bat" "cat" "dog" 3
  
   sr-extractrng[     {rng} ... offset num pos -- {rng'} ... {subrng} ]
     pulls a subrange out of a range buried in the stack, removing them.
  
   sr-copyrng   [     {rng} ... offset num pos -- {rng} ... {subrng}  ]
     copies a subrange out of a range buried in the stack.
  
   sr-deleterng [     {rng} ... offset num pos -- {rng'}              ]
     deletes a subrange from a range buried on the stack.
  
   sr-insertrng [ {rng1} ... {rng2} offset pos -- {rng}               ]
     inserts a subrange into the middle of a buried range on the stack.
  
   sr-filterrng [               {rng} funcaddr -- {rng'} {filtrdrng}  ]
     Takes the given range and tests each item with the given filter
     function address.  The function takes a single data value and
     returns an integer.  If the integer is non-zero, it pulls that
     data item out of the range and puts it into the filtered range.
     The data items can be of any type.
  
   sr-catrng    [                {rng1} {rng2} -- {rng}               ]
     concatenates two ranges into one range.
  
   sr-poprng    [                        {rng} --                     ]
     removes a range from the stack.  Also defined as 'popn'.
  
   sr-swaprng   [                {rng1} {rng2} -- {rng2} {rng1}       ]
     takes two ranges on the stack and swaps them.
  
)
  
: catranges ( {rng1} {rng2} -- {rng} )
    dup 2 + rotate +
;
  
  
: popoffn ({rng} -- )
	popn
;
  
  
: copyrange ( {rng} ... offset num pos -- {rng} ... {subrng} )
	var pos 1 - pos !
	var num num !
    array_make var stuff stuff !
	array_make var range range !
	var subrng

	num @ 0 <= if
        { }list subrng !
	else
		range @ pos @ dup num @ + 1 -
        array_getrange subrng !
    then
    range @ array_vals
    stuff @ array_vals pop
    subrng @ array_vals
;
  
  
: extractrange ( {rng} ... offset num pos -- {rng'} ... {subrng} )
	var pos 1 - pos !
	var num num !
    array_make var stuff stuff !
	array_make var range range !
	var subrng

	num @ 0 <= if
        { }list subrng !
	else
		range @ pos @ dup num @ + 1 -
        array_getrange subrng !
        range @ pos @ dup num @ + 1 -
        array_delrange range !
    then
    range @ array_vals
    stuff @ array_vals pop
    subrng @ array_vals
;
  
  
: swapranges ( {rng1} {rng2} -- {rng2} {rng1} )
	array_make var tmp tmp !
	array_make var tmp2 tmp2 !
	tmp @ array_vals
	tmp2 @ array_vals
;
  
: deleterange  ( {rng} ... offset num pos -- {rng'} )
    extractrange popn
;
  
: insertrange  ( {rng1} ... {rng2} offset pos-- {rng} ... )
	var pos 1 - pos !
    var offset offset !
    array_make var newrng newrng !
    offset @ array_make var stuff stuff !
	array_make

    pos @ newrng @ array_insertrange
    array_vals
    stuff @ array_vals pop
;
  
  
: filterrange ( {rng} funcaddr -- {rng'} {filtrdrng} )
   var cb cb !
   var outrng { }list outrng !
   array_make var range range !
   range @ foreach
      dup cb @ execute if
         outrng @ dup array_count array_setitem outrng !
         range @ swap array_delitem range !
      else
         pop
      then
   repeat
   range @ array_vals
   outrng @ array_vals
;
  
  
public catranges
public popoffn
public extractrange
public swapranges
public copyrange
public deleterange
public insertrange
public filterrange
.
c
q
@register lib-stackrng=lib/stackrng
@register #me lib-stackrng=tmp/prog1
@set $tmp/prog1=L
@set $tmp/prog1=V
@set $tmp/prog1=/_defs/popn:"$lib/stackrng" match "popoffn" call
@set $tmp/prog1=/_defs/sr-catrng:"$lib/stackrng" match "catranges" call
@set $tmp/prog1=/_defs/sr-copyrng:"$lib/stackrng" match "copyrange" call
@set $tmp/prog1=/_defs/sr-deleterng:"$lib/stackrng" match "deleterange" call
@set $tmp/prog1=/_defs/sr-extractrng:"$lib/stackrng" match "extractrange" call
@set $tmp/prog1=/_defs/sr-filterrng:"$lib/stackrng" match "filterrange" call
@set $tmp/prog1=/_defs/sr-insertrng:"$lib/stackrng" match "insertrange" call
@set $tmp/prog1=/_defs/sr-poprng:"$lib/stackrng" match "popoffn" call
@set $tmp/prog1=/_defs/sr-swaprng:"$lib/stackrng" match "swapranges" call
