-module (wordcount_test).
-test (exports).
-export ([count_word_in_one_string/0]).
-export ([count_word_in_several_string/0]).

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
    E = lists: sort (dict: to_list (wordcount: lines (Lines))).
    
