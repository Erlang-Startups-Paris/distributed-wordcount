-module (wc_client).
-export ([start/0]).

-define (WORDCOUNT_LISTENER, wordcount_listener).

start () ->
    register (?WORDCOUNT_LISTENER, self ()),
    listen_for_request ().

listen_for_request () ->
    io: format ("Client ~p waiting for request~n", [node ()]),
    receive 
        {wc, Sender, FileName, From, To} ->
            io: format ("Received request from ~p: file ~p from ~p to ~p~n",
                        [Sender, FileName, From, To]),
            Response = wordcount: count_file (FileName, From, To),
            io: format ("Sending back response to ~p~n", [Sender]),
            Sender ! {response, node(), Response},
            listen_for_request ();
        quit -> 
            io: format ("quit~n"),
            ok
    end.
                             
