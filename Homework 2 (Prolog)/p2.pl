:- ['p1.pl'].

% Important notice: Left-recursive rules need to be handled using a tabular
% form. The following line allows Prolog to handle left recursion. List all
% left-recursive rules  separated by commas after “:- table” and end the
% line with a dot.

% <assign>  -> <id> = <expr>
%
% <id>      -> a | b | c
%
% <expr>    -> <expr> + <expr> | <expr> * <expr> | ( <expr> ) | <digit>
%
% <digit>   -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 */


% list_product([X],X).
% list_product([X | T], A) :- list_product(T,A1), A is A1 * X.

assign(S, R) :- append([id, equal_sign], Z, S), isExpr(Z).
assign_val([id | S], R, V) :- assign_val2(S, V).
assign_val2([equal_sign | S], V) :- expr(S, 0, V).

digit([0], Start, Start).
digit([1], Start, End) :- End is Start + 1.
digit([2], Start, End) :- End is Start + 2.
digit([3], Start, End) :- End is Start + 3.
digit([4], Start, End) :- End is Start + 4.
digit([5], Start, End) :- End is Start + 5.
digit([6], Start, End) :- End is Start + 6.
digit([7], Start, End) :- End is Start + 7.
digit([8], Start, End) :- End is Start + 8.
digit([9], Start, End) :- End is Start + 9.

expr(X, S, E) :- split(X, add_op, L, R), expr(L, S, E1), expr(R, S, E2), E is E1+E2.
expr(X, S, E) :- split(X, mul_op, L, R), expr(L, S, E1), expr(R, S, E2), E is E1*E2.
expr(X, S, E) :- split(X, lt_paren, [], R), split(R, rt_paren, M, []), expr(M, S, E).
expr(X, S, E) :- digit(X, S, E).

isExpr(Z) :- expr(Z, 0, _).

%assign([id,equal_sign, lt_paren, 1,add_op, 2, rt_paren, mul_op,3], []).
%%%% SAMPLE INPUTS & OUTPUTS
% | ?- assign([id,equal_sign,1,add_op,2,mul_op,3], []).
%
% yes
% | ?- assign([],[]).
%
% no
% | ?- assign([id,equal_sign], []).
%
% no
% | ?- tokenizer("a = 1 + 2 * 3", T), assign_val(T, [], V).
%
% T = [id,equal_sign,1,add_op,2,mul_op,3]
% V = 7;
%
% T = [id,equal_sign,1,add_op,2,mul_op,3]
% V = 9;
%
% no
% | ?- assign([id,equal_sign, lt_paren, 1,add_op, lt_paren, 2,mul_op,3, rt_paren], []).
%
% no
% | ?- assign([id,equal_sign, lt_paren, 1,add_op, 2, rt_paren, mul_op,3, rt_paren], []).
%
% no
% | ?- assign([id,equal_sign, lt_paren, 1,add_op, 2, rt_paren, mul_op,3], []).
%
% yes
% | ?-
