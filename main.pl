% ============================
% MAIN.PL
% ============================
:- dynamic pergunta/6.
:- multifile pergunta/6.
:- discontiguous pergunta/6.


:- use_module(library(random)).
:- use_module(library(lists)).
:- use_module(library(date)).
:- consult('ascii_logo.pl').

:- consult('interface.pl').
:- consult('ajudas.pl').
:- consult('ranking.pl').
:- consult('jogos.pl').


% ============================================================================
% ENTRYPOINT
% ============================================================================
jogar :- menu_principal.

% ============================================================================
% A) UI / Navegação (menu principal)
% ============================================================================

menu_principal :-
    setar_modo_jogo,
    limpar_tela,
    pintar_fundo,     % 👈 isto é o que te faltava para ficar mesmo preto
    mostrar_logo,
    mostrar_menu_principal,
    read_line_to_string(user_input, Opcao),
    tratar_menu_principal(Opcao).


tratar_menu_principal("1") :- !, fluxo_novo_jogo, menu_principal.
tratar_menu_principal("2") :- !, mostrar_ranking_ui, esperar_enter, menu_principal.
tratar_menu_principal("3") :- !, mostrar_info_ui, esperar_enter, menu_principal.

tratar_menu_principal("4") :-
    !,
    resetar_terminal,
    limpar_tela.


tratar_menu_principal(_)   :-
    writeln('❌ Opção inválida!'),
    sleep(1),
    menu_principal.

esperar_enter :-
    nl, write('Pressione ENTER para continuar...'),
    read_line_to_string(user_input, _).

mostrar_ranking_ui :-
    limpar_tela,
    mostrar_logo,
    nl,
    mostrar_ranking.

mostrar_info_ui :-
    limpar_tela,
    mostrar_logo,
    nl,
    writeln('═══════════════════════════════════════════════════════════════'),
    writeln('INFO / REGRAS'),
    writeln('═══════════════════════════════════════════════════════════════'),
    nl,
    writeln('- Modos:'),
    writeln('  • Treino: 20 perguntas, 3 ajudas, não entra no ranking.'),
    writeln('  • Rápido: 10 perguntas, 2 ajudas (50/50 e Público), entra no ranking.'),
    writeln('  • Competitivo: 20 perguntas, 3 ajudas, entra no ranking.'),
    nl,
    writeln('- Durante o jogo:'),
    writeln('  • Responder: A/B/C/D'),
    writeln('  • Usar ajuda: H'),
    writeln('  • Desistir: Q'),
    nl,
    writeln('- Patamares de segurança nas perguntas: 5, 10, 15.'),
    nl.

% ============================================================================
% B) Configuração (jogador + modo + tema)
% ============================================================================

fluxo_novo_jogo :-
    pedir_nome(Jogador),
    escolher_modo(Modo),
    escolher_tema(Tema),
    config_modo(Modo, FlagRanking, AjudasIniciais, MaxNivel),
    iniciar_jogo_config(Jogador, Modo, Tema, FlagRanking, AjudasIniciais, MaxNivel).

pedir_nome(Jogador) :-
    limpar_tela,
    mostrar_logo,
    nl,
    writeln('Nome do jogador:'),
    write('> '),
    read_line_to_string(user_input, Nome),
    normalize_space(string(NomeLimpo), Nome),
    (   NomeLimpo = ""
    ->  writeln('❌ Nome inválido.'), sleep(1), pedir_nome(Jogador)
    ;   Jogador = NomeLimpo
    ).

escolher_modo(Modo) :-
    limpar_tela,
    mostrar_logo,
    mostrar_menu_modo,
    read_line_to_string(user_input, X),
    tratar_escolha_modo(X, Modo).

tratar_escolha_modo("1", treino).
tratar_escolha_modo("2", rapido).
tratar_escolha_modo("3", competitivo).
tratar_escolha_modo(_, Modo) :-
    writeln('❌ Escolha inválida!'),
    sleep(1),
    escolher_modo(Modo).

% Mantém o teu menu de temas (era "modo" no texto, mas é tema)
escolher_tema(Tema) :-
    limpar_tela,
    mostrar_logo,
    mostrar_menu_tema,
    read_line_to_string(user_input, Escolha),
    tratar_escolha_tema(Escolha, Tema).

tratar_escolha_tema("1", geral).
tratar_escolha_tema("2", futebol).
tratar_escolha_tema("3", cultura_portuguesa).
tratar_escolha_tema(_, Tema) :-
    writeln('❌ Escolha inválida! Selecione 1, 2 ou 3.'),
    sleep(1),
    escolher_tema(Tema).

