:- ['p1.pl'].

% 3. Expand and modify the BNF given in the second problem to handle addition,
% subtraction, multiplication, division, and exponents. The BNF must enforce the
% correct operator precedence and associativity. Expand your rules assign/2 and
% assign_val/3 according to the new BNF.
%
%
% By making the rules left-recursive we evaluate from right to left; by making
% them right-recursive, they are evaluated from left to right (for exponents).
% BNF:
% <assign> -> <id> = <expr>
%
% <id>         -> a | b | c
%
% <expr>    -> <expr> + <term> | <expr> - <term> | <term>
%
% <term>    -> <term> * <factor> | <term> / <factor> | <factor>
%
% <factor>  -> <item> ^ <factor> | <item>
%
% <item>    -> <digit> | ( <expr> )
%
% <digit>    -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 */


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

expr(X, S, E) :- split(X, add_op, L, R), expr(L, S, E1), term(R, S, E2), E is E1+E2.
expr(X, S, E) :- split(X, sub_op, L, R), expr(L, S, E1), term(R, S, E2), E is E1-E2.
expr(X, S, E) :- term(X, S, E).

term(X, S, E) :- split(X, mul_op, L, R), term(L, S, E1), factor(R, S, E2), E is E1*E2.
term(X, S, E) :- split(X, div_op, L, R), term(L, S, E1), factor(R, S, E2), E is E1/E2.
term(X, S, E) :- factor(X, S, E).

factor(X, S, E) :- split(X, pow_op, L, R), item(L, S, E1), factor(R, S, E2), E is E1**E2.
factor(X, S, E) :- item(X, S, E).

item(X, S, E) :- split(X, lt_paren, [], R), split(R, rt_paren, M, []), expr(M, S, E).
item(X, S, E) :- digit(X, S, E).

isExpr(Z) :- expr(Z, 0, _).

table :- expr\3, term\3, factor\3, item\3.
%%%% SAMPLE INPUTS & OUTPUTS
% | ?- tokenizer("a = 1 + 2 * 3", T), assign_val(T, [], V).
%
% T = [id,equal_sign,1,add_op,2,mul_op,3]
% V = 7;
%
% no
% | ?- tokenizer("a = (1 + 2) * (3 - 4) ^ 2 ^3 ", T), assign_val(T, [], V).
%
% T = [id,equal_sign,lt_paren,1,add_op,2,rt_paren,mul_op,lt_paren,3,sub_op,4,rt_paren,pow_op,2,pow_op,3]
% V = 3;
%
% no
% | ?- tokenizer("2^2^3 ", T), expr(T, 0, V).
%
% T = [2,pow_op,2,pow_op,3]
% V = 256;
%
% no
% | ?- tokenizer("a = 2 + 2 + 3", T), assign_val(T, [], V).
%
% T = [id,equal_sign,2,add_op,2,add_op,3]
% V = 7;
%
% no
% | ?- tokenizer("a = 2 - 2 - 3", T), assign_val(T, [], V).
%
% T = [id,equal_sign,2,sub_op,2,sub_op,3]
% V = -3;
%
% no
% | ?- tokenizer("b = 3 * 2^3" ,T), assign_val(T, [], V).
%
% T = [id,equal_sign,3,mul_op,2,pow_op,3]
% V = 24;
%
% no
% | ?- tokenizer("b = (3 * 2)^3" ,T), assign_val(T, [], V).
%
% T = [id,equal_sign,lt_paren,3,mul_op,2,rt_paren,pow_op,3]
% V = 216;
%
% no
% | ?- tokenizer("b = 3/2/2", T), assign_val(T, [], V).
%
% T = [id,equal_sign,3,div_op,2,div_op,2]
% V = 0.7500;
%
% no
% | ?- tokenizer("b = 3", T), assign_val(T, [], V).
%
% T = [id,equal_sign,3]
% V = 3;
%
% no
% | ?- tokenizer("c = 2 * 3^2/9", T), assign_val(T, [], V).
%
% T = [id,equal_sign,2,mul_op,3,pow_op,2,div_op,9]
% V = 2.0000;
%
% no
