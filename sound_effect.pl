% ============================================================================
% PREDICADOS DE SOM
% ============================================================================

% Som de vitória (toca uma vez, sem loop)
tocar_som_vitoria :-
    shell('afplay SoundEffects/vitoria.mp3').

% Som do primeiro menu (em loop contínuo)
tocar_som_primeiro_menu :-
    shell('(while true; do afplay SoundEffects/primeiro_menu.mp3; done) &').

% Som do menu principal (em loop contínuo)
tocar_som_main_menu :-
    shell('(while true; do afplay SoundEffects/main_menu.mp3; done) &').

% Para todos os sons a tocar (mata processos afplay E subshells)
% Sempre tem sucesso, mesmo que não haja processos a matar
parar_som :-
    ignore(shell('pkill -9 afplay 2>/dev/null')),
    ignore(shell('pkill -9 -f "while true.*afplay" 2>/dev/null')).

% ============================================================================
% CLEANUP AUTOMÁTICO AO SAIR
% ============================================================================

% Garante que os sons param quando o programa Prolog termina
:- at_halt(parar_som).

