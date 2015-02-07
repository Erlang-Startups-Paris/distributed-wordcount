-module (fact).

-export ([f1/1]).
-export ([f2/1]).
-export ([fp/2]).


f1 (1) -> 1; 
f1 (N) ->
    N * f1 (N-1).

f2 (N) ->
    Mid = N div 2,
    f (1, Mid) *  f(Mid+1, N).

fp (N, NbProcess) ->
    RangeSize = N div NbProcess,
    Parent = self (),
    lists: map (fun(P) ->                        
                        From = (RangeSize * P) +1,
                        To =   RangeSize * (P+1),
                        parallelize (Parent, From, To)
                end, lists: seq (0, NbProcess-2)),

    parallelize (Parent, (RangeSize * (NbProcess-1)) + 1 , N),

    wait_for_results (NbProcess).

parallelize (Parent, From, To) ->
    spawn (fun () -> fp2 (Parent, From, To) end).

fp2 (Parent, N1, N2) ->
    Parent ! f (N1, N2).


wait_for_results (0) ->
    1;
wait_for_results (N) ->
    receive
        Result ->
            Result * wait_for_results (N-1)
    end.
    
f (N1, N1) -> N1;
f (N1, N2) ->
    N2 * f (N1, N2-1).
    
