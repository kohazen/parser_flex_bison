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

[0-9]+      { 
    yylval = createIntNode(atoi(yytext));
    return INTEGER; 
}

[a-zA-Z][a-zA-Z0-9]* { 
    // Found a variable name!
    // We create a generic node to hold the name string
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

.           { printf("Unknown character: %s\n", yytext); exit(1); }

%%