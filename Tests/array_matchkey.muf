: test[ str:arg -- ]
    {
        "foo" "This is a"
        "pi" 3.14159
        3 "test for"
        "eight" 8
        "nIne" "with a lock of"
        "lock" "#1&!#1" parselock
    }dict
    "*i*"
    array_matchkey
    dup array_count 3 = not if
        "ARRAY_MATCHKEY: Wrong number of entries in result" abort
    then
    dup "pi" [] 3.14159 = not if
        "ARRAY_MATCHKEY: String entry pi not found" abort
    then
    dup "eight" [] 8 = not if
        "ARRAY_MATCHKEY: String entry eight not found" abort
    then
    dup "nIne" [] "with a lock of" strcmp if
        "ARRAY_MATCHKEY: String entry nIne not found" abort
    then
    pop
    { }dict "" array_matchkey
    array_count if
        "ARRAY_MATCHKEY: Wrong number of entries in null list result." abort    
    then
    "Succeeded: ARRAY_MATCHKEY" .tell
;





