-module (wc_server).

-export ([start/0]).
-export ([clients/0]).
-export ([count/3]).
-export ([quit/0]).

-define (WORDCOUNT_LISTENER, wordcount_listener).    

start () ->
    register (?WORDCOUNT_LISTENER, self ()),
    ok.

clients () ->
    ['client@bernard-VirtualBox'].

quit () ->
    [ {?WORDCOUNT_LISTENER, Node} ! quit || Node <- clients ()].

count (FileName, From, To) ->
    Sender = {?WORDCOUNT_LISTENER, node ()},
    [ {?WORDCOUNT_LISTENER, Node} ! {wc, Sender, FileName, From, To} || Node <- clients ()],
    listen_for_responses (length (clients ()), dict: new ()).

listen_for_responses (0, Responses) ->
    Responses;
listen_for_responses (N, Responses) ->
    io: format ("Waiting for a response~n"),    
    receive 
        {response, Dict} ->
            io: format ("Received response~n"),
            Merged = dict: merge (fun(_,V1,V2) -> V1+V2 end, Responses, Dict),
            listen_for_responses (N-1, Merged);
        Other ->
            io: format ("Unexpected response ~p~n",[Other]),
            error
    end.


