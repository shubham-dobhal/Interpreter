%{
#include "p.tab.h"
#include <stdio.h>
%}

digit   [0-9]
id      [a-zA-Z_][a-zA-Z0-9_]*

%%

"print"         { return PRINT; }
"if"            { return IF; }
"while"         { return WHILE; }

{digit}+        { yylval.ival = atoi(yytext); return NUMBER; }
{id}            { yylval.sval = strdup(yytext); return ID; }

"=="            { return EQ; }
">"             { return GT; }
"<"             { return LT; }
"="             { return ASSIGN; }
";"             { return SEMICOLON; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MUL; }
"/"             { return DIV; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }

[ \t\n]+        { /* ignore whitespace */ }

.               { printf("Unknown character: %s\n", yytext); return yytext[0]; }

%%

int yywrap() { return 1; }
