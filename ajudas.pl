% ============================================================================
% SISTEMA DE AJUDAS
% ============================================================================

% Menu de ajudas
usar_ajuda(AjudasDisponiveis, NovasAjudas, Texto, Opcoes, RespostaCorreta) :-
    limpar_tela,
    mostrar_menu_escolha_ajuda,
    mostrar_menu_ajudas(AjudasDisponiveis, 1),
    writeln('  [0] - Voltar'),
    writeln(''),
    write('Sua escolha: '),
    read_line_to_string(user_input, Input),
    atom_string(Escolha, Input),
    processar_escolha_ajuda(Escolha, AjudasDisponiveis, NovasAjudas, 
                            Texto, Opcoes, RespostaCorreta).

% Mostra menu de ajudas disponíveis
mostrar_menu_ajudas([], _).
mostrar_menu_ajudas([ajuda_50_50|Resto], N) :-
    format('  [~w] - 50/50 (Elimina duas respostas incorretas)~n', [N]),
    N1 is N + 1,
    mostrar_menu_ajudas(Resto, N1).
mostrar_menu_ajudas([ajuda_publico|Resto], N) :-
    format('  [~w] - Ajuda do Público (Mostra distribuição percentual)~n', [N]),
    N1 is N + 1,
    mostrar_menu_ajudas(Resto, N1).
mostrar_menu_ajudas([telefone|Resto], N) :-
    format('  [~w] - Telefone (Consulta um amigo)~n', [N]),
    N1 is N + 1,
    mostrar_menu_ajudas(Resto, N1).

% Processamento da escolha de ajuda
processar_escolha_ajuda('0', Ajudas, Ajudas, _, _, _) :-
    !,
    mostrar_voltar_jogo,
    sleep(1).

processar_escolha_ajuda('1', Ajudas, NovasAjudas, _, Opcoes, RespostaCorreta) :-
    member(ajuda_50_50, Ajudas),
    !,
    select(ajuda_50_50, Ajudas, NovasAjudas),
    aplicar_50_50(Opcoes, RespostaCorreta),
    writeln(''),
    write('Pressione ENTER para continuar...'),
    read_line_to_string(user_input, _).

processar_escolha_ajuda('2', Ajudas, NovasAjudas, _, _, RespostaCorreta) :-
    member(ajuda_publico, Ajudas),
    !,
    select(ajuda_publico, Ajudas, NovasAjudas),
    aplicar_ajuda_publico(RespostaCorreta),
    writeln(''),
    write('Pressione ENTER para continuar...'),
    read_line_to_string(user_input, _).

processar_escolha_ajuda('3', Ajudas, NovasAjudas, _, _, RespostaCorreta) :-
    member(telefone, Ajudas),
    !,
    select(telefone, Ajudas, NovasAjudas),
    aplicar_telefone(RespostaCorreta),
    writeln(''),
    write('Pressione ENTER para continuar...'),
    read_line_to_string(user_input, _).

processar_escolha_ajuda(_, Ajudas, Ajudas, _, _, _) :-
    mostrar_ajuda_invalida,
    sleep(1).

% AJUDA 1: 50/50
aplicar_50_50([OpA, OpB, OpC, OpD], RespostaCorreta) :-
    mostrar_cabecalho_50_50,
    sleep(1),
    
    Opcoes = [
        opcao('A', OpA),
        opcao('B', OpB),
        opcao('C', OpC),
        opcao('D', OpD)
    ],
    
    findall(
        opcao(Letra, Texto),
        (member(opcao(Letra, Texto), Opcoes), Letra \= RespostaCorreta),
        Incorretas
    ),
    
    random_permutation(Incorretas, [Elim1, Elim2|_]),
    
    Elim1 = opcao(L1, T1),
    Elim2 = opcao(L2, T2),
    mostrar_resultado_50_50(L1, T1, L2, T2).

% AJUDA 2: AJUDA DO PÚBLICO
aplicar_ajuda_publico(RespostaCorreta) :-
    mostrar_cabecalho_publico,
    sleep(1),
    
    gerar_distribuicao_publico(RespostaCorreta, DistA, DistB, DistC, DistD),
    
    mostrar_resultado_publico(DistA, DistB, DistC, DistD).

% Gera distribuição percentual com viés para resposta correta
gerar_distribuicao_publico(RespostaCorreta, DistA, DistB, DistC, DistD) :-
    random(45, 76, PctCorreta),
    Resto is 100 - PctCorreta,
    random(0, Resto, Pct1),
    Resto2 is Resto - Pct1,
    random(0, Resto2, Pct2),
    Pct3 is Resto2 - Pct2,
    
    (   RespostaCorreta = 'A' ->
        DistA = PctCorreta, DistB = Pct1, DistC = Pct2, DistD = Pct3
    ;   RespostaCorreta = 'B' ->
        DistA = Pct1, DistB = PctCorreta, DistC = Pct2, DistD = Pct3
    ;   RespostaCorreta = 'C' ->
        DistA = Pct1, DistB = Pct2, DistC = PctCorreta, DistD = Pct3
    ;   DistA = Pct1, DistB = Pct2, DistC = Pct3, DistD = PctCorreta
    ).

% AJUDA 3: TELEFONE
aplicar_telefone(RespostaCorreta) :-
    mostrar_cabecalho_telefone,
    sleep(1),
    
    random(70, 96, Confianca),
    random(1, 101, Sorte),
    
    (   Sorte =< Confianca ->
        mostrar_resposta_amigo_confiante(RespostaCorreta, Confianca)
    ;   select(RespostaCorreta, ['A', 'B', 'C', 'D'], Erradas),
        random_member(Sugestao, Erradas),
        mostrar_resposta_amigo_incerto(Sugestao)
    ).
