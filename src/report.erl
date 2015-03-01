-module (report).
-export ([print/1]).
-export ([print_info/1]).
-export ([reset/0]).
-export ([print_timing_nodes/1]).


banner () ->
    io: format ("~n"),
    yellow (),
    io: format ("Results"),    
    reset (),
    io: format ("~n").
    
print_info(List) ->
    banner (),
    print_info_list (List).

print_info_list ([]) ->
    ok;
print_info_list ([{Title, Details}|Tail]) ->
    io: format ("~30s ~p~n",[Title,Details]),
    print_info_list(Tail).    


print_timing_nodes (Nodes) ->
    [ print_node (N) || N <- Nodes ].

print_node ({Node, Times}) ->
    bold(),
    io: format ("~nNode ~p~n", [Node]),
    reset (),
    underscore (),
    io: format ("~15s ~10s~n", ["Description", "Secs"]),
    reset (),

    Keys = proplists: get_keys (Times),
    [print_timing_key (K, Times) || K <- Keys].

print_timing_key (Key, Times) ->
    NanoSecs  = lists: sum (proplists: get_all_values (Key, Times)),
    Secs = NanoSecs / 1000000,
    io: format ("~15w ~10.6f~n", [Key, Secs]).



reset () ->
    print ([{text_attr, reset},
            {fg_color, default_fg},
            {bg_color, default_bg}]).

underscore () ->
    print ([{text_attr, underscore}]).

bold () ->
    print ([{text_attr, bright}]).


yellow () ->
    print ([{text_attr, reset},
            {fg_color, black},
            {bg_color, yellow}]).
    

print (ColorCode) ->    
    Data = etcol: t ([{ColorCode, ""}]),    
    io: format ("~ts",[Data]).
    
