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
%token INTEGER IDENTIFIER VAR
%token IF ELSE WHILE
%token PLUS MINUS MULT DIV ASSIGN SEMICOLON
%token EQ NEQ LT GT
%token LBRACE RBRACE LPAREN RPAREN

// Operator Precedence (Comparisons < Math < Multiplication)
%left EQ NEQ LT GT
%left PLUS MINUS
%left MULT DIV

%%

program:
    statement_list { root = $1; }
    ;

statement_list:
    statement { $$ = $1; }
    | statement_list statement {
        // Link statements together so they run in order
        $$ = createNode(NODE_SEQ, $1, $2);
    }
    ;

statement:
    variable_decl
    | assignment
    | if_statement
    | while_statement
    | block
    | expression SEMICOLON { $$ = $1; } 
    ;

block:
    LBRACE statement_list RBRACE { $$ = $2; }
    ;

variable_decl:
    VAR IDENTIFIER ASSIGN expression SEMICOLON {
        $$ = createNode(NODE_ASSIGN, $4, NULL); 
        $$->varName = $2->varName;
    }
    | VAR IDENTIFIER SEMICOLON {
        $$ = createNode(NODE_ASSIGN, createIntNode(0), NULL);
        $$->varName = $2->varName;
    }
    ;

assignment:
    IDENTIFIER ASSIGN expression SEMICOLON {
        $$ = createNode(NODE_ASSIGN, $3, NULL);
        $$->varName = $1->varName;
    }
    ;

if_statement:
    IF LPAREN expression RPAREN statement {
        // Create IF node: Left=Condition, Right=TrueBlock
        $$ = createNode(NODE_IF, $3, $5);
    }
    | IF LPAREN expression RPAREN statement ELSE statement {
        // Create IF node: Left=Condition, Right=TrueBlock, Next=ElseBlock
        $$ = createNode(NODE_IF, $3, $5);
        $$->next = $7;
    }
    ;

while_statement:
    WHILE LPAREN expression RPAREN statement {
        // Create WHILE node: Left=Condition, Right=LoopBody
        $$ = createNode(NODE_WHILE, $3, $5);
    }
    ;

expression:
    expression PLUS expression  { $$ = createNode(NODE_OP, $1, $3); $$->value = OP_ADD; }
    | expression MINUS expression { $$ = createNode(NODE_OP, $1, $3); $$->value = OP_SUB; }
    | expression MULT expression  { $$ = createNode(NODE_OP, $1, $3); $$->value = OP_MUL; }
    | expression DIV expression   { $$ = createNode(NODE_OP, $1, $3); $$->value = OP_DIV; }
    
    | expression EQ expression    { $$ = createNode(NODE_OP, $1, $3); $$->value = OP_EQ; }
    | expression NEQ expression   { $$ = createNode(NODE_OP, $1, $3); $$->value = OP_NEQ; }
    | expression LT expression    { $$ = createNode(NODE_OP, $1, $3); $$->value = OP_LT; }
    | expression GT expression    { $$ = createNode(NODE_OP, $1, $3); $$->value = OP_GT; }

    | LPAREN expression RPAREN  { $$ = $2; }
    | INTEGER                   { $$ = $1; }
    | IDENTIFIER                { $$ = $1; }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Error: %s\n", s);
}