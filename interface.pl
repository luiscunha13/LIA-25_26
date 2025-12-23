% ============================
% INTERFACE.PL
% ============================
:- use_module(ascii_logo).  % se estiver na mesma pasta



% ============================
% CORES ANSI
% ============================

setar_modo_jogo :-
    write('\033[0m'),    % reset
    write('\033[37m'),   % texto branco
    write('\033[40m').   % fundo preto

resetar_terminal :-
    write('\033[0m').





% Limpa e "pinta" o ecrã com o background actual
limpar_tela :-
    setar_modo_jogo,
    write('\033[2J'),
    write('\033[H'),
    write('\033[0J').


% "Pinta" o ecrã inteiro com espaços no background actual
pintar_fundo :-
    terminal_cols_rows(Cols, Rows),
    forall(between(1, Rows, _),
           (forall(between(1, Cols, _), write(' ')), nl)),
    write('\033[H').  % volta ao topo



:- use_module(library(process)).
:- use_module(library(readutil)).

terminal_cols_rows(Cols, Rows) :-
    ( catch((process_create(path(tput), ['cols'], [stdout(pipe(O1))]),
             read_line_to_string(O1, S1), close(O1),
             number_string(Cols0, S1)), _, fail)
      -> Cols = Cols0 ; Cols = 80 ),
    ( catch((process_create(path(tput), ['lines'], [stdout(pipe(O2))]),
             read_line_to_string(O2, S2), close(O2),
             number_string(Rows0, S2)), _, fail)
      -> Rows = Rows0 ; Rows = 24 ).



% % Logo do jogo
% mostrar_logo :-
%     writeln(''),
%     writeln('╔═══════════════════════════════════════════════════════════════╗'),
%     writeln('║                                                               ║'),
%     writeln('║         ██████  ██    ██ ███████ ███    ███                   ║'),
%     writeln('║        ██    ██ ██    ██ ██      ████  ████                   ║'),
%     writeln('║        ██    ██ ██    ██ █████   ██ ████ ██                   ║'),
%     writeln('║        ██ ▄▄ ██ ██    ██ ██      ██  ██  ██                   ║'),
%     writeln('║         ██████   ██████  ███████ ██      ██                   ║'),
%     writeln('║            ▀▀                                                 ║'),
%     writeln('║                                                               ║'),
%     writeln('║           QUER SER MILIONÁRIO?                                ║'),
%     writeln('║           ★ ★ ★ ★ ★ ★ ★ ★ ★ ★                                 ║'),
%     writeln('║                                                               ║'),
%     writeln('╚═══════════════════════════════════════════════════════════════╝'),
%     writeln('').

% mostrar_logo_futebol :-
%     writeln(''),
%     writeln('╔═══════════════════════════════════════════════════════════════╗'),
%     writeln('║                                                               ║'),
%     writeln('║         ██████  ██    ██ ███████ ███    ███                   ║'),
%     writeln('║        ██    ██ ██    ██ ██      ████  ████                   ║'),
%     writeln('║        ██    ██ ██    ██ █████   ██ ████ ██                   ║'),
%     writeln('║        ██ ▄▄ ██ ██    ██ ██      ██  ██  ██                   ║'),
%     writeln('║         ██████   ██████  ███████ ██      ██                   ║'),
%     writeln('║            ▀▀                                                 ║'),
%     writeln('║                                                               ║'),
%     writeln('║           QUER SER MILIONÁRIO?                                ║'),
%     writeln('║           ★ ★ ★ ★ ★ ★ ★ ★ ★ ★                                 ║'),
%     writeln('║                                                               ║'),
%     writeln('║                    V E R S Ã O   F U T E B O L   ⚽           ║'),
%     writeln('╚═══════════════════════════════════════════════════════════════╝'),
%     writeln('').

