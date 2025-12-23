%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

extern ASTNode* root;
int yylex();
void yyerror(const char* s);
%}

// Define that every symbol in the grammar is a pointer to a Node
#define YYSTYPE ASTNode*

// Define tokens
%token INTEGER
%token PLUS MINUS MULT DIV SEMICOLON

// Operator Precedence (Multiplication is higher priority than Addition)
%left PLUS MINUS
%left MULT DIV

%%

program:
    expression SEMICOLON { 
        root = $1; // Save the final tree
    }
    ;

expression:
    expression PLUS expression  { 
        $$ = createNode(NODE_OP, $1, $3); 
        $$->value = OP_ADD; 
    }
    | expression MINUS expression { 
        $$ = createNode(NODE_OP, $1, $3); 
        $$->value = OP_SUB; 
    }
    | expression MULT expression  { 
        $$ = createNode(NODE_OP, $1, $3); 
        $$->value = OP_MUL; 
    }
    | expression DIV expression   { 
        $$ = createNode(NODE_OP, $1, $3); 
        $$->value = OP_DIV; 
    }
    | INTEGER { 
        $$ = $1; 
    }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Parser Error: %s\n", s);
    exit(1);
}