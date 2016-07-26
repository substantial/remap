Terminals '$' '@' '[' ']' '*' '.' key.
Nonterminals root root_instruction instructions instruction key_instruction.
Rootsymbol root.

root ->
    root_instruction instructions : ['$1' | '$2'].
root ->
    root_instruction : ['$1'].
root ->
    instructions : '$1'.

root_instruction ->
    key_instruction : '$1'.
root_instruction ->
    '$' : root.
root_instruction ->
    '@' : current.

instructions ->
    instruction : ['$1'].
instructions ->
    instruction instructions : ['$1' | '$2'].

instruction ->
    '.' key_instruction : '$2'.
instruction ->
    '[' '*' ']' : {children, all}.

key_instruction ->
    key : {key, list_to_atom(extract_token('$1'))}.

Erlang code.

extract_token({_Token, _Line, Value}) ->
     Value.
