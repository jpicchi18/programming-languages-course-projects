% *********************** REGULAR_KENKEN ****************************

% SOURCE CITATION: this predicate was inspired by the
%   cs_131 TA GitHub Repo at
%   https://github.com/CS131-TA-team/UCLA_CS131_CodeHelp/tree/master/Prolog
kenken(N, C, T) :-
    % restrict the number of rows to N
    length(T, N),
    
    % restrict the number of columns in each row to be N
    column_lengths(T, N),
    
    % make sure every cell in the matrix takes a value in [1,N]
    restrain_domain(T, N),

    % make sure T follows all cage constraints
    maplist(match_constraint(T), C),
    
    % all values in the same row must be distinct (i.e. for each row list
    %  in T, all of its values must be distinct from each other)
    maplist(fd_all_different, T),
    
    % get the transpose of the matrix T
    transpose(T, Transpose_Matrix),
    
    % all values in the same column must be distinct (i.e. for each column
    %  in Transpose, its constituent values must be distinct)
    maplist(fd_all_different, Transpose_Matrix),

    % restrict each cell to having only 1 possible value, not a range of different
    % values
    maplist(fd_labeling, T).



% COLUMN_LENGTHS...
% L is a list of lists and X is an integer. column_lengths succeeds if the
% length of each list in L is exactly X
% SOURCE CITATION: this predicate was inspired by the
%   cs_131 TA GitHub Repo at
%   https://github.com/CS131-TA-team/UCLA_CS131_CodeHelp/tree/master/Prolog
column_lengths([], _).
column_lengths([Head | Tail], X) :-
    length(Head, X),
    column_lengths(Tail, X).


% DOMAIN_VALUES...
% takes in a list of lists L and an integer X. succeeds if, for each list l in L,
% the elements of l fail in the range 1,2,...,X
% SOURCE CITATION: this predicate was inspired by the
%   cs_131 TA GitHub Repo at
%   https://github.com/CS131-TA-team/UCLA_CS131_CodeHelp/tree/master/Prolog
restrain_domain([], _).
restrain_domain([Head | Tail], X) :-
    fd_domain(Head, 1, X),
    restrain_domain(Tail, X).


% transpose(Matrix, Transpose)...
%  - uses 2 nested helper functions to check if Transpose is the transpose of Matrix
% returns true if Transpose is the transpose of T...
% SOURCE CITATION: this predicate was copy inspired by the
%   cs_131 TA GitHub Repo at
%   https://github.com/CS131-TA-team/UCLA_CS131_CodeHelp/tree/master/Prolog
transpose([], []).
transpose([FirstRowOfMatrix | RestOfMatrix], Transpose) :-
    traverse_matrix(FirstRowOfMatrix, [FirstRowOfMatrix | RestOfMatrix], Transpose).


% traverse_matrix(First_Row_Of_Matrix, Full_Matrix, Full_Transpose)...
%  - checks that each row of the transpose matrix is equivalent to its corresponding column
%     in the regular matrix.
%  - each recursive call reduces the column count of the matrix by 1 (removing the leftmost column
%     and passing along the rest of the matrix), and it reduces the row count of the tranpose matrix
%     by 1 (removing the topmost row and passing along the rest of the transpose matrix)
% SOURCE CITATION: this predicate was inspired by the
%   cs_131 TA GitHub Repo at
%   https://github.com/CS131-TA-team/UCLA_CS131_CodeHelp/tree/master/Prolog
traverse_matrix([], _, []). % stop once we've checked all elements of the matrix row
traverse_matrix([_ | Row1MinusFirstColumn], Matrix, [TransFirstRow | TransMinusFirstRow]) :-
    % check the first row of the tranpose matrix to verify it, and produce a matrix
    %  equivalent to the original without the first column.
    traverse_transpose_row(Matrix, TransFirstRow, MatrixMinusAColumn),
    % check the rest of the transpose rows
    traverse_matrix(Row1MinusFirstColumn, MatrixMinusAColumn, TransMinusFirstRow).


