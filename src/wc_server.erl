-module (wc_server).

-include_lib("eunit/include/eunit.hrl").

-export ([count/0]).
-export ([count/1]).
-export ([count/2]).
-export ([count/3]).
-export ([count/4]).
-export ([quit/1]).
-export ([register/0]).

-define (WORDCOUNT_SERVER, wordcount_server).    
-define (WORDCOUNT_LISTENER, wordcount_listener).

%% To start Server and launch computations :
%% ./start_server.sh 
%% wc_server:register(), wc_server:count(10).

register () ->
    true = register (?WORDCOUNT_SERVER, self ()),
    io: format ("Server registered~n"),    
    ok.

quit (Clients) ->
    [ {?WORDCOUNT_LISTENER, Node} ! quit || Node <- Clients ].

count () ->
    count (3).

count (Number_lines) ->
    count (1, Number_lines).

count (FirstLine, LastLine) ->
    count ("gros.txt", FirstLine, LastLine).

count (FileName, FirstLine, LastLine) ->
    Clients = read_file: all ("clients.txt"),
    count (FileName, FirstLine, LastLine, Clients).

count (FileName, FirstLine, LastLine, Clients) ->
    Ranges = chunk: ranges (FirstLine, LastLine, length (Clients)),
    L = lists: zip (Ranges, Clients),
    [ request_client (FileName,First,Last,Client) || {{First,Last},Client} <- L],
    {_Result, Timing} = listen_for_responses (length (Clients), {dict: new (), []}),
    report: counting (FileName, FirstLine, LastLine, Clients, Timing).
    

request_client (FileName, First, Last, Client) ->
    Sender = {?WORDCOUNT_SERVER, node ()},
    {?WORDCOUNT_LISTENER, list_to_atom(Client)} ! {wc, Sender, FileName, First, Last}.
    
    
listen_for_responses (0, Responses) ->
    Responses;
listen_for_responses (N, {WordCounts, Times}) ->
    io: format ("Waiting for a response~n"),    
    receive 
        {response, Node, Dict, Timing} ->
            io: format ("Received response from node ~p~n", [Node]),
            Merged = dict: merge (fun(_,V1,V2) -> V1+V2 end, WordCounts, Dict),
            listen_for_responses (N-1, {Merged, [{Node, Timing}|Times]});
        Other ->
            io: format ("Unexpected response ~p~n",[Other]),
            error
    end.


