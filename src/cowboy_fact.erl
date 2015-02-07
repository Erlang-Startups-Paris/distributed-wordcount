-module(cowboy_fact).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {NAsBinary, Req2} = cowboy_req:qs_val(<<"n">>, Req),
    {ProcessAsBinary, Req3} = cowboy_req:qs_val(<<"process">>, Req2),
    N = binary_to_integer (NAsBinary),
    Process = binary_to_integer (ProcessAsBinary),
    {ok, Req4} = fact (N, Process, Req3),
    {ok, Req4, State}.

fact(undefined, _, Req) ->
    cowboy_req:reply(400, [], <<"Missing n parameter.">>, Req);
fact(_, undefined, Req) ->
    cowboy_req:reply(400, [], <<"Missing process parameter.">>, Req);
fact(N, Process, Req) ->
    Result = fact: fp(N, Process),
    ResultAsBinary = integer_to_binary (Result),
    cowboy_req:reply(200, [
                           {<<"content-type">>, <<"text/plain; charset=utf-8">>}
                          ], ResultAsBinary, Req).

terminate(_Reason, _Req, _State) ->
    ok.
