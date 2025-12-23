%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "parser.tab.h" // Includes tokens defined in Bison
%}

%option noyywrap

%%

[ \t\n]     ; // Ignore spaces, tabs, and newlines

[0-9]+      { 
    // Found a number! Convert text to integer and send to Bison
    yylval = createIntNode(atoi(yytext));
    return INTEGER; 
}

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MULT; }
"/"         { return DIV; }
";"         { return SEMICOLON; }

.           { 
    printf("Syntax Error: Unknown character: %s\n", yytext); 
    exit(1); 
}

%%