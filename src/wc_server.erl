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

count (File_name, FirstLine, LastLine) ->
    Clients = read_file: all ("clients.txt"),
    count (File_name, FirstLine, LastLine, Clients).

count (File_name, FirstLine, LastLine, Clients) ->
    {Portion, ActiveClients} = chunk: portion (FirstLine, LastLine, Clients),
    case ActiveClients of
	[] -> {error, wrong_number_of_lines};
	_ ->	    
            send_portions_to_clients (File_name, FirstLine, Portion, LastLine, ActiveClients),
            {_Result, Timing} = listen_for_responses (length (ActiveClients), {dict: new (), []}),
            report: counting (File_name, FirstLine, LastLine, Clients, Timing)
    end.


send_portions_to_clients (FileName, FirstLineNode, Portion, LastLine, [Client|Clients]) ->
    LastLineNode = FirstLineNode + Portion,
    send_portion_to_client (FileName, FirstLineNode, LastLineNode, Client),
    send_portions_to_clients (FileName, LastLineNode, Portion, LastLine, Clients);    
send_portions_to_clients (FileName, FirstLineNode, _, LastLine, Client) ->
    send_portion_to_client (FileName, FirstLineNode, LastLine, Client).

send_portion_to_client (FileName, FirstLineNode, LastLineNode, Client) ->
    Sender = {?WORDCOUNT_SERVER, node ()},
    {?WORDCOUNT_LISTENER, list_to_atom(Client)} ! {wc, Sender, FileName, FirstLineNode, LastLineNode}.



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


