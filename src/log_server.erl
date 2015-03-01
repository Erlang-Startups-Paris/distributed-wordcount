-module (log_server).
-behaviour (gen_server).

%% specific API
-export ([start/0]).
-export ([stop/0]).
-export ([time/2]).
-export ([list/0]).
-export ([clear/0]).

%% gen_server API
-export ([init/1, handle_call/3]).
-export ([handle_info/2]).
-export ([terminate/2]).
-export ([code_change/3]).
-export ([handle_cast/2]).


%% Public

time (Id, Fun) ->
    {Time, Result} = timer: tc (Fun),
    ok = gen_server: cast (?MODULE, {measure, Id, Time}),
    Result.

list () ->
    gen_server: call (?MODULE, list).

clear () ->    
    gen_server: cast (?MODULE, clear).
    

start () ->
    case gen_server:start({local, ?MODULE}, ?MODULE, [], []) of
        {ok, Pid} -> 
            io: format ("Starting log server for timers~n"),
            {ok, Pid};
        {error, {already_started, Pid}} -> {ok, Pid}
    end.			 

stop() ->
    gen_server: call (?MODULE, stop).


%% Internal 

init(_) ->
    {ok, []}.


handle_call (list, _From, State) ->
    L = lists: reverse (State),
    {reply, L, State}.

handle_cast ({measure, Id, Time}, State) ->
    {noreply, [{Id, Time}|State]};

handle_cast (clear, _State) ->
    {noreply, []};


handle_cast(shutdown, State) ->
    {stop, normal, State}.


handle_info (_Info, State) -> {noreply, State}.


%% Default gen_server callbacks
terminate (_Reason, _State) ->  ok.
code_change (_OldVsn, State, _Extra) -> {ok, State}.

