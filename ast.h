#ifndef AST_H
#define AST_H

typedef enum {
    NODE_INT,       // For numbers like 5, 42
    NODE_VAR,       // For variable references like 'x'
    NODE_OP,        // For operators like +, -, *, /
    NODE_ASSIGN,    // For assignments like x = 5
    NODE_IF,        // For if statements
    NODE_WHILE,     // For while loops
    NODE_SEQ        // Connects two statements together
} NodeType;

// Enum for specific operators
typedef enum {
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_EQ,  // ==
    OP_NEQ, // !=
    OP_LT,  // <
    OP_GT   // >
} OpType;

typedef struct ASTNode {
    NodeType type;
    int value;              // For constants (e.g., 5) or OpType
    char* varName;          // For variables (e.g., "x")
    struct ASTNode *left;   // Left operand or Condition
    struct ASTNode *right;  // Right operand or If-Body
    struct ASTNode *next;   // Else-Body or Next statement
} ASTNode;

// Function prototypes
ASTNode* createNode(NodeType type, ASTNode* left, ASTNode* right);
ASTNode* createIntNode(int value);
int eval(ASTNode* node);

#endif