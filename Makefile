# Makefile for Linux/WSL

# Standard compiler flags
CC = gcc
CFLAGS = -Wall -g

# Libraries: Linux uses -lfl, macOS uses -ll
# If on macOS, change -lfl to -ll
LIBS = -lfl

# Targets
parser: parser.tab.c lex.yy.c ast.c main.c
	$(CC) $(CFLAGS) -o parser parser.tab.c lex.yy.c ast.c main.c $(LIBS)

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

clean:
	rm -f parser parser.tab.c parser.tab.h lex.yy.c