% ============================
% JOGOS.PL
% ============================

:- use_module(library(random)).
:- use_module(library(lists)).
:- use_module(library(filesex)).  % exists_directory/1, make_directory/1

% cria pasta Jogos/ se não existir
garantir_pasta_jogos :-
    ( exists_directory('Jogos') -> true ; make_directory('Jogos') ).

% escolhe 1 pergunta aleatória para um nível
escolher_pergunta_para_nivel(Nivel, pergunta(Id, Nivel, Valor, Texto, Opcoes, Correta)) :-
    findall(pergunta(I, Nivel, V, T, O, R),
            pergunta(I, Nivel, V, T, O, R),
            Lista),
    Lista \= [],
    random_member(pergunta(Id, Nivel, Valor, Texto, Opcoes, Correta), Lista).

% gera lista de perguntas 1..MaxNivel (1 por nível)
gerar_jogo(MaxNivel, PerguntasSelecionadas) :-
    findall(P,
        (between(1, MaxNivel, Nivel),
         escolher_pergunta_para_nivel(Nivel, P)),
        PerguntasSelecionadas),
    validar_lista_jogo(MaxNivel, PerguntasSelecionadas).

validar_lista_jogo(MaxNivel, PerguntasSelecionadas) :-
    findall(N, (member(pergunta(_,N,_,_,_,_), PerguntasSelecionadas)), Ns),
    sort(Ns, Unicos),
    findall(K, between(1, MaxNivel, K), Esperados),
    ( Unicos = Esperados -> true
    ; writeln('❌ ERRO: não foi possível gerar jogo (faltam níveis no banco)!'),
      format('Níveis obtidos: ~w~n', [Unicos]),
      format('Esperados: ~w~n', [Esperados]),
      halt(1)
    ).

% encontra próximo nome incremental
proximo_jogo_file(Ficheiro) :-
    garantir_pasta_jogos,
    proximo_indice_jogo(1, N),
    format(atom(Ficheiro), 'Jogos/jogo~w.pl', [N]).

proximo_indice_jogo(N, N) :-
    format(atom(Path), 'Jogos/jogo~w.pl', [N]),
    \+ exists_file(Path), !.
proximo_indice_jogo(N, R) :-
    N1 is N + 1,
    proximo_indice_jogo(N1, R).

% grava jogo no formato esperado (pergunta/6)
gravar_jogo(Ficheiro, PerguntasSelecionadas) :-
    open(Ficheiro, write, S),
    format(S, ":- dynamic pergunta/6.~n", []),
    format(S, ":- multifile pergunta/6.~n", []),
    format(S, ":- discontiguous pergunta/6.~n~n", []),
    gravar_perguntas(S, 1, PerguntasSelecionadas),
    close(S).

gravar_perguntas(_, _, []) :- !.
gravar_perguntas(S, NovoId, [pergunta(_OldId, Nivel, Valor, Texto, Opcoes, Correta)|Rs]) :-
    format(S, "pergunta(~d, ~d, ~d, ~q, ~q, ~q).~n",
           [NovoId, Nivel, Valor, Texto, Opcoes, Correta]),
    NovoId2 is NovoId + 1,
    gravar_perguntas(S, NovoId2, Rs).
