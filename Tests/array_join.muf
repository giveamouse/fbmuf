: test[ str:arg -- ]
    {
        "This is a"
        3.14159
        "test for"
        8
        "with a lock of"
        "#1&!#1" parselock
    }list " " array_join
    "This is a 3.14159 test for 8 with a lock of One(#1P*)&!One(#1P*)"
    smatch if
        "Succeeded: ARRAY_JOIN" .tell
    else
        "ARRAY_JOIN: Unexpected result." abort
    then
;


