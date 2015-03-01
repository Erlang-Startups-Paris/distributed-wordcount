-module (wc_server).

-include_lib("eunit/include/eunit.hrl").

-export ([count/0]).
-export ([count/1]).
-export ([count/2]).
-export ([count/3]).
-export ([count/4]).
-export ([portion/3]).
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

count (First_line, Last_line) ->
    count ("gros.txt", First_line, Last_line).

count (File_name, First_line, Last_line) ->
    Clients = read_file: all ("clients.txt"),
    count (File_name, First_line, Last_line, Clients).

count (File_name, First_line, Last_line, Clients) ->
    {Portion, Active_clients} = portion (First_line, Last_line, Clients),
    case Active_clients of
	[] ->
	    report: print_info ([{"Wrong number of lines", Last_line - First_line}]);
	_ ->	    
            send_portions_to_clients (File_name, First_line, Portion, Last_line, Active_clients),
            {_Result, Timing} = listen_for_responses (length (Active_clients), {dict: new (), []}),
            report(File_name, First_line, Last_line, Clients, Timing)
    end.


portion(First_line, Last_line, _) when Last_line < First_line ->
    {0, []};
portion(First_line, Last_line, Clients) ->
    Nb_lines = Last_line - First_line + 1,
    Nb_clients = length(Clients),
    if Nb_lines =< Nb_clients ->
	    {Active_clients, _} = lists:split(Nb_lines, Clients),
	    {1, Active_clients};
       true ->
	    {(Last_line - First_line + 1) div length(Clients), Clients} 
    end.

send_portions_to_clients(File_name, First_line_node, Portion, Last_line, [Client|Clients]) ->
    Last_line_node = First_line_node + Portion,
    send_portion_to_client(File_name, First_line_node, Last_line_node, Client),
    send_portions_to_clients(File_name, Last_line_node, Portion, Last_line, Clients);    
send_portions_to_clients(File_name, First_line_node, _, Last_line, Client) ->
    send_portion_to_client(File_name, First_line_node, Last_line, Client).

send_portion_to_client(File_name, First_line_node, Last_line_node, Client) ->
    Sender = {?WORDCOUNT_SERVER, node ()},
    {?WORDCOUNT_LISTENER, list_to_atom(Client)} ! {wc, Sender, File_name, First_line_node, Last_line_node}.

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

report(File_name, First_line, Last_line, Clients, Timing) ->
    report: print_info ([{"Word count of file:", File_name},
			 {"Launched on clients:", Clients},
			 {"Number of lines treated:", Last_line - First_line + 1}]),
    report: print_timing_nodes (Timing).