% Parâmetros do modo
% FlagRanking = grava | nao_grava
config_modo(treino,      nao_grava, [ajuda_50_50, ajuda_publico, telefone], 20).
config_modo(rapido,      grava,     [ajuda_50_50, ajuda_publico],           10).
config_modo(competitivo, grava,     [ajuda_50_50, ajuda_publico, telefone], 20).

% ============================================================================
% Carregamento de perguntas por tema (o teu sistema, com limpeza)
% ============================================================================

ficheiros_tema(geral, ['Geral/perguntas1.pl', 'Geral/perguntas2.pl', 'Geral/perguntas3.pl',
                       'Geral/perguntas4.pl', 'Geral/perguntas5.pl', 'Geral/perguntas6.pl',
                       'Geral/perguntas7.pl', 'Geral/perguntas8.pl', 'Geral/perguntas9.pl',
                       'Geral/perguntas10.pl']).

ficheiros_tema(futebol, ['MilionárioFutebol/perguntas1.pl',
                         'MilionárioFutebol/perguntas2.pl',
                         'MilionárioFutebol/perguntas3.pl',
                         'MilionárioFutebol/perguntas4.pl',
                         'MilionárioFutebol/perguntas5.pl']).

ficheiros_tema(cultura_portuguesa, ['MilionárioCulturaPortuguesa/perguntas1.pl',
                                    'MilionárioCulturaPortuguesa/perguntas2.pl',
                                    'MilionárioCulturaPortuguesa/perguntas3.pl',
                                    'MilionárioCulturaPortuguesa/perguntas4.pl',
                                    'MilionárioCulturaPortuguesa/perguntas5.pl']).

% carregar_perguntas_aleatorias(Tema) :-
%     retractall(pergunta(_,_,_,_,_,_)),

%     ficheiros_tema(Tema, Ficheiros),
%     length(Ficheiros, NumFicheiros),
%     random(0, NumFicheiros, Indice),
%     nth0(Indice, Ficheiros, FicheiroEscolhido),
%     (   exists_file(FicheiroEscolhido)
%     ->  consult(FicheiroEscolhido)
%     ;   writeln('❌ ERRO: Ficheiro não encontrado!'),
%         format('  Procurando: ~w~n', [FicheiroEscolhido]),
%         halt(1)
%     ).

carregar_banco_tema(Tema) :-
    retractall(pergunta(_,_,_,_,_,_)),
    ficheiros_tema(Tema, Ficheiros),
    maplist(ensure_loaded, Ficheiros).


mostrar_logo_tema(geral) :- mostrar_logo.
mostrar_logo_tema(futebol) :- mostrar_logo_futebol.
mostrar_logo_tema(cultura_portuguesa) :- mostrar_logo_cultura_portuguesa.

% ============================================================================
% C) Fluxo de início do jogo + gravação ranking
% ============================================================================

% iniciar_jogo_config(Jogador, Modo, Tema, FlagRanking, AjudasIniciais, MaxNivel) :-
%     limpar_tela,
%     mostrar_logo_tema(Tema),
%     mostrar_boas_vindas_tema(Tema, Modo),
%     read_line_to_string(user_input, _),

%     limpar_tela,
%     carregar_perguntas_aleatorias(Tema),

%     % Joga e devolve dinheiro final + outcome
%     loop_jogo(1, 0, AjudasIniciais, MaxNivel, DinheiroFinal, Outcome),

%     % Ranking (apenas se FlagRanking = grava)
%     (   FlagRanking = grava
%     ->  guardar_resultado(Jogador, Modo, Tema, DinheiroFinal, Outcome)
%     ;   true
%     ).



iniciar_jogo_config(Jogador, Modo, Tema, FlagRanking, AjudasIniciais, MaxNivel) :-
    limpar_tela,
    mostrar_logo_tema(Tema),
    mostrar_boas_vindas_tema(Tema, Modo),
    read_line_to_string(user_input, _),

    % 1) carrega BANCO completo do tema
    carregar_banco_tema(Tema),

    % 2) gera jogo único (1 pergunta por nível)
    gerar_jogo(MaxNivel, PerguntasSel),

    % 3) grava histórico do jogo
    proximo_jogo_file(FicheiroJogo),
    gravar_jogo(FicheiroJogo, PerguntasSel),

    % 4) agora joga usando só esse ficheiro (exatamente o teu formato)
    retractall(pergunta(_,_,_,_,_,_)),
    consult(FicheiroJogo),
    


    % DEBUG/VALIDAÇÃO: o ficheiro do jogo carregou mesmo perguntas?
    findall(N, pergunta(_,N,_,_,_,_), Ns),
    sort(Ns, Unicos),
    format("DEBUG: ficheiro do jogo = ~w~n", [FicheiroJogo]),
    format("DEBUG: niveis carregados no jogo = ~w~n", [Unicos]),
    (Unicos = [] ->
        writeln('❌ ERRO: o ficheiro do jogo não carregou nenhuma pergunta!'),
        halt(1)
    ; true),



    loop_jogo(1, 0, AjudasIniciais, MaxNivel, DinheiroFinal, Outcome),

    ( FlagRanking = grava ->
        guardar_resultado(Jogador, Modo, Tema, DinheiroFinal, Outcome)
    ; true ).


