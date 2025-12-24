# Technical Report: Parser Implementation for Simple Imperative Language
## Lab 2B - Systems Programming

---

## 1. Language Design

### 1.1 Overview
We designed and implemented a simple imperative programming language with support for basic control structures, variable management, and arithmetic/comparison operations. The language syntax is C-like, making it familiar and intuitive.

### 1.2 Language Constructs

**Variable Declarations:**
```
var x = 10;    // Declaration with initialization
var y;         // Declaration without initialization (defaults to 0)
```

**Assignments:**
```
x = 20;
y = x + 5;
```

**Control Structures:**
```
if (condition) statement
if (condition) statement else statement
while (condition) statement
```

**Expressions:**
- Arithmetic: `+`, `-`, `*`, `/`
- Comparison: `==`, `!=`, `<`, `>`
- Parenthesized expressions: `(expr)`
- Integer literals and variable references

**Blocks:**
```
{
    statement1;
    statement2;
}
```

---

## 2. Lexical Analysis (Lexer)

### 2.1 Tokenization Strategy

The lexer is implemented using Flex and recognizes the following token categories:

**Keywords:**
- `var`, `if`, `else`, `while`

**Operators:**
- Arithmetic: `+`, `-`, `*`, `/`
- Assignment: `=`
- Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`

**Delimiters:**
- `;` (semicolon), `(`, `)`, `{`, `}`

**Literals:**
- Integer literals: `[0-9]+`
- Identifiers: `[a-zA-Z_][a-zA-Z0-9_]*`

**Whitespace:**
- Ignored: spaces, tabs, newlines, carriage returns

### 2.2 Lexer Rules (lexer.l)

Key implementation details:

```c
[0-9]+                      // Integer literal - converted to AST node
[a-zA-Z_][a-zA-Z0-9_]*      // Identifier - check if keyword, else return ID
"=="                        // Equality operator
"!="                        // Inequality operator
```

Each token returns an appropriate value to the parser, with semantic values (like integer values or identifier names) stored in the `yylval` semantic value field as `ASTNode*` pointers.

### 2.3 Line Number Tracking

The lexer automatically tracks line numbers using Flex's built-in `yylineno` variable, which is used for error reporting.

---

## 3. Grammar Design and Parsing

### 3.1 Grammar Specification

The grammar is specified in Bison (parser.y) using a context-free grammar (CFG):

```
program         → statement_list

statement_list  → statement
                | statement_list statement

statement       → variable_decl
                | assignment
                | if_statement
                | while_statement
                | block
                | expression ;

variable_decl   → VAR IDENTIFIER ASSIGN expression ;
                | VAR IDENTIFIER ;

assignment      → IDENTIFIER ASSIGN expression ;

if_statement    → IF ( expression ) statement
                | IF ( expression ) statement ELSE statement

while_statement → WHILE ( expression ) statement

block           → { statement_list }

expression      → expression + expression
                | expression - expression
                | expression * expression
                | expression / expression
                | expression == expression
                | expression != expression
                | expression < expression
                | expression > expression
                | ( expression )
                | INTEGER
                | IDENTIFIER
```

### 3.2 Operator Precedence

Precedence and associativity are specified using Bison directives:

```bison
%left EQ NEQ LT GT          // Comparison operators (lowest precedence)
%left PLUS MINUS            // Addition and subtraction
%left MULT DIV              // Multiplication and division (highest precedence)
```

This ensures that:
- `2 + 3 * 4` parses as `2 + (3 * 4)` = 14
- `10 - 5 - 2` parses as `(10 - 5) - 2` = 3 (left-associative)
- `x < 10 + 5` parses as `x < (10 + 5)`

### 3.3 Conflict Resolution

The grammar has one shift/reduce conflict arising from the "dangling else" problem:

```
if (x > 0)
    if (y > 0)
        z = 1;
    else        // Does this belong to the inner or outer if?
        z = 2;
```

Bison's default behavior (shift) correctly associates the `else` with the nearest `if`, which matches conventional programming language semantics.

---

## 4. Abstract Syntax Tree (AST)

### 4.1 AST Node Structure

The AST is defined in `ast.h`:

```c
typedef struct ASTNode {
    NodeType type;          // Type of node
    int value;              // Integer value or operator type
    char *varName;          // Variable name (for variables/assignments)

    struct ASTNode *left;   // Left child
    struct ASTNode *right;  // Right child
    struct ASTNode *extra;  // Additional child (for if-else)
    struct ASTNode *next;   // Next sibling (for sequences)
} ASTNode;
```

**Node Types:**
- `NODE_INT`: Integer literal
- `NODE_VAR`: Variable reference
- `NODE_OP`: Binary operation
- `NODE_ASSIGN`: Assignment statement
- `NODE_DECL`: Variable declaration
- `NODE_IF`: If statement
- `NODE_WHILE`: While loop
- `NODE_SEQ`: Statement sequence

### 4.2 AST Construction

During parsing, semantic actions construct AST nodes:

**Example: Variable Declaration**
```bison
VAR IDENTIFIER ASSIGN expression SEMICOLON {
    $$ = createNode(NODE_DECL, $4, NULL);
    $$->varName = $2->varName;
}
```

This creates a `NODE_DECL` node with:
- `left`: points to the initialization expression AST
- `varName`: stores the variable name

**Example: Binary Operation**
```bison
expression PLUS expression {
    $$ = createNode(NODE_OP, $1, $3);
    $$->value = OP_ADD;
}
```

### 4.3 AST Traversal and Evaluation

The `eval()` function in `ast.c` recursively traverses and evaluates the AST:

1. **Literal evaluation**: Returns the integer value
2. **Variable evaluation**: Looks up the variable in the symbol table
3. **Operation evaluation**: Recursively evaluates operands, applies operation
4. **Control flow**: Evaluates conditions and executes branches accordingly

---

## 5. Symbol Table and Execution

### 5.1 Symbol Table Implementation

A simple array-based symbol table is implemented in `ast.c`:

```c
typedef struct {
    char name[32];
    int value;
} Symbol;