% mostrar_logo_cultura_portuguesa :-
%     writeln(''),
%     writeln('╔═══════════════════════════════════════════════════════════════╗'),
%     writeln('║                                                               ║'),
%     writeln('║         ██████  ██    ██ ███████ ███    ███                   ║'),
%     writeln('║        ██    ██ ██    ██ ██      ████  ████                   ║'),
%     writeln('║        ██    ██ ██    ██ █████   ██ ████ ██                   ║'),
%     writeln('║        ██ ▄▄ ██ ██    ██ ██      ██  ██  ██                   ║'),
%     writeln('║         ██████   ██████  ███████ ██      ██                   ║'),
%     writeln('║            ▀▀                                                 ║'),
%     writeln('║                                                               ║'),
%     writeln('║           QUER SER MILIONÁRIO?                                ║'),
%     writeln('║           ★ ★ ★ ★ ★ ★ ★ ★ ★ ★                                 ║'),
%     writeln('║                                                               ║'),
%     writeln('║       V E R S Ã O   C U L T U R A   P O R T U G U E S A 🇵🇹    ║'),
%     writeln('╚═══════════════════════════════════════════════════════════════╝'),
%     writeln('').

 % ============================================================================
 % MENUS
 % ============================================================================

mostrar_menu_principal :-
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                    MENU PRINCIPAL                             ║'),
    writeln('╠═══════════════════════════════════════════════════════════════╣'),
    writeln('║  [1] Novo Jogo                                                 ║'),
    writeln('║  [2] Ranking                                                   ║'),
    writeln('║  [3] Regras / Info                                              ║'),
    writeln('║  [4] Sair                                                       ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    nl,
    write('Sua escolha: ').

mostrar_menu_modo :-
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                   SELECIONE O MODO                            ║'),
    writeln('╠═══════════════════════════════════════════════════════════════╣'),
    writeln('║  [1] Treino                                                    ║'),
    writeln('║  [2] Rápido                                                    ║'),
    writeln('║  [3] Competitivo                                               ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    nl,
    write('Sua escolha: ').

% Menu de seleção de tema (o teu original, mantido)
mostrar_menu_tema :-
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                  SELECIONE O TEMA                             ║'),
    writeln('╠═══════════════════════════════════════════════════════════════╣'),
    writeln('║                                                               ║'),
    writeln('║  [1] Cultura Geral                                             ║'),
    writeln('║                                                               ║'),
    writeln('║  [2] Futebol ⚽                                                ║'),
    writeln('║                                                               ║'),
    writeln('║  [3] Cultura Portuguesa 🇵🇹                                    ║'),
    writeln('║                                                               ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln(''),
    write('Sua escolha: ').

% ============================================================================
% Cabeçalho do jogo (agora mostra pergunta / MaxNivel)
% ============================================================================

mostrar_cabecalho(Nivel, Dinheiro, Ajudas, NivelDificuldade, MaxNivel) :-
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    format('║  Pergunta: ~w/~w | Dificuldade: ~w | Dinheiro: €~w~*|~n',
           [Nivel, MaxNivel, NivelDificuldade, Dinheiro, 10]),
    writeln('╠═══════════════════════════════════════════════════════════════╣'),
    write('║  Ajudas disponíveis: '),
    mostrar_ajudas(Ajudas),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln('').

mostrar_ajudas([]) :-
    writeln('Nenhuma                              ║').
mostrar_ajudas(Ajudas) :-
    Ajudas \= [],
    (member(ajuda_50_50, Ajudas) -> write('[50/50] ') ; true),
    (member(ajuda_publico, Ajudas) -> write('[Público] ') ; true),
    (member(telefone, Ajudas) -> write('[Telefone] ') ; true),
    writeln('      ║').

mostrar_pergunta(Texto, [OpA, OpB, OpC, OpD]) :-
    writeln('┌───────────────────────────────────────────────────────────────┐'),
    format('│ ~w~*|~n', [Texto, 62]),
    writeln('└───────────────────────────────────────────────────────────────┘'),
    writeln(''),
    format('  A: ~w~n', [OpA]),
    format('  B: ~w~n', [OpB]),
    format('  C: ~w~n', [OpC]),
    format('  D: ~w~n', [OpD]).

mostrar_vitoria(Dinheiro) :-
    writeln(''),
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                                                               ║'),
    writeln('║                    🎉 PARABÉNS! 🎉                            ║'),
    writeln('║                                                               ║'),
    writeln('║              VOCÊ É MILIONÁRIO!                               ║'),
    writeln('║                                                               ║'),
    format('║              Prêmio: €~w~*|~n', [Dinheiro, 30]),
    writeln('║                                                               ║'),
    writeln('║                    ★ ★ ★ ★ ★                                 ║'),
    writeln('║                                                               ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln('').

% Barra percentual visual
mostrar_barra_percentual(Pct) :-
    Barras is Pct // 2,
    write('['),
    mostrar_barras(Barras),
    write(']').

mostrar_barras(0) :- !.
mostrar_barras(N) :-
    N > 0,
    write('█'),
    N1 is N - 1,
    mostrar_barras(N1).

% ============================================================================
% MENSAGENS DE LÓGICA (mantidas)
% ============================================================================

mostrar_modus_ponens :-
    writeln(''),
    writeln('┌─────────────────────────────────────────────────────────────┐'),
    writeln('│ 🔍 MODUS PONENS (Raciocínio Válido Positivo)               │'),
    writeln('├─────────────────────────────────────────────────────────────┤'),
    writeln('│ Premissa 1: Se resposta correta → progresso                │'),
    writeln('│ Premissa 2: Resposta está correta ✓                        │'),
    writeln('│ Conclusão:  Jogador progride para próxima pergunta ✓       │'),
    writeln('└─────────────────────────────────────────────────────────────┘'),
    writeln('').

mostrar_modus_tollens :-
    writeln(''),
    writeln('┌─────────────────────────────────────────────────────────────┐'),
    writeln('│ 🔍 MODUS TOLLENS (Raciocínio Válido Negativo)              │'),
    writeln('├─────────────────────────────────────────────────────────────┤'),
    writeln('│ Premissa 1: Se resposta correta → progresso                │'),
    writeln('│ Premissa 2: Jogador NÃO progrediu ✗                        │'),
    writeln('│ Conclusão:  Resposta NÃO estava correta ✗                  │'),
    writeln('└─────────────────────────────────────────────────────────────┘'),
    writeln('').

mostrar_modus_mistaken :-
    writeln(''),
    writeln('┌─────────────────────────────────────────────────────────────┐'),
    writeln('│ ⚠️  MODUS MISTAKEN (Falácia Lógica - INVÁLIDO!)            │'),
    writeln('├─────────────────────────────────────────────────────────────┤'),
    writeln('│ Premissa 1: Se resposta correta → progresso                │'),
    writeln('│ Premissa 2: Jogador progrediu ✓                            │'),
    writeln('│ Conclusão FALSA: Resposta estava correcta (?)              │'),
    writeln('├─────────────────────────────────────────────────────────────┤'),
    writeln('│ ⚠️  ERRO LÓGICO: O jogador pode ter progredido por sorte   │'),
    writeln('│     ou por outros factores, não necessariamente por saber  │'),
    writeln('│     a resposta correcta!                                   │'),
    writeln('└─────────────────────────────────────────────────────────────┘'),
    writeln('').

mostrar_demonstracao_logica :-
    writeln(''),
    writeln('═══════════════════════════════════════════════════════════════'),
    writeln('       DEMONSTRAÇÃO DAS REGRAS DE INFERÊNCIA LÓGICA'),
    writeln('═══════════════════════════════════════════════════════════════'),
    writeln(''),
    writeln('EXEMPLO - MODUS PONENS:'),
    writeln('1. Se o jogador acerta a pergunta, ele avança'),
    writeln('2. O jogador acertou a pergunta'),
    writeln('3. Logo, o jogador avança'),
    writeln('✓ Raciocínio VÁLIDO'),
    writeln(''),
    writeln('EXEMPLO - MODUS TOLLENS:'),
    writeln('1. Se o jogador acerta a pergunta, ele avança'),
    writeln('2. O jogador NÃO avançou'),
    writeln('3. Logo, o jogador NÃO acertou a pergunta'),
    writeln('✓ Raciocínio VÁLIDO'),
    writeln(''),
    writeln('═══════════════════════════════════════════════════════════════'),
    writeln('').

% ============================================================================
% MENSAGENS DE AJUDAS / FEEDBACK (mantidas)
% ============================================================================

mostrar_menu_opcoes :-
    writeln(''),
    writeln('O que deseja fazer?'),
    writeln('  [A/B/C/D] - Responder'),
    writeln('  [H] - Usar ajuda'),
    writeln('  [Q] - Desistir e levar o dinheiro'),
    write('Sua escolha: ').

mostrar_desistencia(Dinheiro) :-
    writeln(''),
    writeln('Você decidiu desistir!'),
    format('Você leva para casa €~w!~n', [Dinheiro]),
    writeln(''),
    writeln('Obrigado por jogar!'),
    writeln('').

mostrar_resposta_correta(ValorPergunta, NovoDinheiro) :-
    writeln(''),
    writeln('✅ RESPOSTA CORRETA! ✅'),
    format('Você ganhou €~w!~n', [ValorPergunta]),
    format('Total acumulado: €~w~n', [NovoDinheiro]).

mostrar_patamar_seguranca(Patamar) :-
    format('~n🎯 PATAMAR DE SEGURANÇA ALCANÇADO: €~w 🎯~n', [Patamar]).

mostrar_resposta_errada(RespostaCorreta, DinheiroFinal) :-
    writeln(''),
    writeln('❌ RESPOSTA ERRADA! ❌'),
    format('A resposta correcta era: ~w~n', [RespostaCorreta]),
    writeln(''),
    format('Você leva para casa €~w~n', [DinheiroFinal]),
    writeln(''),
    writeln('Obrigado por jogar!'),
    writeln('').

mostrar_escolha_invalida :-
    writeln(''),
    writeln('❌ Escolha inválida! Use A, B, C, D, H ou Q.'),
    writeln(''),
    write('Pressione ENTER para continuar...').

mostrar_sem_ajudas :-
    writeln(''),
    writeln('❌ Você não tem mais ajudas disponíveis!'),
    writeln(''),
    write('Pressione ENTER para continuar...').

mostrar_voltar_jogo :-
    writeln(''),
    writeln('Voltando ao jogo...').

mostrar_ajuda_invalida :-
    writeln(''),
    writeln('❌ Escolha inválida!').

% Cabeçalhos / mensagens das ajudas (mantidas)
mostrar_menu_escolha_ajuda :-
    writeln(''),
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                    ESCOLHA UMA AJUDA                          ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln('').

mostrar_cabecalho_50_50 :-
    writeln(''),
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                        50/50 ATIVADO                          ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln(''),
    writeln('Eliminando duas respostas incorretas...').

mostrar_resultado_50_50(L1, T1, L2, T2) :-
    writeln(''),
    writeln('Respostas eliminadas:'),
    format('  ✗ ~w: ~w~n', [L1, T1]),
    format('  ✗ ~w: ~w~n', [L2, T2]),
    writeln(''),
    writeln('Restam apenas duas opções!').

mostrar_cabecalho_publico :-
    writeln(''),
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                   AJUDA DO PÚBLICO                            ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln(''),
    writeln('Consultando o público...').

mostrar_resultado_publico(DistA, DistB, DistC, DistD) :-
    writeln(''),
    writeln('Resultado da votação:'),
    writeln(''),
    format('  A: ~w% ', [DistA]), mostrar_barra_percentual(DistA), nl,
    format('  B: ~w% ', [DistB]), mostrar_barra_percentual(DistB), nl,
    format('  C: ~w% ', [DistC]), mostrar_barra_percentual(DistC), nl,
    format('  D: ~w% ', [DistD]), mostrar_barra_percentual(DistD), nl,
    writeln('').

mostrar_cabecalho_telefone :-
    writeln(''),
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                      TELEFONE                                 ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln(''),
    writeln('Ligando para um amigo...').

mostrar_resposta_amigo_confiante(Resposta, Confianca) :-
    writeln(''),
    write('Amigo: Alô? '), writeln(''),
    format('Amigo: Acho que é a opção ~w, tenho ~w% de certeza.~n', [Resposta, Confianca]),
    writeln(''),
    writeln('A ligação foi encerrada.').

mostrar_resposta_amigo_incerto(Sugestao) :-
    writeln(''),
    write('Amigo: Alô? '), writeln(''),
    format('Amigo: Hmm... acho que é a opção ~w, mas não tenho muita certeza...~n', [Sugestao]),
    writeln(''),
    writeln('A ligação foi encerrada.').
