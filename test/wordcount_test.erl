-module (wordcount_test).
-test (exports).
-export ([count_word_in_one_string/0]).
-export ([count_word_in_several_string/0]).
-export ([split_list/0]).

count_word_in_one_string() ->
    Line = "hello world hello",
    E = [{"hello", 2},
         {"world", 1}],
    E = dict: to_list (wordcount: lines ([Line])).

count_word_in_several_string () ->
    Lines = ["hello world hello",
             "hello world goodbye"],
    E = [{"goodbye", 1},
         {"hello", 3},
         {"world", 2}],
    E = lists: sort (dict: to_list (wordcount: lines_p (Lines))).

split_list () ->    
    [[c,d],[a,b]] = wordcount: split_list ([a,b,c,d], 2),
    [[c,d,e],[a,b]] = wordcount: split_list ([a,b,c,d,e], 2),

    ok.
