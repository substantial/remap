Terminals '$' '[' ']' '*' '.' '..' ','
    identifier
    string
    integer
    array_slice
    script_expression
    filter_expression.
Nonterminals
    root
    leading_component
    child_member_component
    descendant_member_component
    member_expression
    member_component
    subscript_component
    child_subscript_component
    descendant_subscript_component
    subscript
    subscript_expression_list
    subscript_expression_listable
    path_components
    path_component
    subscript_expression.
Rootsymbol root.

root ->
    leading_component : ['$1'].
root ->
    leading_component path_components : ['$1' | '$2'].

leading_component ->
    member_expression : {child, '$1'}.
leading_component ->
    member_component : '$1'.
leading_component ->
    subscript_component : '$1'.
leading_component ->
    '$' : root.

path_components ->
    path_component : ['$1'].
path_components ->
    path_component path_components : ['$1' | '$2'].

path_component ->
    member_component : '$1'.
path_component ->
    subscript_component : '$1'.

member_component ->
    child_member_component : '$1'.
member_component ->
    descendant_member_component : '$1'.

child_member_component ->
    '.' member_expression : {child, '$2'}.

descendant_member_component ->
    '..' member_expression : {descendant, '$2'}.

member_expression ->
    '*' : wildcard.
member_expression ->
    identifier : {identifier, list_to_atom(extract_token('$1'))}.
member_expression ->
    script_expression : {script_expression, extract_token('$1')}.
member_expression ->
    integer : {integer, extract_token('$1')}.

subscript_component ->
    child_subscript_component : '$1'.
subscript_component ->
    descendant_subscript_component : '$1'.

child_subscript_component ->
    '[' subscript ']' : {child, '$2'}.

descendant_subscript_component ->
    '..' '[' subscript ']' : {descendant, '$3'}.

subscript ->
    subscript_expression : '$1'.
subscript ->
    subscript_expression_list : '$1'.

subscript_expression_list ->
    subscript_expression_listable : '$1'.
subscript_expression_list ->
    subscript_expression_list ',' subscript_expression_listable.

subscript_expression_listable ->
    integer.
subscript_expression_listable ->
    string : {identifier, to_string(extract_token('$1'))}.
subscript_expression_listable ->
    array_slice.

subscript_expression ->
    '*' : wildcard.
subscript_expression ->
    script_expression.
subscript_expression ->
    filter_expression.

Erlang code.

extract_token({_Token, _Line, Value}) ->
     Value.

to_string(Value) ->
    list_to_binary(string:substr(Value, 2, string:len(Value) - 2)).
