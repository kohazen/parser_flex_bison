%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "parser.tab.h"

// Keep track of line numbers for error reporting
int yylineno = 1;
%}

%option noyywrap

%%

[ \t]       ; // Ignore spaces and tabs (but not newlines yet)
\n          { yylineno++; } // Count lines

"//".* ; // Rule: Ignore everything after // until the end of the line

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

.           { 
    // Better error message with line number
    printf("Lexical Error at line %d: Unknown character '%s'\n", yylineno, yytext); 
    exit(1); 
}

%%