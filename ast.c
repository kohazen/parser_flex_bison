#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

/* ===== Symbol Table (Global, Simple) ===== */
/* Version 1: Arithmetic evaluation supported */
/* Version 2: Variable declaration, assignment, and lookup supported */
/* Version 3: Control flow (if/else, while) and comparisons supported */



#define MAX_VARS 128

typedef struct {
    char name[32];
    int value;
    int declared;
} Symbol;

static Symbol symtab[MAX_VARS];
static int symcount = 0;

/* ===== Symbol Helpers ===== */
static int lookup(char *name) {
    for (int i = 0; i < symcount; i++) {
        if (strcmp(symtab[i].name, name) == 0)
            return i;
    }
    return -1;
}

static void declare_var(char *name, int value) {
    if (lookup(name) != -1)
        return;
    strcpy(symtab[symcount].name, name);
    symtab[symcount].value = value;
    symtab[symcount].declared = 1;
    symcount++;
}

static int get_var(char *name) {
    int idx = lookup(name);
    if (idx == -1) {
        printf("Runtime Error: variable '%s' used before declaration\n", name);
        exit(1);
    }
    return symtab[idx].value;
}

static void set_var(char *name, int value) {
    int idx = lookup(name);
    if (idx == -1) {
        printf("Runtime Error: variable '%s' used before declaration\n", name);
        exit(1);
    }
    symtab[idx].value = value;
}

/* ===== AST Constructors ===== */
ASTNode *make_int(int value) {
    ASTNode *n = malloc(sizeof(ASTNode));
    n->type = NODE_INT;
    n->value = value;
    n->name = NULL;
    n->left = n->right = n->extra = NULL;
    return n;
}

ASTNode *make_var(char *name) {
    ASTNode *n = malloc(sizeof(ASTNode));
    n->type = NODE_VAR;
    n->name = name;
    n->left = n->right = n->extra = NULL;
    return n;
}

ASTNode *make_op(OpType op, ASTNode *l, ASTNode *r) {
    ASTNode *n = malloc(sizeof(ASTNode));
    n->type = NODE_OP;
    n->value = op;
    n->left = l;
    n->right = r;
    n->extra = NULL;
    return n;
}

ASTNode *make_assign(char *name, ASTNode *expr) {
    ASTNode *n = malloc(sizeof(ASTNode));
    n->type = NODE_ASSIGN;
    n->name = name;
    n->left = expr;
    n->right = n->extra = NULL;
    return n;
}

ASTNode *make_decl(char *name, ASTNode *init) {
    ASTNode *n = malloc(sizeof(ASTNode));
    n->type = NODE_DECL;
    n->name = name;
    n->left = init;
    n->right = n->extra = NULL;
    return n;
}

ASTNode *make_if(ASTNode *cond, ASTNode *then_b, ASTNode *else_b) {
    ASTNode *n = malloc(sizeof(ASTNode));
    n->type = NODE_IF;
    n->left = cond;
    n->right = then_b;
    n->extra = else_b;
    return n;
}

ASTNode *make_while(ASTNode *cond, ASTNode *body) {
    ASTNode *n = malloc(sizeof(ASTNode));
    n->type = NODE_WHILE;
    n->left = cond;
    n->right = body;
    n->extra = NULL;
    return n;
}

ASTNode *make_seq(ASTNode *first, ASTNode *second) {
    if (!first) return second;
    ASTNode *n = malloc(sizeof(ASTNode));
    n->type = NODE_SEQ;
    n->left = first;
    n->right = second;
    n->extra = NULL;
    return n;
}

/* ===== Evaluation Engine ===== */
int eval(ASTNode *n) {
    if (!n) return 0;

    switch (n->type) {

    case NODE_INT:
        return n->value;

    case NODE_VAR:
        return get_var(n->name);

		case NODE_OP: {
			int l = eval(n->left);
			    int r = eval(n->right);
			switch (n->value) {
			        case OP_ADD: return l + r;
			        case OP_SUB: return l - r;
			        case OP_MUL: return l * r;
					case OP_DIV:
					    if (r == 0) {
					        printf("Runtime Error: division by zero\n");
					        exit(1);
					    }
					    return l / r;

			        case OP_LT:  return l < r;
			        case OP_GT:  return l > r;
			        case OP_LE:  return l <= r;
			        case OP_GE:  return l >= r;
			        case OP_EQ:  return l == r;
			        case OP_NE:  return l != r;
		    }
		
    }

    case NODE_DECL: {
        int v = 0;
        if (n->left)
            v = eval(n->left);
        declare_var(n->name, v);
        return v;
    }

    case NODE_ASSIGN: {
        int v = eval(n->left);
        set_var(n->name, v);
        return v;
    }

	case NODE_IF:
	    if (eval(n->left))
	        eval(n->right);
	    else if (n->extra)
	        eval(n->extra);
	    return 0;
   

    case NODE_WHILE:
        while (eval(n->left))
            eval(n->right);
        return 0;

    case NODE_SEQ:
        eval(n->left);
        eval(n->right);
        return 0;
    }

    return 0;
}
