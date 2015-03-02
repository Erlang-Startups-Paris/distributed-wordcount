-module (wordcount).
-export ([lines/1]).
-export ([lines_p/1]).

%% simple algo

lines (Lines) ->
    D = dict: new (),
    lists: foldl (fun (Line, Acc) ->
                          string (Line, Acc)
                  end, D, Lines).

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
            

%% parallel version

lines_p (Lines) ->
    lines_p (Lines, 32).

lines_p (Lines, NbProcess) ->
    Parent = self(),
    Splitted = t (split_list, fun() -> chunk: list (Lines, NbProcess) end),
    lists: map (fun(BucketOfLines) ->
                        spawn (fun () ->
                                       Result = t (count_lines, fun () -> lines (BucketOfLines) end),
                                       Parent ! Result
                               end)
                end, Splitted),
    collect_result (length (Splitted), dict: new ()).

collect_result (0, Dict)->
    Dict;
collect_result (N, Dict) ->
    receive
        Result ->
            Merged = t (collect_result, fun () -> dict: merge (fun(_,V1,V2) -> V1+V2 end, Dict, Result) end),
            collect_result (N-1, Merged)
    end.

                          
%% log time measures

t (Id, Fun) ->
    Self = self (),
    io: format ("~p: start ~p~n", [Self, Id]),
    Result = log_server: time (Id, Fun),
    io: format ("~p: finished ~p~n", [Self, Id]),
    Result.

