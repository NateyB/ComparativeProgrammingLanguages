% Helper functions
tokenMatch(97, id).
tokenMatch(98, id).
tokenMatch(99, id).
tokenMatch(40, lt_paren).
tokenMatch(41, rt_paren).
tokenMatch(43, add_op).
tokenMatch(42, mul_op).
tokenMatch(45, sub_op).
tokenMatch(47, div_op).
tokenMatch(94, pow_op).
tokenMatch(61, equal_sign).
tokenMatch(48, 0).
tokenMatch(49, 1).
tokenMatch(50, 2).
tokenMatch(51, 3).
tokenMatch(52, 4).
tokenMatch(53, 5).
tokenMatch(54, 6).
tokenMatch(55, 7).
tokenMatch(56, 8).
tokenMatch(57, 9).

tokenizer(X, Y) :- parse(X, [], Y).

parse([], Tokens, Tokens).
parse([32 | Tail], Tokens, Rest) :- parse(Tail, Tokens, Rest).
parse([Item | Tail], Tokens, [Token | Prev]) :- tokenMatch(Item, Token), parse(Tail, Tokens, Prev).

append([], L, L).
append([H | T], L, [H | R]) :-  append(T, L, R).

member(E, [E | _]).
member(E, [_ | T]) :- member(E,T).

split([Item | List], Item, [], List).
split([Item | List], Search, [Item | Left], R) :- split(List, Search, Left, R).


%%%% SAMPLE INPUTS & OUTPUTS
% | ?- tokenizer("", T).
%
% T = []
% yes
% | ?- tokenizer("a = 1 + 2 + ( 5 + 0 / 9)", T).
%
% T = [id,equal_sign,1,add_op,2,add_op,lt_paren,5,add_op,0,div_op,9,rt_paren]
% yes
% | ?- tokenizer("a = 1 - 2 + 3 * 4 / 5 ^ (6 - 3)", T).
%
% T = [id,equal_sign,1,sub_op,2,add_op,3,mul_op,4,div_op,5,pow_op,lt_paren,6,sub_op,3,rt_paren]
% yes
% | ?- tokenizer("a = not in the language", T).
%
% no
