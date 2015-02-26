-module (wc_server_test).
-include_lib("eunit/include/eunit.hrl").
-test (exports).

-define(CLIENT, "host@node").
-define(CLIENTS, ["host1@node1",
		  "host2@node2",
		  "host3@node3"]).
-define(FILENAME, "filename.txt").

portion_test() ->
    %% One client, starting from line 1
    ?assertEqual ({10, [?CLIENT]}, wc_server:portion( 1,10,[?CLIENT])),
    ?assertEqual ({ 3, [?CLIENT]}, wc_server:portion( 1, 3,[?CLIENT])),
    %% Three clients, starting from line 1
    ?assertEqual ({ 1, ?CLIENTS},  wc_server:portion( 1, 3, ?CLIENTS)),
    ?assertEqual ({ 1, ["host1@node1",
			"host2@node2"]},wc_server:portion( 1, 2, ?CLIENTS)),
    %% starting from line 5
    ?assertEqual ({ 2, ?CLIENTS}, wc_server:portion( 5,10, ?CLIENTS)),
    ?assertEqual ({ 1, ["host1@node1",
			"host2@node2"]}, wc_server:portion( 5, 6, ?CLIENTS)),
    ?assertEqual ({ 1, ["host1@node1"]}, wc_server:portion( 5, 5, ?CLIENTS)),
    %% Start line > End line
    ?assertEqual ({ 0, []}, wc_server:portion( 5, 2, ?CLIENTS)).
