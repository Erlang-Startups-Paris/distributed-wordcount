-module (wordcount).
-export ([lines/1]).
-export ([lines_p/1]).
-export ([count_file/3]).
-export ([split_list/2]).

lines (Lines) ->
    D = dict: new (),
    lists: foldl (fun (Line, Acc) ->
                          string (Line, Acc)
                  end, D, Lines).

lines_p (Lines) ->
    lines_p (Lines, 32).

lines_p (Lines, NbProcess) ->
    Parent = self(),
    Splitted = split_list (Lines, NbProcess),
    lists: map (fun(BucketOfLines) ->
                        spawn (fun () ->
                                       Parent ! lines (BucketOfLines)
                               end)
                end, Splitted),
    collect_result (length (Splitted), dict: new ()).

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
            

%%

count_file (Name, From, To) ->
    io: format ("Reading file ~p from ~p to ~p~n", [Name, From, To]),
    L = read_file: from_to (Name, From, To),
    io: format ("Finished.~n"),
    io: format ("Counting...~n"),
    lines_p (L).

%%

split_list (List, N) ->
    BucketSize = max (floor (length (List) / N), 1),
    buckets (List, N-1, BucketSize, []).

buckets ([], _, _, Acc) ->
    Acc;
buckets (List, 0, _, Acc) ->
    [List|Acc];
buckets (List, N, BucketSize, Acc) ->
    {Bucket, Remaining} = lists: split (BucketSize, List),
    buckets (Remaining, N-1, BucketSize, [Bucket|Acc]).


floor(X) ->
    T = erlang: trunc(X),
    case (X - T) of
        Neg when Neg < 0 -> T - 1;
        Pos when Pos > 0 -> T;
        _ -> T
    end.

