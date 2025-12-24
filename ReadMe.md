# Parser Project - Lab 2B

A simple parser and interpreter for a basic imperative language, built using Flex and Bison.

## Language Features

The parser supports:
- Variable declarations (`var x = 10;` or `var x;`)
- Assignments (`x = 20;`)
- Arithmetic operators (`+`, `-`, `*`, `/`)
- Comparison operators (`==`, `!=`, `<`, `>`)
- Control structures:
  - `if` statements with optional `else`
  - `while` loops
- Block scoping with `{}`
- Expression statements

## Build Instructions

### Prerequisites
- GCC compiler
- Flex (lexical analyzer generator)
- Bison (parser generator)
- Linux/WSL environment (for `-lfl` library)

### Building
```bash
make
```

This will:
1. Generate `parser.tab.c` and `parser.tab.h` from `src/parser.y` using Bison
2. Generate `lex.yy.c` from `src/lexer.l` using Flex
3. Compile all sources into the `parser` executable

### Cleaning
```bash
make clean
```

Removes all generated files (`parser`, `parser.tab.*`, `lex.yy.c`)

## Running the Parser

### Basic Usage
```bash
./parser < input_file.txt
```

The parser reads from standard input, parses the program, builds an AST, and executes it.

### Examples
```bash
# Run a simple arithmetic test
./parser < tests/valid/v1_math.txt

# Run a control flow test
./parser < tests/valid/v3_if_while.txt

# Test error handling
./parser < tests/invalid/undeclared.txt
```

## Running Tests

### All Valid Tests
```bash
for f in tests/valid/*.txt; do
    echo "Testing $f..."
    ./parser < "$f" && echo "PASS" || echo "FAIL"
done
```

### All Invalid Tests (should fail gracefully)
```bash
for f in tests/invalid/*.txt; do
    echo "Testing $f..."
    ./parser < "$f" 2>&1 | head -1
done
```

## Test Coverage

The project includes 11 test files:

**Valid programs** (7 tests):
- `v1_math.txt`: Basic arithmetic operations
- `v2_vars.txt`: Variable declarations and assignments
- `v3_if_while.txt`: Control flow with if-else and while
- `v4_nested.txt`: Nested if-else within while loop
- `v5_precedence.txt`: Operator precedence and parentheses
- `v6_comparison.txt`: Comparison operators
- `v7_multi_var.txt`: Multiple variable declarations

**Invalid programs** (4 tests):
- `undeclared.txt`: Use of undeclared variable
- `missing_semicolon.txt`: Syntax error (missing semicolon)
- `bad_expr.txt`: Malformed expression
- `i4_unmatched_brace.txt`: Unmatched braces

## Project Structure

```
parser_flex_bison-master/
├── src/
│   ├── lexer.l          # Flex lexer specification
│   ├── parser.y         # Bison parser specification
│   ├── ast.c            # AST implementation and evaluator
│   ├── ast.h            # AST data structures
│   └── main.c           # Entry point
├── Makefile
├── tests/
│   ├── valid/           # Valid test programs
│   └── invalid/         # Invalid test programs
├── report.pdf           # Technical report
└── README.md            # This file
```

## Implementation Notes

### Grammar
- The grammar follows standard operator precedence (multiplication/division before addition/subtraction)
- Comparison operators have lower precedence than arithmetic operators
- The dangling-else problem is resolved using Bison's default shift behavior

### Error Handling
- **Syntax errors**: Reported with line numbers by Bison
- **Runtime errors**: Reported for:
  - Division by zero
  - Use of undeclared variables
  - Assignment to undeclared variables

### Limitations
- No support for functions
- No support for arrays or strings
- Limited to integer arithmetic
- No floating-point support
- Simple symbol table (no nested scopes)
