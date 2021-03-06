%{
    #include <stdlib.h>
    #include <string.h>
    #include <stdio.h>
    #include <math.h>
    #include "ast.h"
    #include "syntax.tab.h"
    int yycolumn = 1;
    int error_num;
    
    void yyerror(const char*s);
    
    #define YY_USER_ACTION \
        yylloc.first_line = yylineno; \
        yylloc.first_column = yycolumn; \
        yylloc.last_line = yylineno; \
        yylloc.last_column = yycolumn + yyleng; \
        yycolumn += yyleng;
    #define ERROR_A() printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, yytext); error_num++;
    #define ERROR_B(lineno, msg) printf("Error type B at Line %d: %s\n", lineno, msg); error_num++;    
%}

%option yylineno
decInt          [1-9][0-9]*
hexInt          0|0[xX][1-9a-fA-F][0-9a-fA-F]*|0[xX][0]
wrong_hexInt    0[xX][0-9a-zA-Z]*
float           -?[0-9]+\.[0-9]+
id              [a-zA-Z_][0-9a-zA-Z_]*
wrong_id        [0-9][0-9a-zA-Z_]*
letter          [a-zA-Z_]
char            ('{letter}')|('\\[xX][0-9a-fA-F]{1,2}')
wrong_char      ('.+')
%%

{decInt} {
    int val = atol(yytext);
    yylval.node = newASTNode(yylineno, "INT", INT, &val, 0);
    return INT;
}
{hexInt} {
    int val = 0;
    sscanf(yytext, "%x", &val);
    yylval.node = newASTNode(yylineno, "INT", INT, &val, 0);
    return INT;
}
{wrong_hexInt} {
    ERROR_A();
    int val = 0;
    yylval.node = newASTNode(yylineno, "INT", INT, &val, 0);
    return INT;
}
{float} {
    float val = strtof(yytext, NULL);
    yylval.node = newASTNode(yylineno, "FLOAT", FLOAT, &val, 0);
    return FLOAT;
}
"int"|"float"|"char" {
    char *s = malloc(strlen(yytext) + 1);
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "TYPE", TYPE, s, 0);
    return TYPE;
}
"struct" {
    yylval.node = newASTNode(yylineno, "STRUCT", STRUCT, NULL, 0);
    return STRUCT;
}
"return" {
    yylval.node = newASTNode(yylineno, "RETURN", RETURN, NULL, 0);
    return RETURN;
}
"if" {
    yylval.node = newASTNode(yylineno, "IF", IF, NULL, 0);
    return IF;
}
"else" {
    yylval.node = newASTNode(yylineno, "ELSE", ELSE, NULL, 0);
    return ELSE;
}
"while" {
    yylval.node = newASTNode(yylineno, "WHILE", WHILE, NULL, 0);
    return WHILE;
}
{id} {
    char *s = malloc(strlen(yytext) + 1);
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "ID", ID, s, 0);
    return ID;
}
{wrong_id} {
    ERROR_A();
    return ID;
}
{char} {
    char *s = malloc(strlen(yytext) + 1);
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "CHAR", CHAR, s, 0);
    return CHAR;
}
{wrong_char} {
    ERROR_A();
    return CHAR;
}
"." {
    yylval.node = newASTNode(yylineno, "DOT", DOT, NULL, 0);
    return DOT;
}
";" {
    yylval.node = newASTNode(yylineno, "SEMI", SEMI, NULL, 0);
    return SEMI;
}
"," {
    yylval.node = newASTNode(yylineno, "COMMA", COMMA, NULL, 0);
    return COMMA;
}
"=" {
    yylval.node = newASTNode(yylineno, "ASSIGN", ASSIGN, NULL, 0);
    return ASSIGN;
}
">" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "GT", GT, s, 0);
    return GT;
}
"<" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "LT", LT, s, 0);
    return LT;
}
">=" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "GE", GE, s, 0);
    return GE;
}
"<=" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "LE", LE, s, 0);
    return LE;
}
"==" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "EQ", EQ, s, 0);
    return EQ;
}
"!=" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "NE", NE, s, 0);
    return NE;
}
"+" {
    yylval.node = newASTNode(yylineno, "PLUS", PLUS, NULL, 0);
    return PLUS;
}
"-" {
    yylval.node = newASTNode(yylineno, "MINUS", MINUS, NULL, 0);
    return MINUS;
}
"*" {
    yylval.node = newASTNode(yylineno, "MUL", MUL, NULL, 0);
    return MUL;
}
"/" {
    yylval.node = newASTNode(yylineno, "DIV", DIV, NULL, 0);
    return DIV;
}
"&&" {
    yylval.node = newASTNode(yylineno, "AND", AND, NULL, 0);
    return AND;
}
"||" {
    yylval.node = newASTNode(yylineno, "OR", OR, NULL, 0);
    return OR;
}
"!" {
    yylval.node = newASTNode(yylineno, "NOT", NOT, NULL, 0);
    return NOT;
}
"(" {
    yylval.node = newASTNode(yylineno, "LP", LP, NULL, 0);
    return LP;
}
")" {
    yylval.node = newASTNode(yylineno, "RP", RP, NULL, 0);
    return RP;
}
"[" {
    yylval.node = newASTNode(yylineno, "LB", LB, NULL, 0);
    return LB;
}
"]" {
    yylval.node = newASTNode(yylineno, "RB", RB, NULL, 0);
    return RB;
}
"{" {
    yylval.node = newASTNode(yylineno, "LC", LC, NULL, 0);
    return LC;
}
"}" {
    yylval.node = newASTNode(yylineno, "RC", RC, NULL, 0);
    return RC;
}
[\n\r] {
    yycolumn = 1;
}
[ \t] {}
. {
    ERROR_A();
    return LEXEME_ERROR;
}

%%
