:- module(sound_effect, [
    tocar_som_vitoria/0,
    tocar_som_primeiro_menu/0,
    tocar_som_main_menu/0,
    parar_som/0
]).

:- use_module(library(process)).



:- use_module(library(unix)).

:- initialization(setup_signals).

setup_signals :-
    on_signal(int,  _, handle_exit),  % Ctrl+C
    on_signal(term, _, handle_exit),  % kill
    on_signal(hup,  _, handle_exit).

handle_exit(_Signal) :-
    parar_som,
    halt(0).


:- dynamic som_pid/1.








% --- helper: arranca um loop e guarda o PID
start_loop(Comando) :-
    process_create(path(sh), ['-c', Comando], [process(PID), detached(true)]),
    assertz(som_pid(PID)).

% --- helper: mata todos os PIDs que nós próprios criámos
stop_all_loops :-
    forall(retract(som_pid(PID)),
           catch(process_kill(PID, term), _, true)).

tocar_som_vitoria :-
    % toca uma vez (não guardar PID)
    process_create(path(sh),
        ['-c', 'ffplay -nodisp -autoexit -loglevel quiet SoundEffects/vitoria.mp3 >/dev/null 2>&1'],
        [detached(true)]).

tocar_som_primeiro_menu :-
    stop_all_loops,
    start_loop('while true; do ffplay -nodisp -autoexit -loglevel quiet SoundEffects/primeiro_menu.mp3 >/dev/null 2>&1; done').

tocar_som_main_menu :-
    stop_all_loops,
    start_loop('while true; do ffplay -nodisp -autoexit -loglevel quiet SoundEffects/main_menu.mp3 >/dev/null 2>&1; done').

parar_som :-
    stop_all_loops.

:- at_halt(parar_som).
