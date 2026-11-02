:- use_module(library(threads)).

main :-
    (   current_prolog_flag(argv, Argv),
        append(_, [NumStr|_], Argv),
        atom_number(NumStr, NumTasks)
    ;   NumTasks = 100000
    ),
    spawn_workers(NumTasks),
    % Wait for all worker threads to finish
    await_all(NumTasks),
    format('All tasks completed~n').

spawn_workers(0).
spawn_workers(N) :-
    N > 0,
    thread_create((sleep(10), true), _, [detached(false)]),
    N1 is N - 1,
    spawn_workers(N1).

await_all(0).
await_all(N) :-
    N > 0,
    thread_join(_, _),
    N1 is N - 1,
    await_all(N1).

:- initialization(main).