mostrar_boas_vindas_tema(geral, Modo) :-
    nl,
    writeln('Bem-vindo ao QUEM QUER SER MILIONÁRIO!'),
    format('Modo: ~w~n', [Modo]),
    nl,
    writeln('Responda às perguntas e ganhe até €1.000.000!'),
    writeln(''),
    write('Pressione ENTER para começar...').

mostrar_boas_vindas_tema(futebol, Modo) :-
    nl,
    writeln('Bem-vindo ao QUEM QUER SER MILIONÁRIO - VERSÃO FUTEBOL! ⚽'),
    format('Modo: ~w~n', [Modo]),
    nl,
    writeln('Testa os teus conhecimentos sobre o mundo do futebol!'),
    writeln(''),
    write('Pressione ENTER para começar...').

mostrar_boas_vindas_tema(cultura_portuguesa, Modo) :-
    nl,
    writeln('Bem-vindo ao QUEM QUER SER MILIONÁRIO - VERSÃO CULTURA PORTUGUESA! 🇵🇹'),
    format('Modo: ~w~n', [Modo]),
    nl,
    writeln('Testa os teus conhecimentos sobre Portugal e a sua cultura!'),
    writeln(''),
    write('Pressione ENTER para começar...').

% ============================================================================
% REGRAS DO JOGO
% ============================================================================

nivel_dificuldade(N, 'Fácil') :- N >= 1, N =< 5.
nivel_dificuldade(N, 'Médio') :- N >= 6, N =< 10.
nivel_dificuldade(N, 'Difícil') :- N >= 11, N =< 15.
nivel_dificuldade(N, 'Muito Difícil') :- N >= 16, N =< 20.

patamar_seguranca(5, 3000).
patamar_seguranca(10, 20000).
patamar_seguranca(15, 100000).

:- dynamic jogador_acertou/0.
:- dynamic jogador_errou/0.
:- discontiguous conclusao/1.

% ============================================================================
% REGRAS DE INFERÊNCIA LÓGICA
% ============================================================================

implica(resposta_certa, progresso).
verdadeiro(resposta_certa) :- jogador_acertou.

conclusao(progresso) :-
    implica(resposta_certa, progresso),
    verdadeiro(resposta_certa).

aplicar_modus_ponens :-
    mostrar_modus_ponens,
    assertz(jogador_acertou),
    sleep(2),
    retractall(jogador_acertou).

falso(progresso) :- jogador_errou.

conclusao(nao_resposta_certa) :-
    implica(resposta_certa, progresso),
    falso(progresso).

aplicar_modus_tollens :-
    mostrar_modus_tollens,
    assertz(jogador_errou),
    sleep(2),
    retractall(jogador_errou).

conclusao_incorreta(resposta_certa) :-
    implica(resposta_certa, progresso),
    verdadeiro(progresso).

demonstrar_modus_mistaken :-
    mostrar_modus_mistaken.

demonstrar_logica :-
    mostrar_demonstracao_logica.

% ============================================================================
% LOOP DO JOGO (agora devolve DinheiroFinal e Outcome)
% Outcome = venceu | desistiu | errou
% ============================================================================

loop_jogo(Nivel, Dinheiro, _Ajudas, MaxNivel, DinheiroFinal, venceu) :-
    Nivel > MaxNivel,
    !,
    limpar_tela,
    mostrar_vitoria(Dinheiro),
    DinheiroFinal = Dinheiro.

loop_jogo(Nivel, DinheiroAtual, Ajudas, MaxNivel, DinheiroFinal, Outcome) :-
    Nivel =< MaxNivel,
    limpar_tela,
    nivel_dificuldade(Nivel, NivelDificuldade),

    selecionar_pergunta(Nivel, ID, ValorPergunta, Texto, Opcoes, RespostaCorreta),
    mostrar_cabecalho(Nivel, DinheiroAtual, Ajudas, NivelDificuldade, MaxNivel),
    mostrar_pergunta(Texto, Opcoes),
    mostrar_menu_opcoes,

    read_line_to_string(user_input, Input),
    upcase_escolha(Input, EscolhaUpper),

    processar_escolha(EscolhaUpper, Nivel, DinheiroAtual, ValorPergunta,
                      RespostaCorreta, Ajudas, ID, Texto, Opcoes,
                      MaxNivel, DinheiroFinal, Outcome).

