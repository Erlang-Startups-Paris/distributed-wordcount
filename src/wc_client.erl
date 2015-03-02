-module (wc_client).
-export ([start/0]).

-define (WORDCOUNT_LISTENER, wordcount_listener).

start () ->
    register (?WORDCOUNT_LISTENER, self ()),
    log_server: start (),
    listen_for_request ().

listen_for_request () ->
    log_server: clear (),
    io: format ("Client ~p waiting for request~n", [node ()]),
    receive 
        {wc, Sender, FileName, From, To} ->
            io: format ("Received request from ~p: file ~p from ~p to ~p~n",
                        [Sender, FileName, From, To]),
            Wordcount = count_file (FileName, From, To),
            io: format ("Sending back response to ~p~n", [Sender]),
            Timing = log_server: list (),
            Sender ! {response, node (), Wordcount, Timing},
            listen_for_request ();
        quit -> 
            io: format ("quit~n"),
            ok
    end.
                             
%% read lines from a text file

count_file (Name, From, To) ->
    L = log_server: time (read_file, fun ()-> read_file: from_to (Name, From, To) end),
    Dict = log_server: time (counting_all, fun ()-> wordcount: lines_p (L) end),
    Dict.
