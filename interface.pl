% ============================================================================
% INTERFACE - ASCII Art e Formatação Visual
% ============================================================================

% Importação de modulos
:- consult('sound_effect.pl').

% Limpeza de tela
limpar_tela :-
    write('\033[2J'),  % Limpa a tela
    write('\033[H').   % Move cursor para o topo

% Logo do jogo
mostrar_logo :-
    writeln(''),
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                                                               ║'),
    writeln('║         ██████  ██    ██ ███████ ███    ███                   ║'),
    writeln('║        ██    ██ ██    ██ ██      ████  ████                   ║'),
    writeln('║        ██    ██ ██    ██ █████   ██ ████ ██                   ║'),
    writeln('║        ██ ▄▄ ██ ██    ██ ██      ██  ██  ██                   ║'),
    writeln('║         ██████   ██████  ███████ ██      ██                   ║'),
    writeln('║            ▀▀                                                 ║'),
    writeln('║                                                               ║'),
    writeln('║           QUER SER MILIONÁRIO?                                ║'),
    writeln('║           ★ ★ ★ ★ ★ ★ ★ ★ ★ ★                                 ║'),
    writeln('║                                                               ║'),
    writeln('║                                                               ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln(''),
    tocar_som_main_menu.

% Logo do jogo - Versão Futebol
mostrar_logo_futebol :-
    writeln(''),
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                                                               ║'),
    writeln('║         ██████  ██    ██ ███████ ███    ███                   ║'),
    writeln('║        ██    ██ ██    ██ ██      ████  ████                   ║'),
    writeln('║        ██    ██ ██    ██ █████   ██ ████ ██                   ║'),
    writeln('║        ██ ▄▄ ██ ██    ██ ██      ██  ██  ██                   ║'),
    writeln('║         ██████   ██████  ███████ ██      ██                   ║'),
    writeln('║            ▀▀                                                 ║'),
    writeln('║                                                               ║'),
    writeln('║           QUER SER MILIONÁRIO?                                ║'),
    writeln('║           ★ ★ ★ ★ ★ ★ ★ ★ ★ ★                                 ║'),
    writeln('║                                                               ║'),
    writeln('║                    V E R S Ã O   F U T E B O L   ⚽           ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln(''),
    tocar_som_main_menu.

% Logo do jogo - Versão Cultura Portuguesa
mostrar_logo_cultura_portuguesa :-
    writeln(''),
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                                                               ║'),
    writeln('║         ██████  ██    ██ ███████ ███    ███                   ║'),
    writeln('║        ██    ██ ██    ██ ██      ████  ████                   ║'),
    writeln('║        ██    ██ ██    ██ █████   ██ ████ ██                   ║'),
    writeln('║        ██ ▄▄ ██ ██    ██ ██      ██  ██  ██                   ║'),
    writeln('║         ██████   ██████  ███████ ██      ██                   ║'),
    writeln('║            ▀▀                                                 ║'),
    writeln('║                                                               ║'),
    writeln('║           QUER SER MILIONÁRIO?                                ║'),
    writeln('║           ★ ★ ★ ★ ★ ★ ★ ★ ★ ★                                 ║'),
    writeln('║                                                               ║'),
    writeln('║       V E R S Ã O   C U L T U R A   P O R T U G U E S A 🇵🇹    ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln(''),
    tocar_som_main_menu.

% Cabeçalho do jogo
mostrar_cabecalho(Nivel, Dinheiro, Ajudas, NivelDificuldade) :-
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    format('║  Pergunta: ~w/20  |  Dificuldade: ~w  |  Dinheiro: €~w~*|~n', 
           [Nivel, NivelDificuldade, Dinheiro, 10]),
    writeln('╠═══════════════════════════════════════════════════════════════╣'),
    write('║  Ajudas disponíveis: '),
    mostrar_ajudas(Ajudas),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln('').

% Mostra ajudas disponíveis
mostrar_ajudas([]) :- 
    writeln('Nenhuma                              ║').
mostrar_ajudas(Ajudas) :-
    Ajudas \= [],
    (member(ajuda_50_50, Ajudas) -> write('[50/50] ') ; true),
    (member(ajuda_publico, Ajudas) -> write('[Público] ') ; true),
    (member(telefone, Ajudas) -> write('[Telefone] ') ; true),
    writeln('      ║').

% Exibição de pergunta
mostrar_pergunta(Texto, [OpA, OpB, OpC, OpD]) :-
    writeln('┌───────────────────────────────────────────────────────────────┐'),
    format('│ ~w~*|~n', [Texto, 62]),
    writeln('└───────────────────────────────────────────────────────────────┘'),
    writeln(''),
    format('  A: ~w~n', [OpA]),
    format('  B: ~w~n', [OpB]),
    format('  C: ~w~n', [OpC]),
    format('  D: ~w~n', [OpD]).

% Tela de vitória
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
    writeln(''),
    tocar_som_vitoria.

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
% MENSAGENS DE LÓGICA DE INFERÊNCIA
% ============================================================================

% Mensagem Modus Ponens
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

% Mensagem Modus Tollens
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

% Mensagem Modus Mistaken
mostrar_modus_mistaken :-
    writeln(''),
    writeln('┌─────────────────────────────────────────────────────────────┐'),
    writeln('│ ⚠️  MODUS MISTAKEN (Falácia Lógica - INVÁLIDO!)            │'),
    writeln('├─────────────────────────────────────────────────────────────┤'),
    writeln('│ Premissa 1: Se resposta correta → progresso                │'),
    writeln('│ Premissa 2: Jogador progrediu ✓                            │'),
    writeln('│ Conclusão FALSA: Resposta estava correta (?)               │'),
    writeln('├─────────────────────────────────────────────────────────────┤'),
    writeln('│ ⚠️  ERRO LÓGICO: O jogador pode ter progredido usando      │'),
    writeln('│     ajudas ou por sorte, não necessariamente por saber     │'),
    writeln('│     a resposta correta!                                     │'),
    writeln('└─────────────────────────────────────────────────────────────┘'),
    writeln('').

% Demonstração de lógica
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
    writeln('EXEMPLO - MODUS MISTAKEN (FALÁCIA):'),
    writeln('1. Se o jogador acerta a pergunta, ele avança'),
    writeln('2. O jogador avançou'),
    writeln('3. Logo, o jogador acertou a pergunta'),
    writeln('✗ Raciocínio INVÁLIDO (pode ter usado ajuda!)'),
    writeln(''),
    writeln('═══════════════════════════════════════════════════════════════'),
    writeln('').

% ============================================================================
% MENSAGENS DO SISTEMA DE AJUDAS
% ============================================================================

% Menu de escolha de ajuda
mostrar_menu_escolha_ajuda :-
    writeln(''),
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                    ESCOLHA UMA AJUDA                          ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln('').

% Cabeçalho 50/50
mostrar_cabecalho_50_50 :-
    writeln(''),
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                        50/50 ATIVADO                          ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln(''),
    writeln('A eliminar duas respostas incorretas...').

% Resultado 50/50
mostrar_resultado_50_50(L1, T1, L2, T2) :-
    writeln(''),
    writeln('Respostas eliminadas:'),
    format('  ✗ ~w: ~w~n', [L1, T1]),
    format('  ✗ ~w: ~w~n', [L2, T2]),
    writeln(''),
    writeln('Restam apenas duas opções!').

% Cabeçalho Ajuda do Público
mostrar_cabecalho_publico :-
    writeln(''),
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                   AJUDA DO PÚBLICO                            ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln(''),
    writeln('A consultar o público...').

% Resultado Ajuda do Público
mostrar_resultado_publico(DistA, DistB, DistC, DistD) :-
    writeln(''),
    writeln('Resultado da votação:'),
    writeln(''),
    format('  A: ~w% ', [DistA]), mostrar_barra_percentual(DistA), nl,
    format('  B: ~w% ', [DistB]), mostrar_barra_percentual(DistB), nl,
    format('  C: ~w% ', [DistC]), mostrar_barra_percentual(DistC), nl,
    format('  D: ~w% ', [DistD]), mostrar_barra_percentual(DistD), nl,
    writeln('').

% Cabeçalho Telefone
mostrar_cabecalho_telefone :-
    writeln(''),
    writeln('╔═══════════════════════════════════════════════════════════════╗'),
    writeln('║                      TELEFONE                                 ║'),
    writeln('╚═══════════════════════════════════════════════════════════════╝'),
    writeln(''),
    writeln('A ligar para um amigo...').

% Resposta do amigo (confiante)
mostrar_resposta_amigo_confiante(Resposta, Confianca) :-
    writeln(''),
    write('Amigo: Alô? '),
    writeln(''),
    format('Amigo: Acho que é a opção ~w, tenho ~w% de certeza.~n', [Resposta, Confianca]),
    writeln(''),
    writeln('A ligação foi encerrada.').

% Resposta do amigo (incerto)
mostrar_resposta_amigo_incerto(Sugestao) :-
    writeln(''),
    write('Amigo: Alô? '),
    writeln(''),
    format('Amigo: Hmm... acho que é a opção ~w, mas não tenho muita certeza...~n', [Sugestao]),
    writeln(''),
    writeln('A ligação foi encerrada.').

% ============================================================================
% MENSAGENS DE FEEDBACK DO JOGO
% ============================================================================

% Mensagem de boas-vindas
mostrar_boas_vindas :-
    writeln(''),
    writeln('Bem-vindo ao QUEM QUER SER MILIONÁRIO!'),
    writeln(''),
    writeln('Responda a 20 perguntas e ganhe até €1.000.000!'),
    writeln('Você tem 3 ajudas: 50/50, Ajuda do Público e Telefone.'),
    writeln(''),
    write('Pressione ENTER para começar...').

% Menu de opções do jogo
mostrar_menu_opcoes :-
    writeln(''),
    writeln('O que deseja fazer?'),
    writeln('  [A/B/C/D] - Responder'),
    writeln('  [H] - Usar ajuda'),
    writeln('  [Q] - Desistir e levar o dinheiro'),
    write('Sua escolha: ').

% Mensagem de desistência
mostrar_desistencia(Dinheiro) :-
    writeln(''),
    writeln('Você decidiu desistir!'),
    format('Você leva para casa €~w!~n', [Dinheiro]),
    writeln(''),
    writeln('Obrigado por jogar!'),
    writeln('').

% Mensagem de resposta correta
mostrar_resposta_correta(ValorPergunta, NovoDinheiro) :-
    writeln(''),
    writeln('✅ RESPOSTA CORRETA! ✅'),
    format('Você ganhou €~w!~n', [ValorPergunta]),
    format('Total acumulado: €~w~n', [NovoDinheiro]).

% Mensagem de patamar de segurança
mostrar_patamar_seguranca(Patamar) :-
    format('~n🎯 PATAMAR DE SEGURANÇA ALCANÇADO: €~w 🎯~n', [Patamar]).

% Mensagem de resposta errada
mostrar_resposta_errada(RespostaCorreta, DinheiroFinal) :-
    writeln(''),
    writeln('❌ RESPOSTA ERRADA! ❌'),
    format('A resposta correta era: ~w~n', [RespostaCorreta]),
    writeln(''),
    format('Você leva para casa €~w~n', [DinheiroFinal]),
    writeln(''),
    writeln('Obrigado por jogar!'),
    writeln('').

% Mensagem de escolha inválida
mostrar_escolha_invalida :-
    writeln(''),
    writeln('❌ Escolha inválida! Use A, B, C, D, H ou Q.'),
    writeln(''),
    write('Pressione ENTER para continuar...').

% Mensagem de sem ajudas
mostrar_sem_ajudas :-
    writeln(''),
    writeln('❌ Você não tem mais ajudas disponíveis!'),
    writeln(''),
    write('Pressione ENTER para continuar...').

% Mensagem de voltar ao jogo
mostrar_voltar_jogo :-
    writeln(''),
    writeln('A voltar ao jogo...').

% Mensagem de escolha de ajuda inválida
mostrar_ajuda_invalida :-
    writeln(''),
    writeln('❌ Escolha inválida!').
