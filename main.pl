% Importação de modulos
:- consult('interface.pl').
:- consult('ajudas.pl').

% ============================================================================
% MENU DE SELEÇÃO DE TEMA/MODALIDADE
% ============================================================================

% Menu principal de seleção de modo
mostrar_menu_tema :-
    limpar_tela,
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                  SELECIONE O MODO DE JOGO                     ║'),
    writeln('╠═══════════════════════════════════════════════════════════════╣'),
    writeln('║                                                               ║'),
    writeln('║  [1] Modo Geral                                               ║'),
    writeln('║                                                               ║'),
    writeln('║  [2] Versão Futebol ⚽                                        ║'),
    writeln('║                                                               ║'),
    writeln('║  [3] Versão Cultura Portuguesa 🇵🇹                            ║'),
    writeln('║                                                               ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln(''),
    write('Sua escolha: ').

% ============================================================================
% SISTEMA DE PERGUNTAS ALEATÓRIAS POR TEMA
% ============================================================================

% Lista de ficheiros por tema
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

% Carrega um ficheiro de perguntas aleatoriamente conforme o tema
carregar_perguntas_aleatorias(Tema) :-
    ficheiros_tema(Tema, Ficheiros),
    length(Ficheiros, NumFicheiros),
    random(0, NumFicheiros, Indice),
    nth0(Indice, Ficheiros, FicheiroEscolhido),
    
    % Verifica se o ficheiro existe antes de carregar
    (exists_file(FicheiroEscolhido) ->
        consult(FicheiroEscolhido)
    ;
        writeln('❌ ERRO: Ficheiro não encontrado!'),
        format('  Procurando: ~w~n', [FicheiroEscolhido]),
        halt(1)
    ).

% Mostra o logo conforme o tema
mostrar_logo_tema(geral) :- mostrar_logo.
mostrar_logo_tema(futebol) :- mostrar_logo_futebol.
mostrar_logo_tema(cultura_portuguesa) :- mostrar_logo_cultura_portuguesa.

% ============================================================================
% FLUXO PRINCIPAL DO JOGO - VERSÃO SIMPLIFICADA
% ============================================================================

jogar :-
    limpar_tela,
    mostrar_menu_tema,
    read_line_to_string(user_input, Escolha),
    tratar_escolha_tema(Escolha).

% Trata a escolha do tema
tratar_escolha_tema("1") :-
    iniciar_jogo_tema(geral).

tratar_escolha_tema("2") :-
    iniciar_jogo_tema(futebol).

tratar_escolha_tema("3") :-
    iniciar_jogo_tema(cultura_portuguesa).

tratar_escolha_tema(_) :-
    writeln('❌ Escolha inválida! Selecione 1, 2 ou 3.'),
    sleep(2),
    jogar.

% Inicia o jogo com um tema específico
iniciar_jogo_tema(Tema) :-
    limpar_tela,
    mostrar_logo_tema(Tema),
    mostrar_boas_vindas_tema(Tema),
    read_line_to_string(user_input, _),
    iniciar_jogo_com_tema(Tema).

% Mostra boas-vindas específicas por tema
mostrar_boas_vindas_tema(geral) :-
    writeln(''),
    writeln('Bem-vindo ao QUEM QUER SER MILIONÁRIO!'),
    writeln(''),
    writeln('Responda 20 perguntas e ganhe até €1.000.000!'),
    writeln('Você tem 3 ajudas: 50/50, Ajuda do Público e Telefone.'),
    writeln(''),
    write('Pressione ENTER para começar...').

mostrar_boas_vindas_tema(futebol) :-
    writeln(''),
    writeln('Bem-vindo ao QUEM QUER SER MILIONÁRIO - VERSÃO FUTEBOL! ⚽'),
    writeln(''),
    writeln('Testa os teus conhecimentos sobre o mundo do futebol!'),
    writeln('Responda 20 perguntas e ganhe até €1.000.000!'),
    writeln('Você tem 3 ajudas: 50/50, Ajuda do Público e Telefone.'),
    writeln(''),
    write('Pressione ENTER para começar...').

mostrar_boas_vindas_tema(cultura_portuguesa) :-
    writeln(''),
    writeln('Bem-vindo ao QUEM QUER SER MILIONÁRIO - VERSÃO CULTURA PORTUGUESA! 🇵🇹'),
    writeln(''),
    writeln('Testa os teus conhecimentos sobre Portugal e sua cultura!'),
    writeln('Responda 20 perguntas e ganhe até €1.000.000!'),
    writeln('Você tem 3 ajudas: 50/50, Ajuda do Público e Telefone.'),
    writeln(''),
    write('Pressione ENTER para começar...').

% Inicializa o jogo com tema específico
iniciar_jogo_com_tema(Tema) :-
    limpar_tela,
    carregar_perguntas_aleatorias(Tema),
    loop_jogo(1, 0, [ajuda_50_50, ajuda_publico, telefone]).

% ============================================================================
% REGRAS DO JOGO
% ============================================================================

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
% LOOP DO JOGO
% ============================================================================

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

% Utilidades
upcase_escolha(String, Atom) :-
    string_upper(String, Upper),
    atom_string(Atom, Upper).

%pixler