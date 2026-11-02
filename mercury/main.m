:- module main.
:- import_module io, thread, int, list.

:- pred main(io::di, io::uo) is det.
main(!IO) :-
    NumTasks = 100000,
    (   command_line_args(Args, !IO),
        (   Args = [NumStr|_],
            int_from_string(NumStr, NumTasks)
        ;   true
        )
    ;   true
    ),
    Main = num_tasks(NumTasks),
    spawn_workers(NumTasks, Main),
    wait_for_all(NumTasks, Main),
    io.write_string("All tasks completed\n", !IO).

:- pred spawn_workers(int::in, num_tasks::in) is det.
spawn_workers(0, _) :- !.
spawn_workers(N, Main) :-
    N > 0,
    thread.create(worker(Main), _),
    N1 is N - 1,
    spawn_workers(N1, Main).

:- pred wait_for_all(int::in, num_tasks::in) is det.
wait_for_all(0, _) :- !.
wait_for_all(N, _) :-
    thread.wait_one,
    N1 is N - 1,
    wait_for_all(N1, _).

:- pred worker(num_tasks::in) is det.
worker(Main) :-
    thread.sleep(10.0),
    dec(Main),
    (   is_zero(Main) -> thread.signal_all
    ;   true
    ).

:- module num_tasks.
:- import_module int, thread.

:- type num_tasks ---> num_tasks(int).

:- pred dec(num_tasks::in, num_tasks::out) is det.
dec(num_tasks(N0), num_tasks(N1)) :- N1 is N0 - 1.

:- pred is_zero(num_tasks::in) is semidet.
is_zero(num_tasks(0)).
