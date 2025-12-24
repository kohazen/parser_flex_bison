#ifndef AST_H
#define AST_H

/* ===== AST Node Types ===== */
typedef enum {
    NODE_INT,      // Integer literal
    NODE_VAR,      // Variable reference
    NODE_OP,       // Arithmetic / comparison operation
    NODE_ASSIGN,   // Assignment
    NODE_DECL,     // Variable declaration
    NODE_IF,       // If / else
    NODE_WHILE,    // While loop
    NODE_SEQ       // Sequence of statements
} NodeType;

/* ===== Operator Types ===== */
typedef enum {
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_LT,
    OP_GT,
    OP_LE,
    OP_GE,
    OP_EQ,
    OP_NE
} OpType;

/* ===== AST Node ===== */
typedef struct ASTNode {
    NodeType type;
    int value;                  // Literal value OR operator type
    char *name;                 // Variable name (if applicable)
    struct ASTNode *left;       // Left child
    struct ASTNode *right;      // Right child
    struct ASTNode *extra;      // Else body / loop body / next stmt
} ASTNode;

/* ===== Constructors ===== */
ASTNode *make_int(int value);
ASTNode *make_var(char *name);
ASTNode *make_op(OpType op, ASTNode *l, ASTNode *r);
ASTNode *make_assign(char *name, ASTNode *expr);
ASTNode *make_decl(char *name, ASTNode *init);
ASTNode *make_if(ASTNode *cond, ASTNode *then_b, ASTNode *else_b);
ASTNode *make_while(ASTNode *cond, ASTNode *body);
ASTNode *make_seq(ASTNode *first, ASTNode *second);

/* ===== Evaluation ===== */
int eval(ASTNode *node);

#endif
