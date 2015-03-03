-module (chunk_test).
-test (exports).

-export ([split_list/0]).
-export ([ranges/0]).


split_list () ->    
    [[c,d],[a,b]] = chunk: list ([a,b,c,d], 2),
    [[c,d,e],[a,b]] = chunk: list ([a,b,c,d,e], 2),
    [[c],[b],[a]] = chunk: list ([a,b,c], 32),
    ok.

ranges () ->
    [{1, 3}, {4, 6}, {7, 10}] = chunk: ranges (1, 10, 3),
    [{1, 5}, {6, 10}] = chunk: ranges (1, 10, 2),
    [{1, 10}] = chunk: ranges (1, 10, 1),
    [{11, 13}, {14, 16}] = chunk: ranges (11, 16, 2),
    ok.
    
