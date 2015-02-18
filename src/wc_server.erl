-module (wc_server).

-export ([hard_coded_clients/0]).
-export ([count/3]).
-export ([count/4]).
-export ([quit/1]).
-export ([test/0]).
-export ([register/0]).

-define (WORDCOUNT_SERVER, wordcount_server).    
-define (WORDCOUNT_LISTENER, wordcount_listener).

test () ->
    Clients = read_file: all ("clients.txt"),
    count ("gros.txt", 1, 200, Clients).

register () ->
    true = register (?WORDCOUNT_SERVER, self ()),
    io: format ("server registered~n"),    
    ok.

hard_coded_clients () ->
    ["client@bernard-VirtualBox"].

quit (Clients) ->
    [ {?WORDCOUNT_LISTENER, Node} ! quit || Node <- Clients ].

count (FileName, From, To) ->
    count (FileName, From, To, hard_coded_clients ()).

count (FileName, From, To, Clients) ->
    Sender = {?WORDCOUNT_SERVER, node ()},
    Nodes = [ list_to_atom (S) || S <- Clients ],
    [ {?WORDCOUNT_LISTENER, Node} ! {wc, Sender, FileName, From, To} || Node <- Nodes],
    listen_for_responses (length (Clients), dict: new ()).

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


