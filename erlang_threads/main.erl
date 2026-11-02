-module(bench).
-export([main/1]).

worker() ->
    timer:sleep(10000),
    ok.

main([NumStr | _]) ->
    Num = list_to_integer(NumStr),
    [spawn(fun worker/0) || _ <- lists:seq(1, Num)],
    io:format("All tasks completed~n").

main(_) ->
    main(["100000"]).