static Symbol symtab[MAX_VARS];  // Max 128 variables
static int symcount = 0;
```

**Operations:**
- `lookup(name)`: Find variable index
- `declare_var(name, value)`: Add new variable
- `get_var(name)`: Retrieve variable value
- `set_var(name, value)`: Update variable value

### 5.2 Execution Model

The interpreter uses a tree-walking evaluation approach:

1. Parser builds complete AST
2. `eval(root)` is called on the root node
3. Each node type has specific evaluation logic:
   - Declarations add variables to symbol table
   - Assignments update existing variables
   - Operations compute results from children
   - Control structures evaluate conditions and branches

---

## 6. Error Handling

### 6.1 Syntax Errors

Bison's `yyerror()` function reports syntax errors with line numbers:

```c
void yyerror(const char* s) {
    fprintf(stderr, "Syntax Error at line %d: %s\n", yylineno, s);
}
```

**Example output:**
```
Syntax Error at line 3: syntax error
```

### 6.2 Runtime Errors

Runtime errors are detected during AST evaluation:

**Undeclared Variable:**
```c
if (i == -1) {
    printf("Runtime Error: variable '%s' used before declaration\n", name);
    exit(1);
}
```

**Division by Zero:**
```c
if (r == 0) {
    printf("Runtime Error: division by zero\n");
    exit(1);
}
```

### 6.3 Error Recovery

Currently, the parser does not implement error recovery. On encountering a syntax error, parsing stops immediately. This is acceptable for a simple interpreter but could be enhanced in future versions.

---

## 7. Testing Strategy

### 7.1 Test Coverage

We created 11 comprehensive test cases:

**Valid Programs (7):**
1. **v1_math.txt**: Basic arithmetic (`3 + 4 * 5`)
2. **v2_vars.txt**: Variable operations
3. **v3_if_while.txt**: Control flow with if-else and while
4. **v4_nested.txt**: Nested control structures
5. **v5_precedence.txt**: Operator precedence verification
6. **v6_comparison.txt**: All comparison operators
7. **v7_multi_var.txt**: Multiple variable declarations

**Invalid Programs (4):**
1. **undeclared.txt**: Use before declaration
2. **missing_semicolon.txt**: Syntax error
3. **bad_expr.txt**: Malformed expression
4. **i4_unmatched_brace.txt**: Unmatched delimiters

### 7.2 Test Results

All tests pass successfully:
- Valid programs execute without errors
- Invalid programs produce appropriate error messages
- No segmentation faults or memory errors

---

## 8. Limitations and Future Extensions

### 8.1 Current Limitations

1. **Type System**: Only integer types supported
2. **Scope**: No nested scopes; single global scope
3. **Functions**: No function definitions or calls
4. **Data Structures**: No arrays, strings, or structs
5. **I/O**: No input/output operations
6. **Error Recovery**: Parser stops on first error

### 8.2 Possible Extensions

1. **Enhanced Type System**:
   - Add floating-point, boolean, and string types
   - Type checking during parsing

2. **Functions**:
   - Function definitions and calls
   - Parameter passing
   - Return values

3. **Advanced Features**:
   - Arrays and indexing
   - For loops
   - Break/continue statements
   - Logical operators (`&&`, `||`, `!`)

4. **Better Error Handling**:
   - Error recovery in parser
   - Multiple error reporting
   - Warning messages

5. **Optimization**:
   - Constant folding
   - Dead code elimination
   - Bytecode compilation instead of tree-walking

6. **Development Tools**:
   - AST visualization
   - Debugger support
   - Interactive REPL

---

## 9. Conclusion

This lab assignment successfully implements a complete parser and interpreter for a simple imperative language using industry-standard tools (Flex and Bison). The implementation demonstrates:

- Proper lexical analysis and tokenization
- Context-free grammar design with correct precedence
- AST construction and tree-walking evaluation
- Basic symbol table management
- Comprehensive error handling
- Thorough testing methodology
