% Load built-in HTTP and JSON libraries
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(clpfd)).

% Initialization directive runs automatically when the file is loaded
:- initialization(start_server, main).

start_server :-
    Port = 8080,
    http_server(http_dispatch, [port(Port)]),
    format('Server is running on port ~w...~n', [Port]),
    % Prevent the main thread from exiting (keeps the Docker container alive)
    thread_get_message(_).

% Bind the POST /solver route to the solver_handler
:- http_handler('/solve', solve_handler, [method(post)]).

% --- Request Handlers ---
solve_handler(Request) :-
    % 1. Parse the incoming JSON request body into a Prolog Dict
    http_read_json_dict(Request, DictIn),

    % 2. Log the received data to the console (for debugging purposes)
    format(user_error, 'Received a board to solve.~n', []),

    % Extract the board array from the JSON request
    BoardIn = DictIn.board,

    % Convert JSON 0s into Prolog free variables (_)
    prepare_board(BoardIn, PrologBoard),

    % Attempt to solve the Sudoku
    (   solve_sudoku(PrologBoard)
    ->  % If success, send back the solved board
        DictOut = _{ status: "success", board: PrologBoard}
    ;   % If it fails (invalid Sudoku), send an error
        DictOut = _{ status: "error", message: "This board is unsolvable."}
    ),

    % 4. Send the response back to the client
    reply_json_dict(DictOut).

% Replaces 0 with an unbound variable (_) so clpfd can fill it
prepare_board([], []).
prepare_board([RowIn|RestIn], [RowOut|RestOut]) :-
    replace_zeros(RowIn, RowOut),
    prepare_board(RestIn, RestOut).

replace_zeros([], []).
replace_zeros([0|T1], [_|T2]) :- replace_zeros(T1, T2).
replace_zeros([H|T1], [H|T2]) :- H \= 0, replace_zeros(T1, T2).

solve_sudoku(Rows) :-
    % Ensure it is a 9x9 grid
    length(Rows, 9),

    % 1. All variables must be between 1 and 9
    maplist(same_length(Rows), Rows),

    % 2. All rows must have distinct numberes
    append(Rows, Vs), Vs ins 1..9, 
    maplist(all_distinct, Rows),

    % 3. All columns must have distinct numbers (transpose flips the matrix)
    transpose(Rows, Columns),
    maplist(all_distinct, Columns),

    % 4. All 3x3 blocks must have distinct numbers
    Rows = [As, Bs, Cs, Ds, Es, Fs, Gs, Hs, Is],
    blocks(As, Bs, Cs),
    blocks(Ds, Es, Fs),
    blocks(Gs, Hs, Is),

    % Find the actual solution (instsasntiate the variables)
    maplist(label, Rows).

% Helper to check 3x3 blocks
blocks([], [], []).
blocks([N1,N2,N3|Ns1], [N4,N5,N6|Ns2], [N7,N8,N9|Ns3]) :-
    all_distinct([N1,N2,N3,N4,N5,N6,N7,N8,N9]),
    blocks(Ns1, Ns2, Ns3).