processar_escolha('Q', _Nivel, Dinheiro, _ValorPergunta, _RespostaCorreta,
                  _Ajudas, _ID, _Texto, _Opcoes,
                  _MaxNivel, Dinheiro, desistiu) :-
    !,
    limpar_tela,
    mostrar_desistencia(Dinheiro).

processar_escolha('H', Nivel, Dinheiro, _ValorPergunta, RespostaCorreta,
                  Ajudas, _ID, Texto, Opcoes,
                  MaxNivel, DinheiroFinal, Outcome) :-
    !,
    (   Ajudas = []
    ->  mostrar_sem_ajudas,
        read_line_to_string(user_input, _),
        loop_jogo(Nivel, Dinheiro, Ajudas, MaxNivel, DinheiroFinal, Outcome)
    ;   usar_ajuda(Ajudas, NovasAjudas, Texto, Opcoes, RespostaCorreta),
        loop_jogo(Nivel, Dinheiro, NovasAjudas, MaxNivel, DinheiroFinal, Outcome)
    ).

processar_escolha(Resposta, Nivel, DinheiroAtual, ValorPergunta, RespostaCorreta,
                  Ajudas, _ID, _Texto, _Opcoes,
                  MaxNivel, DinheiroFinal, Outcome) :-
    member(Resposta, ['A', 'B', 'C', 'D']),
    !,
    verificar_resposta(Resposta, RespostaCorreta, Nivel, DinheiroAtual,
                       ValorPergunta, Ajudas,
                       MaxNivel, DinheiroFinal, Outcome).

processar_escolha(_, Nivel, Dinheiro, _ValorPergunta, _RespostaCorreta,
                  Ajudas, _ID, _Texto, _Opcoes,
                  MaxNivel, DinheiroFinal, Outcome) :-
    mostrar_escolha_invalida,
    read_line_to_string(user_input, _),
    loop_jogo(Nivel, Dinheiro, Ajudas, MaxNivel, DinheiroFinal, Outcome).

verificar_resposta(Resposta, RespostaCorreta, Nivel, DinheiroAtual, ValorPergunta, Ajudas,
                   MaxNivel, DinheiroFinal, Outcome) :-
    Resposta = RespostaCorreta,
    !,
    NovoDinheiro is DinheiroAtual + ValorPergunta,
    limpar_tela,
    mostrar_resposta_correta(ValorPergunta, NovoDinheiro),

    (   patamar_seguranca(Nivel, Patamar)
    ->  mostrar_patamar_seguranca(Patamar)
    ;   true
    ),

    nl,
    write('Pressione ENTER para continuar...'),
    read_line_to_string(user_input, _),

    aplicar_modus_ponens,

    ProximoNivel is Nivel + 1,
    loop_jogo(ProximoNivel, NovoDinheiro, Ajudas, MaxNivel, DinheiroFinal, Outcome).

verificar_resposta(_, RespostaCorreta, Nivel, DinheiroAtual, _ValorPergunta, _Ajudas,
                   _MaxNivel, DinheiroFinal, errou) :-
    limpar_tela,
    calcular_dinheiro_erro_desistir(Nivel, DinheiroAtual, DinheiroFinal),
    mostrar_resposta_errada(RespostaCorreta, DinheiroFinal),
    aplicar_modus_tollens.

% Seleção de perguntas (mantive o teu modelo pergunta/6: pergunta(ID, Nivel, Valor, Texto, Opcoes, RespostaCorreta))
selecionar_pergunta(NivelJogo, ID, ValorPergunta, Texto, Opcoes, RespostaCorreta) :-
    findall(
        pergunta(I, _, Valor, T, O, R),
        pergunta(I, NivelJogo, Valor, T, O, R),
        Perguntas
    ),
    length(Perguntas, Total),
    (   Total =:= 0
    ->  writeln('❌ ERRO: Não existem perguntas para este nível no ficheiro carregado!'),
        halt(1)
    ;   random(0, Total, Index),
        nth0(Index, Perguntas, pergunta(ID, _, ValorPergunta, Texto, Opcoes, RespostaCorreta))
    ).

calcular_dinheiro_erro_desistir(NivelAtual, _, DinheiroFinal) :-
    findall(Valor, (patamar_seguranca(N, Valor), N < NivelAtual), Patamares),
    (   Patamares = []
    ->  DinheiroFinal = 0
    ;   max_list(Patamares, DinheiroFinal)
    ).

upcase_escolha(String, Atom) :-
    string_upper(String, Upper),
    atom_string(Atom, Upper).
