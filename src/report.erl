-module (report).
-export ([print/1]).
-export ([reset/0]).
-export ([print_timing/1]).

print_timing (Results) ->
    io: format ("Node                       Reading File  Counting words~n"),
    io: format ("-------------------------------------------------------~n"),
    [ print_row (R) || R <- Results ].

print_row ([Node|Times]) ->
    Row = [Node | micro_to_sec (Times)],
    io: format ("~p                         ~p ~p~n", Row).                  

micro_to_sec (List) ->
    [ X/1000000 || X <- List].

reset () ->
    Data = etcol: t ([{[{text_attr, reset},
                        {fg_color, default_fg},
                        {bg_color, default_bg}], ""}]),
    io: format ("~ts",[Data]).
    
print (S) ->    
    Data = etcol: t ([{[{fg_color, red}], S}]),    
    io: format ("~ts",[Data]).
