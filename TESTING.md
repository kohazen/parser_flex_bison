# Testing Guide

This document explains how to test the parser implementation against all test cases from Lab3-Testcases.pdf.

## Building the Parser

First, ensure the parser is built:

```bash
make clean
make
```

You should see:
```
bison -d src/parser.y
flex src/lexer.l
gcc -Wall -g -I src -o parser parser.tab.c lex.yy.c src/ast.c src/main.c -lfl
```

## Understanding Test Behavior

**Valid Programs:**
- Parse and execute successfully
- Produce **no output** (silent execution)
- Exit code: 0

**Invalid Programs:**
- Show error messages to stderr
- Exit with non-zero code (typically 1)
- Two types of errors:
  - **Syntax Errors**: Reported during parsing (e.g., "Syntax Error at line 1: syntax error")
  - **Runtime Errors**: Reported during execution (e.g., "Runtime Error: variable 'x' used before declaration")

## Running Individual Tests

### Valid Test Cases

**Test 1: Variable Declaration**
```bash
printf 'var x;\n' | ./parser
```
Expected: No output (success)

**Test 2: Declaration with Initialization**
```bash
printf 'var x = 10;\n' | ./parser
```
Expected: No output (success)

**Test 3: Assignment**
```bash
printf 'var x;\nx = 5;\n' | ./parser
```
Expected: No output (success)

**Test 4: Arithmetic Expression**
```bash
printf 'var x;\nx = 5 + 3 * 2;\n' | ./parser
```
Expected: No output (success)

**Test 5: Comparison Expression**
```bash
printf 'var x = 10;\nvar y = 20;\nx = x < y;\n' | ./parser
```
Expected: No output (success)

**Test 6: If Statement**
```bash
printf 'var x = 5;\nif (x > 3)\n  x = x - 1;\n' | ./parser
```
Expected: No output (success)

**Test 7: If-Else Statement**
```bash
printf 'var x = 10;\nif (x < 5)\n  x = 0;\nelse\n  x = 1;\n' | ./parser
```
Expected: No output (success)

**Test 8: While Loop**
```bash
printf 'var i = 0;\nwhile (i < 5)\n  i = i + 1;\n' | ./parser
```
Expected: No output (success)

**Test 9: Block with Nested Statements**
```bash
printf 'var x = 0;\n{\n  var y = 1;\n  while (x < 3) {\n    if (x == 1)\n      y = y + 1;\n    else\n      y = y + 2;\n    x = x + 1;\n  }\n}\n' | ./parser
```
Expected: No output (success)

### Invalid Test Cases

**Test 10: Use Before Declaration**
```bash
printf 'x = 10;\n' | ./parser 2>&1
```
Expected output:
```
Runtime Error: variable 'x' used before declaration
```

**Test 11: Missing Semicolon**
```bash
printf 'var x = 10\nx = 5;\n' | ./parser 2>&1
```
Expected output:
```
Syntax Error at line 1: syntax error
```

**Test 12: Malformed Expression**
```bash
printf 'var x = 5 + ;\n' | ./parser 2>&1
```
Expected output:
```
Syntax Error at line 1: syntax error
```

**Test 13: Unmatched Braces**
```bash
printf 'var x = 5;\nif (x > 0) {\n  x = x - 1;\n' | ./parser 2>&1
```
Expected output:
```
Syntax Error at line 1: syntax error
```

**Test 14: Invalid Assignment Target**
```bash
printf 'var x = 5;\n(x + 1) = 10;\n' | ./parser 2>&1
```
Expected output:
```
Syntax Error at line 1: syntax error
```

## Running Tests from Files

The project includes pre-made test files in `tests/` directory.

### Running Valid Test Files

```bash
# Individual tests
./parser < tests/valid/v1_math.txt
./parser < tests/valid/v2_vars.txt
./parser < tests/valid/v3_if_while.txt
./parser < tests/valid/v4_nested.txt
./parser < tests/valid/v5_precedence.txt
./parser < tests/valid/v6_comparison.txt
./parser < tests/valid/v7_multi_var.txt
```

All should execute silently (no output = success).

### Running Invalid Test Files

```bash
# Individual tests (will show errors)
./parser < tests/invalid/undeclared.txt 2>&1
./parser < tests/invalid/missing_semicolon.txt 2>&1
./parser < tests/invalid/bad_expr.txt 2>&1
./parser < tests/invalid/i4_unmatched_brace.txt 2>&1
```

Each will display an appropriate error message.

## Batch Testing Scripts

### Run All Valid Tests

Create a script to test all valid programs:

```bash
#!/bin/bash
echo "=== Running Valid Tests ==="
for testfile in tests/valid/*.txt; do
    echo -n "Testing $(basename $testfile)... "
    if ./parser < "$testfile" 2>&1 > /dev/null; then
        echo "PASS"
    else
        echo "FAIL"
    fi
done
```

Save as `run_valid_tests.sh`, make executable with `chmod +x run_valid_tests.sh`, then run:
```bash
./run_valid_tests.sh
```

### Run All Invalid Tests

Create a script to test invalid programs:

```bash
#!/bin/bash
echo "=== Running Invalid Tests ==="
for testfile in tests/invalid/*.txt; do
    echo "Testing $(basename $testfile):"
    ./parser < "$testfile" 2>&1 | head -1
    echo ""
done
```

Save as `run_invalid_tests.sh`, make executable with `chmod +x run_invalid_tests.sh`, then run:
```bash
./run_invalid_tests.sh
```

### Run All Tests (One Command)

```bash
# Quick test of all valid files
for f in tests/valid/*.txt; do ./parser < "$f" && echo "$(basename $f): PASS" || echo "$(basename $f): FAIL"; done

# Quick test of all invalid files
for f in tests/invalid/*.txt; do echo "=== $(basename $f) ==="; ./parser < "$f" 2>&1 | head -1; done
```