% traverse_transpose_row(full_matrix, transpose_row, full_matrix_minus_first_column)
% - returns true iff each element of the transpose_row matches the first element of each
%    row in full_matrix, and if full_matrix_minus_first_column is the same as full_matrix,
%    with the first columnn stripped away
% SOURCE CITATION: this predicate was inspired by the
%   cs_131 TA GitHub Repo at
%   https://github.com/CS131-TA-team/UCLA_CS131_CodeHelp/tree/master/Prolog
traverse_transpose_row([], [], []).
traverse_transpose_row([[FirstEl | RestRow] | RestRows], [FirstEl | RestTransRow], [RestRow | RestOfRowRests]) :-
    traverse_transpose_row(RestRows, RestTransRow, RestOfRowRests).

% match_constraint(T, +(S, Coord_List))...
%  succeeds if the values in T at each coordinate in Coord_List sum up to S
match_constraint(_, +(0, [])).
match_constraint(T, +(Sum, [ Coord |RestOfCoords])) :-
    get_element(T, Coord, Val),
    match_constraint(T, +(SumOfRest, RestOfCoords)),
    Sum #= Val + SumOfRest.

% match_constraint(T, *(P, Coord_List))...
%  succeeds if the values in T at each coordinate in Coord_List multiply to P
match_constraint(_, *(1, [])).
match_constraint(T, *(Prod, [ Coord |RestOfCoords])) :-
    get_element(T, Coord, Val),
    match_constraint(T, *(ProdOfRest, RestOfCoords)),
    Prod #= Val * ProdOfRest.

