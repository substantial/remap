Terminals '$' '@' '[' ']' '*' '.' key.
Nonterminals root root_step path step key_step.
Rootsymbol root.

root ->
    root_step path : ['$1' | '$2'].
root ->
    root_step : ['$1'].
root ->
    path : '$1'.

root_step ->
    key_step : '$1'.
root_step ->
    '$' : root.
root_step ->
    '@' : current.

path ->
    step : ['$1'].
path ->
    step path : ['$1' | '$2'].

step ->
    '.' key_step : '$2'.
step ->
    '[' '*' ']' : {children, all}.

key_step ->
    key : {key, list_to_atom(extract_token('$1'))}.

Erlang code.

extract_token({_Token, _Line, Value}) ->
     Value.
