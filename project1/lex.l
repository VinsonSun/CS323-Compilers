%{
    #include <stdlib.h>
    #include <string.h>
    #include <stdio.h>
    #include <math.h>
    #include "ast.h"
    #include "syntax.tab.h"
    int yycolumn = 1;
    extern int error_num;
    #define YY_USER_ACTION \
        yylloc.first_line = yylloc.last_line = yylineno; \
        yylloc.first_column = yycolumn; \
        yylloc.last_column = yycolumn + yyleng - 1; \
        yycolumn += yyleng;

%}

digit [0-9]
hex_head "0x"|"0X"
hex_char [0-9a-fA-F]
not_hex_char [g-zG-Z]
letter [_a-zA-Z]
%option yylineno

%%

"struct" {
    yylval.node = new_node(yylineno, "STRUCT", STRUCT, NULL, 0);
    return STRUCT;
}
"return" {
    yylval.node = new_node(yylineno, "RETURN", RETURN, NULL, 0);
    return RETURN;
}
"if" {
    yylval.node = new_node(yylineno, "IF", IF, NULL, 0);
    return IF;
}
"else" {
    yylval.node = new_node(yylineno, "ELSE", ELSE, NULL, 0);
    return ELSE;
}
"while" {
    yylval.node = new_node(yylineno, "WHILE", WHILE, NULL, 0);
    return WHILE;
}
"int"|"float"|"char" {
    char *s = malloc(strlen(yytext) + 1);
    strcpy(s, yytext);
    yylval.node = new_node(yylineno, "TYPE", TYPE, s, 0);
    return TYPE;
}
0|[1-9]{digit}* {
    unsigned int val = atol(yytext);
    yylval.node = new_node(yylineno, "INT", INT, &val, 0);
    return INT;
}
{digit}*\.{digit}*[eE][\+\-]?{digit}+ {
    float val = strtof(yytext, NULL);
    yylval.node = new_node(yylineno, "FLOAT", FLOAT, &val, 0);
    return FLOAT;
}
{digit}+\.{digit}+ {
    float val = strtof(yytext, NULL);
    yylval.node = new_node(yylineno, "FLOAT", FLOAT, &val, 0);
    return FLOAT;
}
{hex_head}[0-9a-zA-Z]*{not_hex_char}+[0-9a-zA-Z]* {
    printf("Error type A at Line %d: Illegal hexadecimal number '%s'.\n", yylineno, yytext);
    error_num++;
    int val = 0;
    yylval.node = new_node(yylineno, "INT", INT, &val, 0);
    return INT;
}
{hex_head}{hex_char}+ {
    unsigned int val = 0;
    sscanf(yytext, "%x", &val);
    yylval.node = new_node(yylineno, "INT", INT, &val, 0);
    return INT;
}
{letter}({digit}|{letter})* {
    char *s = malloc(strlen(yytext) + 1);
    strcpy(s, yytext);
    yylval.node = new_node(yylineno, "ID", ID, s, 0);
    return ID;
}
\'{letter}\' {
    char *s = malloc(strlen(yytext) + 1);
    strcpy(s, yytext);
    yylval.node = new_node(yylineno, "CHAR", CHAR, s, 0);
    return CHAR;
}
"//"[^\n]* {}
"/*" {
    char a = input(), b = input();
    while(a != '*' || b != '/'){
        a = b;
        b = input();
    }
 }
";" {
    yylval.node = new_node(yylineno, "SEMI", SEMI, NULL, 0);
    return SEMI;
}
"," {
    yylval.node = new_node(yylineno, "COMMA", COMMA, NULL, 0);
    return COMMA;
}
"=" {
    yylval.node = new_node(yylineno, "ASSIGN", ASSIGN, NULL, 0);
    return ASSIGN;
}
">" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = new_node(yylineno, "GT", GT, s, 0);
    return GT;
}
"<" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = new_node(yylineno, "LT", LT, s, 0);
    return LT;
}
">=" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = new_node(yylineno, "GE", GE, s, 0);
    return GE;
}
"<=" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = new_node(yylineno, "LE", LE, s, 0);
    return LE;
}
"==" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = new_node(yylineno, "EQ", EQ, s, 0);
    return EQ;
}
"!=" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = new_node(yylineno, "NE", NE, s, 0);
    return NE;
}

\+ {
    yylval.node = new_node(yylineno, "PLUS", PLUS, NULL, 0);
    return PLUS;
}
"-" {
    yylval.node = new_node(yylineno, "MINUS", MINUS, NULL, 0);
    return MINUS;
}
\* {
    yylval.node = new_node(yylineno, "STAR", STAR, NULL, 0);
    return STAR;
}
\/ {
    yylval.node = new_node(yylineno, "DIV", DIV, NULL, 0);
    return DIV;
}
"&&" {
    yylval.node = new_node(yylineno, "AND", AND, NULL, 0);
    return AND;
}
"||" {
    yylval.node = new_node(yylineno, "OR", OR, NULL, 0);
    return OR;
}
\. {
    yylval.node = new_node(yylineno, "DOT", DOT, NULL, 0);
    return DOT;
}
"!" {
    yylval.node = new_node(yylineno, "NOT", NOT, NULL, 0);
    return NOT;
}
\( {
    yylval.node = new_node(yylineno, "LP", LP, NULL, 0);
    return LP;
}
\) {
    yylval.node = new_node(yylineno, "RP", RP, NULL, 0);
    return RP;
}
\[ {
    yylval.node = new_node(yylineno, "LB", LB, NULL, 0);
    return LB;
}
\] {
    yylval.node = new_node(yylineno, "RB", RB, NULL, 0);
    return RB;
}
\{ {
    yylval.node = new_node(yylineno, "LC", LC, NULL, 0);
    return LC;
}
\} {
    yylval.node = new_node(yylineno, "RC", RC, NULL, 0);
    return RC;
}
\n {yycolumn = 1;}
[" "|\r|\t] {}
. {
    error_num++;
    printf("Error type A at line %d: Mysterious characters '%s'.\n", yylineno, yytext);
}

%%
