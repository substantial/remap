Definitions.

INT = [0-9]+
ATOM = :[a-z_]+
WHITESPACE = [\s\t\n\r]
IDENTIFIER = [A-Za-z0-9_-]+

Rules.

\$ : {token, {'$', TokenLine}}.
@ : {token, {'@', TokenLine}}.
\. : {token, {'.', TokenLine}}.
\[ : {token, {'[', TokenLine}}.
\] : {token, {']', TokenLine}}.
\* : {token, {'*', TokenLine}}.
{IDENTIFIER} : {token, {identifier, TokenLine, TokenChars}}.

Erlang code.
