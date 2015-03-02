-module (chunk).
-export ([portion/3]).
-export ([list/2]).


%%
%% @doc ???
%%
portion (FirstLine, LastLine, _) when LastLine < FirstLine ->
    {0, []};
portion (FirstLine, LastLine, Clients) ->
    NbLines = LastLine - FirstLine + 1,
    Nb_clients = length(Clients),
    if NbLines =< Nb_clients ->
	    {Active_clients, _} = lists:split(NbLines, Clients),
	    {1, Active_clients};
       true ->
	    {(LastLine - FirstLine + 1) div length(Clients), Clients} 
    end.

%%
%% @doc Split a list in several part of about the same size
%%
list (List, N) ->
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
