#include <stdio.h>
#include "ast.h"

extern int yyparse();
extern ASTNode *root;

int main() {
    if (yyparse() == 0) {
        eval(root);
    }
    return 0;
}
