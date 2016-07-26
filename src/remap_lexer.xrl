Definitions.

INT = [0-9]+
ATOM = :[a-z_]+
WHITESPACE = [\s\t\n\r]
KEY = [A-Za-z0-9_-]+

Rules.

\$ : {token, {'$', TokenLine}}.
@ : {token, {'@', TokenLine}}.
\. : {token, {'.', TokenLine}}.
\[ : {token, {'[', TokenLine}}.
\] : {token, {']', TokenLine}}.
\* : {token, {'*', TokenLine}}.
{KEY} : {token, {key, TokenLine, TokenChars}}.

Erlang code.
