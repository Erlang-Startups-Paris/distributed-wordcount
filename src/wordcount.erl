-module (wordcount).
-export ([lines/1]).
-export ([lines_p/1]).
-export ([count_file/1]).

lines (Lines) ->
    D = dict: new (),
    lists: foldl (fun (Line, Acc) ->
                          string (Line, Acc)
                  end, D, Lines).

lines_p (Lines) ->
    Parent = self(),
    lists: map (fun(L) ->
                        spawn (fun () ->
                                       Parent ! string (L, dict: new ())
                               end)
                end, Lines),
    collect_result (length (Lines), dict: new ()).

collect_result (0, Dict)->
    Dict;
collect_result (N, Dict) ->
    receive
        Result ->
            Merged = dict: merge (fun(_,V1,V2) -> V1+V2 end, Dict, Result),
            collect_result (N-1, Merged)
    end.

                          
string (String, Dict) ->
    Words = string: tokens (String, " ;,.:()"),
    count (Words, Dict).
    
count ([], Dict) ->
    Dict;
count ([FirstWord|Other], Dict) ->
    Updated = case dict: find (FirstWord, Dict) of
                  {ok, N} ->
                      dict: store (FirstWord, N+1, Dict);
                  error ->
                      dict: store (FirstWord, 1, Dict)
              end,
    count (Other, Updated).
            
    

count_file (Name) ->
    L = read_file (Name),
    lines_p (L).


read_file (Name) ->
    {ok, Device} = file: open (Name, read),
    for_each_line (Device, []).
 
for_each_line (Device, Accum) ->
    case io: get_line (Device, "") of
        eof  -> file:close (Device), Accum;
        Line -> for_each_line (Device, [Line|Accum])
    end.

