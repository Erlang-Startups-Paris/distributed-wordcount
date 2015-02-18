-module (read_file).

-export ([all/1]).
-export ([from_to/3]).


all (FileName) ->
    from_to (FileName, 1, eof).

from_to (FileName, From, To) ->
    {ok, Device} = file: open (FileName, read),
    skip_first_lines  (Device, From-1),
    for_each_line (Device, From, To, []).

skip_first_lines (_, 0) -> 
    ok;
skip_first_lines (Device, N) ->
    io: get_line (Device, ""),
    skip_first_lines (Device, N-1).

for_each_line (Device, From, To, Accum) when is_number (To) and (From > To)->
    close (Device, Accum);
for_each_line (Device, From, To, Accum) ->
    case io: get_line (Device, "") of
        eof  -> close (Device, Accum);
        Line -> 
            for_each_line (Device, From+1, To, [trim_nl (Line)|Accum])
    end.

close (Device, Accum) ->
    file: close (Device), Accum.


trim_nl (S) ->
    lists: reverse (trim_first_nl (lists: reverse (S))).

trim_first_nl ([$\n|Other]) ->
    Other;
trim_first_nl (Any) ->
    Any.

