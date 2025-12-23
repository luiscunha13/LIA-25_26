% ============================
% RANKING.PL
% ============================

:- use_module(library(date)).
:- use_module(library(lists)).

ranking_file('Ranking/ranking.csv').

% Guardar resultado (CSV):
% timestamp,jogador,modo,tema,pontuacao,outcome
guardar_resultado(Jogador, Modo, Tema, Pontuacao, Outcome) :-
    get_time(T),
    stamp_date_time(T, DT, 'UTC'),
    format_time(string(TS), '%FT%TZ', DT),

    ranking_file(F),
    open(F, append, S),
    format(S, "~w,~w,~w,~w,~d,~w~n", [TS, Jogador, Modo, Tema, Pontuacao, Outcome]),
    close(S).

% UI: mostrar ranking
mostrar_ranking :-
    ler_resultados(Rs),
    (   Rs = []
    ->  writeln('Ainda não há jogos registados no ranking.')
    ;   writeln('═══════════════════════════════════════════════════════════════'),
        writeln('RANKING MUNDIAL (TOP 3)'),
        writeln('═══════════════════════════════════════════════════════════════'),
        nl,
        sort(5, @>=, Rs, Ordenado), % ordena por pontuação desc
        mostrar_top(Ordenado, 3, 1)
    ).

% Ler resultados do CSV
ler_resultados(Resultados) :-
    ranking_file(F),
    (   \+ exists_file(F)
    ->  Resultados = []
    ;   open(F, read, S),
        ler_linhas(S, Resultados),
        close(S)
    ).

ler_linhas(S, []) :-
    at_end_of_stream(S), !.
ler_linhas(S, Rs) :-
    read_line_to_string(S, Linha),
    (   Linha = ""
    ->  ler_linhas(S, Rs)
    ;   (   parse_linha_ranking(Linha, R)
        ->  Rs = [R|Rest],
            ler_linhas(S, Rest)
        ;   % linha inválida -> ignora
            ler_linhas(S, Rs)
        )
    ).

parse_linha_ranking(Linha, registo(TS, Jogador, Modo, Tema, Pontuacao, Outcome)) :-
    split_string(Linha, ",", " \t\r\n", [TS, JogStr, ModoStr, TemaStr, PontStr, OutcomeStr]),
    Jogador = JogStr,
    atom_string(Modo, ModoStr),
    atom_string(Tema, TemaStr),
    number_string(Pontuacao, PontStr),
    atom_string(Outcome, OutcomeStr).

mostrar_top(_, Max, I) :- I > Max, !.
mostrar_top([], _, _) :- !.
mostrar_top([registo(_TS, Jog, Modo, Tema, P, Outcome)|Rs], Max, I) :-
    format("~d) ~w  —  €~d  (~w / ~w / ~w)~n", [I, Jog, P, Modo, Tema, Outcome]),
    I2 is I + 1,
    mostrar_top(Rs, Max, I2).
