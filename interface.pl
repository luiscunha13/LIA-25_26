% ============================
% INTERFACE.PL
% ============================
:- use_module(ascii_logo).  % se estiver na mesma pasta




:- use_module(library(random)).

% ============================
% STARFIELD (estrelas a piscar nas margens)
% ============================

cursor_pos(Row, Col) :-
    format('\033[~d;~dH', [Row, Col]).

ansi_fg_dim    :- write('\033[90m').
ansi_fg_bright :- write('\033[97m').
ansi_bg_black  :- write('\033[40m').
ansi_fg_reset_only :- write('\033[39m').
ansi_fg_yellow :- write('\033[33m').     % amarelo “normal”
ansi_fg_yellow_bright :- write('\033[93m'). % amarelo brilhante (se o terminal suportar)


draw_star(R, C, bright) :-
    cursor_pos(R, C),
    ansi_bg_black,
    ansi_fg_bright,
    write('✦'),
    ansi_fg_reset_only.

draw_star(R, C, dim) :-
    cursor_pos(R, C),
    ansi_bg_black,
    ansi_fg_dim,
    write('·'),
    ansi_fg_reset_only.

draw_star(R, C, off) :-
    cursor_pos(R, C),
    ansi_bg_black,
    write(' '),
    ansi_fg_reset_only.

draw_star(R, C, yellow) :-
    cursor_pos(R, C),
    ansi_bg_black,
    ansi_fg_yellow_bright,   % ou ansi_fg_yellow
    write('✦'),
    ansi_fg_reset_only.


