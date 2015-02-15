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
            

%%

count_file (Name, From, To) ->
    L = read_file (Name, From, To),
    lines_p (L).


read_file (Name, From, To) ->
    {ok, Device} = file: open (Name, read),
    skip_first_lines  (Device, From-1),
    for_each_line (Device, From, To, []).

skip_first_lines (_, 0) -> 
    ok;
skip_first_lines (Device, N) ->
    io: get_line (Device, ""),
    skip_first_lines (Device, N-1).

for_each_line (Device, From, To, Accum) when From > To->
    close (Device, Accum);
for_each_line (Device, From, To, Accum) ->
    case io: get_line (Device, "") of
        eof  -> close (Device, Accum);
        Line -> for_each_line (Device, From+1, To, [Line|Accum])
    end.

close (Device, Accum) ->
    file: close (Device), Accum.



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

