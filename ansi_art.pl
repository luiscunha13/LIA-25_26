:- use_module(library(readutil)).  % read_stream_to_codes/2

% imprime um ficheiro ANSI (com escapes) tal como está
mostrar_ansi_file(Path) :-
    setup_call_cleanup(
        open(Path, read, S, [type(binary)]),
        (
            read_stream_to_codes(S, Codes),
            format('~s', [Codes])
        ),
        close(S)
    ).