% zona proibida (centro)
in_center_zone(C, Cols, CenterPad) :-
    CenterStart is (Cols // 2) - CenterPad,
    CenterEnd   is (Cols // 2) + CenterPad,
    C >= CenterStart,
    C =< CenterEnd.

% helper: random_between seguro (não rebenta se Min>Max)
safe_random_between(Min, Max, V) :-
    (  Min =< Max
    -> random_between(Min, Max, V)
    ;  V = Min
    ).

% gera N posições de estrelas só nas margens
make_star_positions(N, Cols, Rows, MarginW0, CenterPad0, Positions) :-
    % --- ajustes para não rebentar em terminais pequenos ---
    MarginW is min(MarginW0, max(2, Cols // 4)),
    CenterPad is min(CenterPad0, max(8, (Cols // 2) - MarginW - 2)),

    RMin is 2,
    RMax0 is Rows - 1,
    RMax is max(RMin, RMax0),

    LMin is 2,
    LMax0 is MarginW,
    LMax is max(LMin, LMax0),

    RightStart0 is Cols - MarginW,
    RightStart is max(2, RightStart0),

    CMax0 is Cols - 1,
    CMax is max(2, CMax0),

    findall(pos(R,C),
        ( between(1, N, _),

          safe_random_between(RMin, RMax, R),

          random_between(0, 1, Side),
          ( Side =:= 0 ->
              safe_random_between(LMin, LMax, C)
          ;   safe_random_between(RightStart, CMax, C)
          ),

          \+ in_center_zone(C, Cols, CenterPad)
        ),
        Positions).

% piscar
render_starfield(Positions, Cols, _Rows, CenterPad, BlinkPct) :-
    forall(member(pos(R,C), Positions),
        (   ( in_center_zone(C, Cols, CenterPad) ->
                true
            ;   random_between(1, 100, X),
                ( X =< BlinkPct ->
                    random_between(1, 4, S),
                    ( S =:= 1 -> draw_star(R,C,off)
                    ; S =:= 2 -> draw_star(R,C,dim)
                    ; S =:= 3 -> draw_star(R,C,bright)
                    ;           draw_star(R,C,yellow)
                    )

                ; true )
            )
        )),
    cursor_pos(1,1),
    flush_output.

% corre starfield por DurationSecs
starfield_run(_DurationSecs) :-
    terminal_cols_rows(Cols, Rows),

    % se o terminal for minúsculo, não faz nada (evita bugs)
    ( Cols < 40 ; Rows < 10 ),
    !,
    true.

starfield_run(DurationSecs) :-
    terminal_cols_rows(Cols, Rows),
    MarginW = 35,
    CenterPad = 20,
    NStars is max(60, Rows * 5),
    make_star_positions(NStars, Cols, Rows, MarginW, CenterPad, Positions),

    FPS is 14,
    FrameDelay is 1.0 / FPS,
    Frames is max(1, round(DurationSecs * FPS)),

    forall(between(1, Frames, _),
        ( render_starfield(Positions, Cols, Rows, CenterPad, 80),
          sleep(FrameDelay)
        )).



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

% ============================
% Centralização de blocos (H + V)
% ============================

max_line_len_strs(Lines, Max) :-
    maplist(string_length, Lines, Lens),
    max_list(Lens, Max).

pad_left_spaces(Spaces, Line, Out) :-
    ( Spaces =< 0 ->
        Out = Line
    ;   length(Cs, Spaces),
        maplist(=(' '), Cs),
        string_chars(Prefix, Cs),
        string_concat(Prefix, Line, Out)
    ).

print_centered_block(Lines) :-
    terminal_cols_rows(Cols, Rows),
    length(Lines, H),
    max_line_len_strs(Lines, W),

    Left is max(0, (Cols - W) // 2),
    % Top  is max(0, (Rows - H) // 2),

    BaseTop is max(0, (Rows - H) // 2),
    Top is max(0, BaseTop - 17),


    % espaço em cima (centro vertical)
    forall(between(1, Top, _), nl),

    % imprime centrado (horizontal)
    forall(member(L, Lines),
           ( pad_left_spaces(Left, L, L2),
             writeln(L2)
           )).

print_centered_block_h(Lines) :-
    terminal_cols_rows(Cols, _Rows),
    max_line_len_strs(Lines, W),
    Left is max(0, (Cols - W) // 2),
    forall(member(L, Lines),
           ( pad_left_spaces(Left, L, L2),
             writeln(L2)
           )).


mostrar_menu_tema_abaixo :-
    menu_tema_block(Lines),
    nl, nl,
    limpar_ate_fim,                 % corrige o fundo
    shimmer_fg_white,                    % <-- cinza (igual ao look do shimmer)
    print_centered_block_h(Lines),
    write('\033[37m'),              % <-- volta ao branco normal do UI
    nl,
    write('Escolha uma opção: ').


% ============================
% SHIMMER (texto ASCII em branco com brilho a passar)
% ============================

shimmer_fg_white   :- write('\033[37m').
shimmer_reset      :- write('\033[0m').

% imprime uma linha com shimmer: a zona [K..K+W] fica em bright
print_line_shimmer(Line, K, W) :-
    string_chars(Line, Chars),
    print_chars_shimmer(Chars, 1, K, W),
    nl.

% print_chars_shimmer([], _I, _K, _W).
% print_chars_shimmer([Ch|Rest], I, K, W) :-
%     ( I >= K, I =< K+W ->
%         ansi_fg_bright
%     ;   ansi_fg_white
%     ),
%     write(Ch),
%     I1 is I + 1,
%     print_chars_shimmer(Rest, I1, K, W1),
%     % W1 = W só para evitar warning de singleton em alguns set-ups
%     W1 = W,
%     print_chars_shimmer(Rest, I1, K, W).



print_chars_shimmer([], _I, _K, _W).
print_chars_shimmer([Ch|Rest], I, K, W) :-
    ( I >= K, I =< K+W ->
        ansi_fg_bright
    ;   shimmer_fg_white
    ),
    write(Ch),
    I1 is I + 1,
    print_chars_shimmer(Rest, I1, K, W).





% limpa do cursor até ao fim e garante fundo preto
limpar_ate_fim :-
    ansi_bg_black,          % \033[40m
    write('\033[J'),        % clear screen from cursor to end
    flush_output.









% imprime um bloco centrado MAS com shimmer só nas N primeiras linhas (o Title)
print_centered_block_shimmer(Lines, TitleN, Frames, BeamW, Delay) :-
    terminal_cols_rows(Cols, Rows),
    length(Lines, H),
    max_line_len_strs(Lines, Wmax),

    Left is max(0, (Cols - Wmax) // 2),
    BaseTop is max(0, (Rows - H) // 2),
    Top is max(0, BaseTop - 17),

    % largura “virtual” do shimmer (considera o padding à esquerda)
    TotalW is Left + Wmax,

    forall(between(1, Frames, F),
      (
        % redesenha tudo
        cursor_pos(1,1),

        % espaço em cima
        forall(between(1, Top, _), nl),

        % posição do feixe (vai da esquerda até ao fim)
        K is 1 + ((F-1) mod max(1, TotalW)),

        % imprime linhas
        print_lines_shimmer(Lines, Left, 1, TitleN, K, BeamW),

        flush_output,
        sleep(Delay)
      )),
    shimmer_reset.

print_lines_shimmer([], _Left, _Idx, _TitleN, _K, _BeamW).
print_lines_shimmer([L|Ls], Left, Idx, TitleN, K, BeamW) :-
    pad_left_spaces(Left, L, L2),
    ( Idx =< TitleN ->
        print_line_shimmer(L2, K, BeamW)
    ;   writeln(L2)
    ),
    Idx1 is Idx + 1,
    print_lines_shimmer(Ls, Left, Idx1, TitleN, K, BeamW).




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
    menu_principal_block(Lines),
    print_centered_block(Lines),
    nl,
    write('Escolha uma opção: ').

menu_principal_block(Lines) :-
    Title = [
        "███╗   ███╗███████╗███╗   ██╗██╗   ██╗",
        "████╗ ████║██╔════╝████╗  ██║██║   ██║",
        "██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║",
        "██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║",
        "██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝",
        "╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ ",
        "██████╗ ██████╗ ██╗███╗   ██╗ ██████╗██╗██████╗  █████╗ ██╗     ",
        "██╔══██╗██╔══██╗██║████╗  ██║██╔════╝██║██╔══██╗██╔══██╗██║     ",
        "██████╔╝██████╔╝██║██╔██╗ ██║██║     ██║██████╔╝███████║██║     ",
        "██╔═══╝ ██╔══██╗██║██║╚██╗██║██║     ██║██╔═══╝ ██╔══██║██║     ",
        "██║     ██║  ██║██║██║ ╚████║╚██████╗██║██║     ██║  ██║███████╗",
        "╚═╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝"
    ],

    Box = [
        "╔════════════════════════════════════════════════════════════════╗",
        "║  [1] Novo Jogo                                                 ║",
        "║  [2] Ranking                                                   ║",
        "║  [3] Regras / Info                                             ║",
        "║  [4] Sair                                                      ║",
        "╚════════════════════════════════════════════════════════════════╝"
    ],

    append(Title, [""], T1),
    append(T1, Box, Lines).

mostrar_menu_modo :-
    menu_modo_block(Lines),
    % Title tem 12 linhas no teu menu_modo_block
    print_centered_block_shimmer(Lines, 12, 18, 8, 0.05),
    nl,
    write('Escolha uma opção: ').

menu_modo_block(Lines) :-
    Title = [
        "███████╗███████╗██╗     ███████╗ ██████╗██╗ ██████╗ ███╗   ██╗███████╗",
        "██╔════╝██╔════╝██║     ██╔════╝██╔════╝██║██╔═══██╗████╗  ██║██╔════╝",
        "███████╗█████╗  ██║     █████╗  ██║     ██║██║   ██║██╔██╗ ██║█████╗  ",
        "╚════██║██╔══╝  ██║     ██╔══╝  ██║     ██║██║   ██║██║╚██╗██║██╔══╝  ",
        "███████║███████╗███████╗███████╗╚██████╗██║╚██████╔╝██║ ╚████║███████╗",
        "╚══════╝╚══════╝╚══════╝╚══════╝ ╚═════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝",
        "███╗   ███╗ ██████╗ ██████╗  ██████╗ ",
        "████╗ ████║██╔═══██╗██╔══██╗██╔═══██╗",
        "██╔████╔██║██║   ██║██║  ██║██║   ██║",
        "██║╚██╔╝██║██║   ██║██║  ██║██║   ██║",
        "██║ ╚═╝ ██║╚██████╔╝██████╔╝╚██████╔╝",
        "╚═╝     ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝ "
    ],
    Box = [
        "╔════════════════════════════════════════════════════════════════╗",
        "║  [1] Treino                                                    ║",
        "║  [2] Rápido                                                    ║",
        "║  [3] Competitivo                                               ║",
        "╚════════════════════════════════════════════════════════════════╝"
    ],
    append(Title, [""], T1),
    append(T1, Box, Lines).

mostrar_menu_tema :-
    menu_tema_block(Lines),
    % Title tem 12 linhas também
    print_centered_block_shimmer(Lines, 12, 18, 8, 0.05),
    nl,
    write('Escolha uma opção: ').


menu_tema_block(Lines) :-
    Title = [
        "███████╗███████╗██╗     ███████╗ ██████╗██╗ ██████╗ ███╗   ██╗███████╗",
        "██╔════╝██╔════╝██║     ██╔════╝██╔════╝██║██╔═══██╗████╗  ██║██╔════╝",
        "███████╗█████╗  ██║     █████╗  ██║     ██║██║   ██║██╔██╗ ██║█████╗  ",
        "╚════██║██╔══╝  ██║     ██╔══╝  ██║     ██║██║   ██║██║╚██╗██║██╔══╝  ",
        "███████║███████╗███████╗███████╗╚██████╗██║╚██████╔╝██║ ╚████║███████╗",
        "╚══════╝╚══════╝╚══════╝╚══════╝ ╚═════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝",
        "████████╗███████╗███╗   ███╗ █████╗ ",
        "╚══██╔══╝██╔════╝████╗ ████║██╔══██╗",
        "   ██║   █████╗  ██╔████╔██║███████║",
        "   ██║   ██╔══╝  ██║╚██╔╝██║██╔══██║",
        "   ██║   ███████╗██║ ╚═╝ ██║██║  ██║",
        "   ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝"
    ],
    Box = [
        "╔════════════════════════════════════════════════════════════════╗",
        "║  [1] Cultura Geral                                             ║",
        "║  [2] Futebol                                                   ║",
        "║  [3] Cultura Portuguesa                                        ║",
        "╚════════════════════════════════════════════════════════════════╝"
    ],
    append(Title, [""], T1),
    append(T1, Box, Lines).

% ============================================================================
% Cabeçalho do jogo (agora mostra pergunta / MaxNivel)
% ============================================================================

% mostrar_cabecalho(Nivel, Dinheiro, Ajudas, NivelDificuldade, MaxNivel) :-
%     writeln('╔═══════════════════════════════════════════════════════════════╗'),
%     format('║  Pergunta: ~w/~w | Dificuldade: ~w | Dinheiro: €~w~*|~n',
%            [Nivel, MaxNivel, NivelDificuldade, Dinheiro, 10]),
%     writeln('╠═══════════════════════════════════════════════════════════════╣'),
%     write('║  Ajudas disponíveis: '),
%     mostrar_ajudas(Ajudas),
%     writeln('╚═══════════════════════════════════════════════════════════════╝'),
%     writeln('').

mostrar_ajudas([]) :-
    writeln('Nenhuma                              ║').
mostrar_ajudas(Ajudas) :-
    Ajudas \= [],
    (member(ajuda_50_50, Ajudas) -> write('[50/50] ') ; true),
    (member(ajuda_publico, Ajudas) -> write('[Público] ') ; true),
    (member(telefone, Ajudas) -> write('[Telefone] ') ; true),
    writeln('      ║').

% mostrar_pergunta(Texto, [OpA, OpB, OpC, OpD]) :-
%     writeln('┌───────────────────────────────────────────────────────────────┐'),
%     format('│ ~w~*|~n', [Texto, 62]),
%     writeln('└───────────────────────────────────────────────────────────────┘'),
%     writeln(''),
%     format('  A: ~w~n', [OpA]),
%     format('  B: ~w~n', [OpB]),
%     format('  C: ~w~n', [OpC]),
%     format('  D: ~w~n', [OpD]).

% ============================
% UI do jogo (ASCII + centrado)
% ============================

mostrar_cabecalho(Nivel, Dinheiro, Ajudas, NivelDificuldade, MaxNivel) :-
    cabecalho_block(Nivel, Dinheiro, Ajudas, NivelDificuldade, MaxNivel, Lines),
    print_centered_block(Lines),
    nl.

cabecalho_block(Nivel, Dinheiro, Ajudas, NivelDificuldade, MaxNivel, Lines) :-
    % Título pequeno em ASCII (podes trocar se quiseres)
    % Title = [
    % "██╗███╗   ██╗███████╗ ██████╗ ",
    % "██║████╗  ██║██╔════╝██╔═══██╗",
    % "██║██╔██╗ ██║█████╗  ██║   ██║",
    % "██║██║╚██╗██║██╔══╝  ██║   ██║",
    % "██║██║ ╚████║██║     ╚██████╔╝",
    % "╚═╝╚═╝  ╚═══╝╚═╝      ╚═════╝ "
    % ],

    Title = [
    "██╗███╗   ██╗███████╗ ██████╗ ██████╗ ███╗   ███╗ █████╗  ██████╗ █████╗  ██████╗ ",
    "██║████╗  ██║██╔════╝██╔═══██╗██╔══██╗████╗ ████║██╔══██╗██╔════╝██╔══██╗██╔═══██╗",
    "██║██╔██╗ ██║█████╗  ██║   ██║██████╔╝██╔████╔██║███████║██║     ███████║██║   ██║",
    "██║██║╚██╗██║██╔══╝  ██║   ██║██╔══██╗██║╚██╔╝██║██╔══██║██║     ██╔══██║██║   ██║",
    "██║██║ ╚████║██║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║██║  ██║╚██████╗██║  ██║╚██████╔╝",
    "╚═╝╚═╝  ╚═══╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ "
],




    format(string(Line1),
           "║  Pergunta: ~w/~w | Dificuldade: ~w | Dinheiro: €~w",
           [Nivel, MaxNivel, NivelDificuldade, Dinheiro]),

    ajudas_string(Ajudas, AStr),
    format(string(Line2),
           "║  Ajudas disponíveis: ~w",
           [AStr]),

    Box = [
        "╔════════════════════════════════════════════════════════════════╗",
        Line1,
        "╠════════════════════════════════════════════════════════════════╣",
        Line2,
        "╚════════════════════════════════════════════════════════════════╝"
    ],

    pad_box_lines(Box, PaddedBox),
    append(Title, [""], T1),
    append(T1, PaddedBox, Lines).

ajudas_string([], "Nenhuma") :- !.
ajudas_string(Ajudas, S) :-
    ( member(ajuda_50_50, Ajudas) -> P1 = "[50/50]"   ; P1 = "" ),
    ( member(ajuda_publico, Ajudas) -> P2 = " [Público]" ; P2 = "" ),
    ( member(telefone, Ajudas) -> P3 = " [Telefone]" ; P3 = "" ),
    atomic_list_concat([P1,P2,P3], "", S0),
    normalize_space(string(S), S0).




% Garante que todas as linhas do "box" têm a mesma largura (80 chars aprox).
% Se uma linha não tiver o '║ ... ║' completo, corrige.
pad_box_lines([], []).
pad_box_lines([L|Ls], [O|Os]) :-
    ( sub_string(L, 0, 1, _, "╔")
    ; sub_string(L, 0, 1, _, "╚")
    ; sub_string(L, 0, 1, _, "╠")
    ),
    !,
    O = L,
    pad_box_lines(Ls, Os).
pad_box_lines([L|Ls], [O|Os]) :-
    % Linha de conteúdo "║ ...": fecha e preenche até 64 interior
    % (a largura total do box acima é 66: ║ + 64 + ║)
    ( sub_string(L, 0, 1, _, "║") ->
        % remove "║  " inicial se existir, e volta a montar
        ( sub_string(L, 0, _, _, "║") ->
            % tira o primeiro "║" e possíveis espaços
            sub_string(L, 1, _, 0, Rest0),
            normalize_space(string(Rest1), Rest0),
            % garante que não fica com "║" final duplicado
            ( sub_string(Rest1, _, 1, 0, "║") ->
                sub_string(Rest1, 0, _, 1, Rest2)
            ;   Rest2 = Rest1
            ),
            string_length(Rest2, Len),
            InnerW = 64,
            Pad is max(0, InnerW - Len),
            length(Cs, Pad), maplist(=(' '), Cs),
            string_chars(PadStr, Cs),
            string_concat(Rest2, PadStr, Mid),
            format(string(O), "║~w║", [Mid])
        ; O = L )
    ; O = L ),
    pad_box_lines(Ls, Os).

mostrar_pergunta(Texto, [OpA, OpB, OpC, OpD]) :-
    pergunta_block(Texto, [OpA, OpB, OpC, OpD], Lines),
    print_centered_block(Lines),
    nl.

pergunta_block(Texto, [OpA, OpB, OpC, OpD], Lines) :-
    Title = [
        "██████╗ ███████╗██████╗  ██████╗ ██╗   ██╗███╗   ██╗████████╗ █████╗ ",
        "██╔══██╗██╔════╝██╔══██╗██╔════╝ ██║   ██║████╗  ██║╚══██╔══╝██╔══██╗",
        "██████╔╝█████╗  ██████╔╝██║  ███╗██║   ██║██╔██╗ ██║   ██║   ███████║",
        "██╔═══╝ ██╔══╝  ██╔══██╗██║   ██║██║   ██║██║╚██╗██║   ██║   ██╔══██║",
        "██║     ███████╗██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║   ██║   ██║  ██║",
        "╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝"
    ],
    Box = [
        "╔════════════════════════════════════════════════════════════════╗",
        "║                                                                ║",
        "╠════════════════════════════════════════════════════════════════╣",
        "║                                                                ║",
        "╚════════════════════════════════════════════════════════════════╝"
    ],
    % mete o texto no meio (linha 2 do conteúdo)
    wrap_question_line(Texto, QLine),
    replace_nth0(1, Box, QLine, Box2),

    format(string(A), "║  A: ~w", [OpA]),
    format(string(B), "║  B: ~w", [OpB]),
    format(string(C), "║  C: ~w", [OpC]),
    format(string(D), "║  D: ~w", [OpD]),
    Options0 = [
        "╔════════════════════════════════════════════════════════════════╗",
        A, B, C, D,
        "╚════════════════════════════════════════════════════════════════╝"
    ],
    pad_box_lines(Options0, Options),

    pad_box_lines(Box2, Box3),
    append(Title, [""], T1),
    append(T1, Box3, T2),
    append(T2, [""], T3),
    append(T3, Options, Lines).

wrap_question_line(Texto, OutLine) :-
    % mete o texto numa linha única "║  ... ║" com padding
    normalize_space(string(T), Texto),
    string_length(T, Len),
    InnerW = 64,
    % corta se for demasiado longo (simples e seguro)
    ( Len > InnerW -> sub_string(T, 0, InnerW, _, T2) ; T2 = T ),
    string_length(T2, L2),
    Pad is max(0, InnerW - L2),
    length(Cs, Pad), maplist(=(' '), Cs),
    string_chars(PadStr, Cs),
    string_concat("  ", T2, Mid0),
    string_concat(Mid0, PadStr, Mid),
    format(string(OutLine), "║~w║", [Mid]).

replace_nth0(0, [_|T], X, [X|T]) :- !.
replace_nth0(N, [H|T], X, [H|R]) :-
    N > 0, N1 is N - 1,
    replace_nth0(N1, T, X, R).

mostrar_menu_opcoes :-
    menu_opcoes_block(Lines),
    print_centered_block(Lines),
    nl,
    write('Escolha uma opção: ').

menu_opcoes_block(Lines) :-


    Title = [
    "███████╗ ███████╗  ██████╗  ██████╗ ██╗     ██╗  ██╗  █████╗ ",
    "██╔════╝ ██╔════╝ ██╔════╝ ██╔═══██╗██║     ██║  ██║ ██╔══██╗",
    "█████╗   ███████╗ ██║      ██║   ██║██║     ███████║ ███████║",
    "██╔══╝   ╚════██║ ██║      ██║   ██║██║     ██╔══██║ ██╔══██║",
    "███████╗ ███████║ ╚██████╗ ╚██████╔╝███████╗██║  ██║ ██║  ██║",
    "╚══════╝ ╚══════╝  ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═╝  ╚═╝"
],

    Box0 = [
        "╔════════════════════════════════════════════════════════════════╗",
        "║  [A/B/C/D] - Responder                                         ║",
        "║  [H]       - Usar ajuda                                        ║",
        "║  [Q]       - Desistir e levar o dinheiro                       ║",
        "╚════════════════════════════════════════════════════════════════╝"
    ],
    pad_box_lines(Box0, Box),
    append(Title, [""], T1),
    append(T1, Box, Lines).



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

% mostrar_menu_opcoes :-
%     writeln(''),
%     writeln('O que deseja fazer?'),
%     writeln('  [A/B/C/D] - Responder'),
%     writeln('  [H] - Usar ajuda'),
%     writeln('  [Q] - Desistir e levar o dinheiro'),
%     write('Escolha uma opção: ').

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









