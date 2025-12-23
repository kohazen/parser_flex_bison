%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

extern ASTNode* root;
int yylex();
void yyerror(const char* s);
%}

#define YYSTYPE ASTNode*

// Tokens
%token INTEGER IDENTIFIER
%token VAR
%token PLUS MINUS MULT DIV ASSIGN SEMICOLON

// Precedence
%left PLUS MINUS
%left MULT DIV

%%

program:
    statement_list
    ;

statement_list:
    statement { 
        root = $1; // Save the last statement as root for now
    }
    | statement_list statement {
        root = $2; // Overwrite root with the latest statement
    }
    ;

statement:
    variable_decl
    | assignment
    | expression SEMICOLON { $$ = $1; } 
    ;

variable_decl:
    VAR IDENTIFIER ASSIGN expression SEMICOLON {
        // "var x = 5;" is parsed as an ASSIGN node
        $$ = createNode(NODE_ASSIGN, $4, NULL); 
        $$->varName = $2->varName;
    }
    | VAR IDENTIFIER SEMICOLON {
         // "var x;" (no value) is parsed as x = 0
        $$ = createNode(NODE_ASSIGN, createIntNode(0), NULL);
        $$->varName = $2->varName;
    }
    ;

assignment:
    IDENTIFIER ASSIGN expression SEMICOLON {
        // "x = 5;"
        $$ = createNode(NODE_ASSIGN, $3, NULL);
        $$->varName = $1->varName;
    }
    ;

expression:
    expression PLUS expression  { $$ = createNode(NODE_OP, $1, $3); $$->value = OP_ADD; }
    | expression MINUS expression { $$ = createNode(NODE_OP, $1, $3); $$->value = OP_SUB; }
    | expression MULT expression  { $$ = createNode(NODE_OP, $1, $3); $$->value = OP_MUL; }
    | expression DIV expression   { $$ = createNode(NODE_OP, $1, $3); $$->value = OP_DIV; }
    | INTEGER                   { $$ = $1; }
    | IDENTIFIER                { $$ = $1; } // Use the variable node created in Lexer
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Error: %s\n", s);
}