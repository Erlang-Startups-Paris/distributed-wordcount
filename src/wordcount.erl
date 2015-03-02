-module (wordcount).
-export ([lines/1]).
-export ([lines_p/1]).
-export ([count_file/3]).
-export ([split_list/2]).

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
    Splitted = t (split_list, fun() -> split_list (Lines, NbProcess) end),
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

                          

%% helper to split lines over several processes

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


%% read lines from a text file

count_file (Name, From, To) ->
    L = t (read_file, fun ()-> read_file: from_to (Name, From, To) end),
    Dict = t (counting_all, fun ()-> lines_p (L) end),
    Dict.


%% log time measures

t (Id, Fun) ->
    Self = self (),
    io: format ("~p: start ~p~n", [Self, Id]),
    Result = log_server: time (Id, Fun),
    io: format ("~p: finished ~p~n", [Self, Id]),
    Result.

