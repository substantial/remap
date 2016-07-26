Terminals '$' '[' ']' '*' '.' '..' identifier.
Nonterminals root root_step path step member_expression.
Rootsymbol root.

root ->
    root_step path : ['$1' | '$2'].
root ->
    root_step : ['$1'].
root ->
    path : '$1'.

root_step ->
    member_expression : {child, '$1'}.
root_step ->
    '$' : root.

path ->
    step : ['$1'].
path ->
    step path : ['$1' | '$2'].

step ->
    '..' member_expression : {descendant, '$2'}.
step ->
    '.' member_expression : {child, '$2'}.
step ->
    '[' '*' ']' : {children, all}.

member_expression ->
    identifier : {identifier, list_to_atom(extract_token('$1'))}.

Erlang code.

extract_token({_Token, _Line, Value}) ->
     Value.
