Definitions.

INT = [0-9]+
ATOM = :[a-z_]+
WHITESPACE = [\s\t\n\r]
KEY = [^.\[]+

Rules.

\$ : {token, root}.
@ : {token, current}.
\. : skip_token.
{KEY} : {token, {key, list_to_binary(TokenChars)}}.
\[\*\] : {token, {children, all}}.

Erlang code.
