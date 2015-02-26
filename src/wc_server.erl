-module (wc_server).

-include_lib("eunit/include/eunit.hrl").

-export ([count/0]).
-export ([count/1]).
-export ([count/2]).
-export ([count/3]).
-export ([count/4]).
-export ([portion/3]).
-export ([hard_coded_clients/0]).
-export ([quit/1]).
-export ([register/0]).

-define (WORDCOUNT_SERVER, wordcount_server).    
-define (WORDCOUNT_LISTENER, wordcount_listener).
-define (DEFAULT_LINES_NB, 3).

%% To start Server and launch computations :
%% ./start_server.sh 
%% wc_server:register(), wc_server:count(10).

register () ->
    true = register (?WORDCOUNT_SERVER, self ()),
    io: format ("server registered~n"),    
    ok.

quit (Clients) ->
    [ {?WORDCOUNT_LISTENER, Node} ! quit || Node <- Clients ].

count () ->
    count (?DEFAULT_LINES_NB).

count (Number_lines) ->
    count (1, Number_lines).

count (First_line, Last_line) ->
    count ("gros.txt", First_line, Last_line).

count (FileName, From, To) ->
    Clients = case read_file: all ("clients.txt") of
		  [] ->
		      hard_coded_clients ();
		  Defined_clients ->
		      Defined_clients
	      end,
    count (FileName, From, To, Clients).

count (FileName, First_line, Last_line, Clients) ->
    {Portion, Active_clients} = portion (First_line, Last_line, Clients),
    case Active_clients of
	[] ->
	    report: print_info ([{"Wrong number of lines", Last_line - First_line}]);
	_ ->	    
	    Start_time = erlang:now(),
	    send_portions_to_clients (FileName, First_line, Portion, Last_line, Active_clients),
	    {_WordCount, Timing} = listen_for_responses (length (Active_clients), {dict: new (), []}),
	    Total_time = timer:now_diff (erlang:now(), Start_time),
	    report(FileName, First_line, Last_line, Active_clients, Timing, Total_time)
    end.

hard_coded_clients () ->
    ["client@bernard-VirtualBox"].

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

send_portions_to_clients(FileName, First_line_node, Portion, Last_line, [Client|Clients]) ->
    Last_line_node = First_line_node + Portion,
    send_portion_to_client(FileName, First_line_node, Last_line_node, Client),
    send_portions_to_clients(FileName, Last_line_node, Portion, Last_line, Clients);    
send_portions_to_clients(FileName, First_line_node, _, Last_line, Client) ->
    send_portion_to_client(FileName, First_line_node, Last_line, Client).

send_portion_to_client(FileName, First_line_node, Last_line_node, Client) ->
    Sender = {?WORDCOUNT_SERVER, node ()},
    {?WORDCOUNT_LISTENER, list_to_atom(Client)} ! {wc, Sender, FileName, First_line_node, Last_line_node}.

listen_for_responses (0, Responses) ->
    Responses;
listen_for_responses (N, {WordCounts, Times}) ->
    io: format ("Waiting for a response~n"),    
    receive 
        {response, Node, {Dict, TimeReadingFile, TimeCounting}} ->
            io: format ("Received response from node ~p~n", [Node]),
            Merged = dict: merge (fun(_,V1,V2) -> V1+V2 end, WordCounts, Dict),
            listen_for_responses (N-1, {Merged, [[Node, TimeReadingFile, TimeCounting]|Times]});
        Other ->
            io: format ("Unexpected response ~p~n",[Other]),
            error
    end.

report(FileName, First_line, Last_line, Clients, Timing, Total_time) ->
    report: print_info ([{"Word count of file", FileName},
			 {"launched on clients: ", Clients},
			 {"number of lines treated", Last_line - First_line + 1},
			 {"total exec time in sec", Total_time/1000000}, 
			 {"nodes_infos", Timing}]).
