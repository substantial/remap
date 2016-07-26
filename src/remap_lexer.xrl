Definitions.

INT = [0-9]+
ATOM = :[a-z_]+
WHITESPACE = [\s\t\n\r]
IDENTIFIER = [A-Za-z0-9_-]+
STRING = "(\\["\\]|[^"\\])*"

Rules.

\$ : {token, {'$', TokenLine}}.
@ : {token, {'@', TokenLine}}.
\. : {token, {'.', TokenLine}}.
\.\. : {token, {'..', TokenLine}}.
\[ : {token, {'[', TokenLine}}.
\] : {token, {']', TokenLine}}.
\* : {token, {'*', TokenLine}}.
\" : {token, {'"', TokenLine}}.
{IDENTIFIER} : {token, {identifier, TokenLine, TokenChars}}.
{STRING} : {token, {string, TokenLine, TokenChars}}.

Erlang code.
