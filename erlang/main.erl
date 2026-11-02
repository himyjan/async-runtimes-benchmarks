-module(main).
-export([main/1]).

worker(Parent) ->
    timer:sleep(10000),
    Parent ! done.

main([NumStr | _]) ->
    Num = list_to_integer(NumStr),
    Parent = self(),
    [spawn(fun() -> worker(Parent) end) || _ <- lists:seq(1, Num)],
    [receive done -> ok end || _ <- lists:seq(1, Num)],
    io:format("All tasks completed~n").

main(_) ->
    main(["100000"]).
