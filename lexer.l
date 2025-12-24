%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "parser.tab.h"
%}

%option noyywrap

%%

[ \t\n]     ; // Ignore whitespace

"var"       { return VAR; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }

[0-9]+      { 
    yylval = createIntNode(atoi(yytext));
    return INTEGER; 
}

[a-zA-Z][a-zA-Z0-9]* { 
    yylval = createNode(NODE_VAR, NULL, NULL);
    yylval->varName = strdup(yytext); 
    return IDENTIFIER; 
}

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MULT; }
"/"         { return DIV; }
"="         { return ASSIGN; }
";"         { return SEMICOLON; }

"=="        { return EQ; }
"!="        { return NEQ; }
"<"         { return LT; }
">"         { return GT; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
"("         { return LPAREN; }
")"         { return RPAREN; }

.           { printf("Unknown character: %s\n", yytext); exit(1); }

%%