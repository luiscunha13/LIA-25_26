% Importação de modulos
:- consult('perguntas.pl').
:- consult('interface.pl').
:- consult('ajudas.pl').

% Níveis de dificuldade das perguntas
nivel_dificuldade(N, 'Fácil') :- N >= 1, N =< 5.
nivel_dificuldade(N, 'Médio') :- N >= 6, N =< 10.
nivel_dificuldade(N, 'Difícil') :- N >= 11, N =< 15.
nivel_dificuldade(N, 'Muito Difícil') :- N >= 16, N =< 20.

% Patamares de segurança
patamar_seguranca(5, 3000).    
patamar_seguranca(10, 20000).  
patamar_seguranca(15, 100000).

% Predicados dinâmicos para lógica
:- dynamic jogador_acertou/0.
:- dynamic jogador_errou/0.
:- discontiguous conclusao/1.

% ============================================================================
% REGRAS DE INFERÊNCIA LÓGICA
% ============================================================================

% MODUS PONENS: Se P → Q e P é verdadeiro, então Q é verdadeiro
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

% MODUS TOLLENS: Se P → Q e Q é falso, então P é falso
falso(progresso) :- jogador_errou.

conclusao(nao_resposta_certa) :- 
    implica(resposta_certa, progresso),
    falso(progresso).

aplicar_modus_tollens :-
    mostrar_modus_tollens,
    assertz(jogador_errou),
    sleep(2),
    retractall(jogador_errou).

% MODUS MISTAKEN: Falácia - Afirmação do Consequente
conclusao_incorreta(resposta_certa) :- 
    implica(resposta_certa, progresso),
    verdadeiro(progresso).

demonstrar_modus_mistaken :-
    mostrar_modus_mistaken.

% Demonstração interativa
demonstrar_logica :-
    mostrar_demonstracao_logica.

% ============================================================================
% FLUXO PRINCIPAL DO JOGO
% ============================================================================


jogar :-
    limpar_tela,
    mostrar_logo,
    mostrar_boas_vindas,
    read_line_to_string(user_input, _),
    iniciar_jogo.

% Inicializa o jogo
iniciar_jogo :-
    limpar_tela,
    loop_jogo(1, 0, [ajuda_50_50, ajuda_publico, telefone]).

% Loop principal do jogo (recursivo)
loop_jogo(Nivel, Dinheiro, _) :-
    Nivel > 20,
    !,
    limpar_tela,
    mostrar_vitoria(Dinheiro).

loop_jogo(Nivel, DinheiroAtual, Ajudas) :-
    Nivel =< 20,
    limpar_tela,
    nivel_dificuldade(Nivel, NivelDificuldade),
    
    selecionar_pergunta(Nivel, ID, ValorPergunta, Texto, Opcoes, RespostaCorreta),
    mostrar_cabecalho(Nivel, DinheiroAtual, Ajudas, NivelDificuldade),
    mostrar_pergunta(Texto, Opcoes),
    
    mostrar_menu_opcoes,
    
    read_line_to_string(user_input, Input),
    upcase_escolha(Input, EscolhaUpper),
    
    processar_escolha(EscolhaUpper, Nivel, DinheiroAtual, ValorPergunta, 
                      RespostaCorreta, Ajudas, ID, Texto, Opcoes).

% Processamento de escolhas
processar_escolha('Q', _, Dinheiro, _, _, _, _, _, _) :-
    !,
    limpar_tela,
    mostrar_desistencia(Dinheiro).

processar_escolha('H', Nivel, Dinheiro, _, RespostaCorreta, 
                  Ajudas, _, Texto, Opcoes) :-
    !,
    (   Ajudas = [] ->
        mostrar_sem_ajudas,
        read_line_to_string(user_input, _),
        loop_jogo(Nivel, Dinheiro, Ajudas)
    ;
        usar_ajuda(Ajudas, NovasAjudas, Texto, Opcoes, RespostaCorreta),
        loop_jogo(Nivel, Dinheiro, NovasAjudas)
    ).

processar_escolha(Resposta, Nivel, DinheiroAtual, ValorPergunta, 
                  RespostaCorreta, Ajudas, _, _, _) :-
    member(Resposta, ['A', 'B', 'C', 'D']),
    !,
    verificar_resposta(Resposta, RespostaCorreta, Nivel, DinheiroAtual, 
                       ValorPergunta, Ajudas).

processar_escolha(_, Nivel, Dinheiro, _, _, Ajudas, _, _, _) :-
    mostrar_escolha_invalida,
    read_line_to_string(user_input, _),
    loop_jogo(Nivel, Dinheiro, Ajudas).

% Verificação de resposta
verificar_resposta(Resposta, RespostaCorreta, Nivel, DinheiroAtual, ValorPergunta, Ajudas) :-
    Resposta = RespostaCorreta,
    !,
    NovoDinheiro is DinheiroAtual + ValorPergunta,
    limpar_tela,
    mostrar_resposta_correta(ValorPergunta, NovoDinheiro),
    
    (   patamar_seguranca(Nivel, Patamar) ->
        mostrar_patamar_seguranca(Patamar)
    ;   true
    ),
    
    writeln(''),
    write('Pressione ENTER para continuar...'),
    read_line_to_string(user_input, _),
    
    aplicar_modus_ponens,
    
    ProximoNivel is Nivel + 1,
    loop_jogo(ProximoNivel, NovoDinheiro, Ajudas).

verificar_resposta(_, RespostaCorreta, Nivel, DinheiroAtual, _, _) :-
    limpar_tela,
    calcular_dinheiro_erro_desistir(Nivel, DinheiroAtual, DinheiroFinal),
    mostrar_resposta_errada(RespostaCorreta, DinheiroFinal),
    aplicar_modus_tollens.

% Seleção de perguntas
selecionar_pergunta(NivelJogo, ID, ValorPergunta, Texto, Opcoes, RespostaCorreta) :-
    findall(
        pergunta(I, _, Valor, T, O, R),
        pergunta(I, NivelJogo, Valor, T, O, R),
        Perguntas
    ),
    
    length(Perguntas, Total),
    random(0, Total, Index),
    nth0(Index, Perguntas, pergunta(ID, _, ValorPergunta, Texto, Opcoes, RespostaCorreta)).

% Cálculo de dinheiro ao errar
calcular_dinheiro_erro_desistir(NivelAtual, _, DinheiroFinal) :-
    findall(
        Valor,
        (patamar_seguranca(N, Valor), N < NivelAtual),
        Patamares
    ),
    (   Patamares = [] ->
        DinheiroFinal = 0
    ;   max_list(Patamares, DinheiroFinal)
    ).


upcase_escolha(String, Atom) :-
    string_upper(String, Upper),
    atom_string(Atom, Upper).

%pixler
