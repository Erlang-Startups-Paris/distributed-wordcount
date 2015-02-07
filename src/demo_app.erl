-module (demo_app).
-behaviour (application).

-export ([start/2, stop/1]).
-export ([start/0]).
-export ([stop/0]).

start () ->
    ok = application: start (crypto),
    ok = application: start (cowlib),    
    ok = application: start (ranch),
    ok = application: start (cowboy),
    
    start([],[]).

  
stop () ->
    ok = application: stop (cowboy),
    ok = application: stop (ranch),
    ok = application: stop (cowlib),
    ok = application: stop (crypto),
    ok.

start(_StartType, _StartArgs) ->  
    Dispatch = cowboy_router: compile ([
                                        %% {URIHost, list({URIPath, Handler, Opts})}
                                        {'_', [
                                               {"/demo", cowboy_echo, []},
                                               {"/fact", cowboy_fact, []}
                                              ]}
                                       ]),
 
    {ok, _} = cowboy: start_http (my_http_listener, 100,
                                  [{port, 8090}],
                                  [{env, [{dispatch, Dispatch}]}]),
    ok.

stop(_State) ->
    ok.

