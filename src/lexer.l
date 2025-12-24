%option noinput
%option nounput

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ast.h"
#include "parser.tab.h"
%}

%%

[0-9]+ {
    yylval = createIntNode(atoi(yytext));
    return INTEGER;
}

"var"     { return VAR; }
"if"      { return IF; }
"else"    { return ELSE; }
"while"   { return WHILE; }

[a-zA-Z_][a-zA-Z0-9_]* {
    ASTNode *n = createNode(NODE_VAR, NULL, NULL);
    n->varName = strdup(yytext);
    yylval = n;
    return IDENTIFIER;
}

"=="  { return EQ; }
"!="  { return NEQ; }
"<="  { return LT; }   /* IMPORTANT */
">="  { return GT; }   /* IMPORTANT */
"<"   { return LT; }
">"   { return GT; }

"+"   { return PLUS; }
"-"   { return MINUS; }
"*"   { return MULT; }
"/"   { return DIV; }

"="   { return ASSIGN; }
";"   { return SEMICOLON; }

"("   { return LPAREN; }
")"   { return RPAREN; }
"{"   { return LBRACE; }
"}"   { return RBRACE; }

[ \t\r\n]+   ;
.            { return yytext[0]; }

%%