% match_constraint(T, -(D, A, B))...
%  succeeds if the values in T at coordinates A and B have a difference of Diff
match_constraint(T, -(Diff, A, B)) :-
    get_element(T, A, A_Val),
    get_element(T, B, B_Val),
    (Diff #= B_Val - A_Val; Diff #= A_Val - B_Val).

% match_constraint(T, -(Q, A, B))...
%  succeeds if the values in T at coordinates A and B divide to produce Q
match_constraint(T, /(Quot, A, B)) :-
    get_element(T, A, A_Val),
    get_element(T, B, B_Val),
    (Quot #= B_Val / A_Val; Quot #= A_Val / B_Val). 

% get_element(Matrix, Coord, Val)...
%  succeeds if the value at coordinate Coord in Matrix is equivalent to Val
get_element(Matrix, [A|B], X) :-
    nth(A, Matrix, Y),
    nth(B, Y, X).



% ************************ PLAIN_KENKEN ***************************

% SOURCE CITATION: this predicate was inspired by the
%   cs_131 TA GitHub Repo at
%   https://github.com/CS131-TA-team/UCLA_CS131_CodeHelp/tree/master/Prolog
plain_kenken(N, C, T) :-
    % restrict the number of rows to N
    length(T, N),
    
    % restrict the number of columns in each row to be N
    column_lengths(T, N),
    
    % % make sure every cell in the matrix takes a value in RangeList
    create_grid(T, N),
    
    % get the transpose of the matrix T
    transpose(T, Transpose_Matrix),
    
    % all values in the same column must be distinct (i.e. for each column
    %  in Transpose, its constituent values must be distinct)
    maplist(all_unique, Transpose_Matrix),

    % make sure T follows all cage constraints
    maplist(new_match_constraint(T), C).


% match_constraint(T, +(S, Coord_List))...
%  succeeds if the values in T at each coordinate in Coord_List sum up to S
new_match_constraint(_, +(0, [])).
new_match_constraint(T, +(Sum, [ Coord |RestOfCoords])) :-
    get_element(T, Coord, Val),
    new_match_constraint(T, +(SumOfRest, RestOfCoords)),
    Sum is Val + SumOfRest.

% match_constraint(T, *(P, Coord_List))...
%  succeeds if the values in T at each coordinate in Coord_List multiply to P
new_match_constraint(_, *(1, [])).
new_match_constraint(T, *(Prod, [ Coord |RestOfCoords])) :-
    get_element(T, Coord, Val),
     new_match_constraint(T, *(ProdOfRest, RestOfCoords)),
    Prod is Val * ProdOfRest.

% match_constraint(T, -(D, A, B))...
%  succeeds if the values in T at coordinates A and B have a difference of Diff
new_match_constraint(T, -(Diff, A, B)) :-
    get_element(T, A, A_Val),
    get_element(T, B, B_Val),
    (Diff is B_Val - A_Val; Diff is A_Val - B_Val).

% match_constraint(T, -(Q, A, B))...
%  succeeds if the values in T at coordinates A and B divide to produce Q
new_match_constraint(T, /(Quot, A, B)) :-
    get_element(T, A, A_Val),
    get_element(T, B, B_Val),
    (Quot is B_Val / A_Val; Quot is A_Val / B_Val).


% all_unique(Row)...
%  succeeds if all members of Row are distinct
%  (i.e. if the length of the sorted row is equivalent to the length of the row)
% SOURCE CITATION: this predicate was copy and pasted from the
%   cs_131 TA GitHub Repo at
%   https://github.com/CS131-TA-team/UCLA_CS131_CodeHelp/tree/master/Prolog
all_unique(Row) :-
    sort(Row, SortedRow),
    length(SortedRow, X),
    length(Row, X).

% SOURCE CITATION: this predicate was copy and pasted from the
%   cs_131 TA GitHub Repo at
%   https://github.com/CS131-TA-team/UCLA_CS131_CodeHelp/tree/master/Prolog
within_domain(N, Domain) :- 
    findall(X, between(1, N, X), Domain).

% fill in a 2D array with lists of fixed length (N)
% http://www.gprolog.org/manual/gprolog.html#sec215
% SOURCE CITATION: this predicate was copy and pasted from the
%   cs_131 TA GitHub Repo at
%   https://github.com/CS131-TA-team/UCLA_CS131_CodeHelp/tree/master/Prolog
fill_2d([], _).
fill_2d([Head | Tail], N) :-
    within_domain(N, Domain),
    permutation(Domain, Head),
    fill_2d(Tail, N).

% SOURCE CITATION: this predicate was copy and pasted from the
%   cs_131 TA GitHub Repo at
%   https://github.com/CS131-TA-team/UCLA_CS131_CodeHelp/tree/master/Prolog
create_grid(Grid, N) :-
    length(Grid, N),
    fill_2d(Grid, N).

% ******************************** TIME TESTS **********************************

% define test case
kenken_testcase(
    4,
    [
    +(6, [[1|1], [1|2], [2|1]]),
    *(96, [[1|3], [1|4], [2|2], [2|3], [2|4]]),
    -(1, [3|1], [3|2]),
    -(1, [4|1], [4|2]),
    +(8, [[3|3], [4|3], [4|4]]),
    *(2, [[3|4]])
    ]
).

time_test :-
    fd_set_vector_max(255),

    statistics,
    % statistics(real_time, [_,_]),
    kenken_testcase(N,C), kenken(N,C, _),
    % statistics(real_time, [_,K]),
    statistics, nl,

    
    % statistics(real_time, [_,_]),
    kenken_testcase(X,Y), plain_kenken(X,Y, _),
    % statistics(real_time, [_,PK]).
    statistics.



% ******************************** ANTIQUATED PREDICATES **********************************

% % nofd_restrain_domain(T, RangeList)...
% %  - succeeds if each cell of T is a member of RangeList
% nofd_restrain_domain([], _).
% nofd_restrain_domain([Head | Tail], RangeList) :-
%     nofd_process_row(Head, RangeList),
%     nofd_restrain_domain(Tail, RangeList).

% % nofd_process_row(Row, RangeList)...
% %  - succeeds if each cell in Row is a member of RangeList
% nofd_process_row([], _).
% nofd_process_row([Head | Tail], RangeList) :-
%     member(Head, RangeList),
%     nofd_process_row(Tail, RangeList).