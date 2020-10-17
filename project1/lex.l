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
    yylval.node = newASTNode(yylineno, "STRUCT", NULL);
    return STRUCT;
}
"return" {
    yylval.node = newASTNode(yylineno, "RETURN", NULL);
    return RETURN;
}
"if" {
    yylval.node = newASTNode(yylineno, "IF", NULL);
    return IF;
}
"else" {
    yylval.node = newNode(yylineno, "ELSE", NULL);
    return ELSE;
}
"while" {
    yylval.node = newASTNode(yylineno, "WHILE", NULL);
    return WHILE;
}
"int"|"float"|"char" {
    char *s = malloc(strlen(yytext) + 1);
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "TYPE", s);
    return TYPE;
}
0|[1-9]{digit}* {
    unsigned int val = atol(yytext);
    yylval.node = newASTNode(yylineno, "INT", &val);
    return INT;
}
{digit}*\.{digit}*[eE][\+\-]?{digit}+ {
    float val = strtof(yytext, NULL);
    yylval.node = newASTNode(yylineno, "FLOAT", &val);
    return FLOAT;
}
{digit}+\.{digit}+ {
    float val = strtof(yytext, NULL);
    yylval.node = newASTNode(yylineno, "FLOAT", &val);
    return FLOAT;
}
{hex_head}[0-9a-zA-Z]*{not_hex_char}+[0-9a-zA-Z]* {
    printf("Error type A at Line %d: Illegal hexadecimal number '%s'.\n", yylineno, yytext);
    error_num++;
    int val = 0;
    yylval.node = newASTNode(yylineno, "INT", &val);
    return INT;
}
{hex_head}{hex_char}+ {
    unsigned int val = 0;
    sscanf(yytext, "%x", &val);
    yylval.node = newASTNode(yylineno, "INT", &val);
    return INT;
}
{letter}({digit}|{letter})* {
    char *s = malloc(strlen(yytext) + 1);
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "ID", s);
    return ID;
}
\'{letter}\' {
    char *s = malloc(strlen(yytext) + 1);
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "CHAR", s);
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
    yylval.node = newASTNode(yylineno, "SEMI", NULL);
    return SEMI;
}
"," {
    yylval.node = newASTNode(yylineno, "COMMA", NULL);
    return COMMA;
}
"=" {
    yylval.node = newASTNode(yylineno, "ASSIGN", NULL);
    return ASSIGN;
}
">" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "GT", s);
    return GT;
}
"<" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "LT", s);
    return LT;
}
">=" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "GE", s);
    return GE;
}
"<=" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "LE", s);
    return LE;
}
"==" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "EQ", s);
    return EQ;
}
"!=" {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "NE", s);
    return NE;
}

\+ {
    yylval.node = newASTNode(yylineno, "PLUS", NULL);
    return PLUS;
}
"-" {
    yylval.node = newASTNode(yylineno, "MINUS", NULL);
    return MINUS;
}
\* {
    yylval.node = newASTNode(yylineno, "STAR", NULL);
    return STAR;
}
\/ {
    yylval.node = newASTNode(yylineno, "DIV", NULL);
    return DIV;
}
"&&" {
    yylval.node = newASTNode(yylineno, "AND", NULL);
    return AND;
}
"||" {
    yylval.node = newASTNode(yylineno, "OR", NULL);
    return OR;
}
\. {
    yylval.node = newASTNode(yylineno, "DOT", NULL);
    return DOT;
}
"!" {
    yylval.node = newASTNode(yylineno, "NOT", NULL);
    return NOT;
}
\( {
    yylval.node = newASTNode(yylineno, "LP", NULL);
    return LP;
}
\) {
    yylval.node = newASTNode(yylineno, "RP", NULL);
    return RP;
}
\[ {
    yylval.node = newASTNode(yylineno, "LB", NULL);
    return LB;
}
\] {
    yylval.node = newASTNode(yylineno, "RB", NULL);
    return RB;
}
\{ {
    yylval.node = newASTNode(yylineno, "LC", NULL);
    return LC;
}
\} {
    yylval.node = newASTNode(yylineno, "RC", NULL);
    return RC;
}
\n {yycolumn = 1;}
[" "|\r|\t] {}
. {
    error_num++;
    printf("Error type A at line %d: Mysterious characters '%s'.\n", yylineno, yytext);
}

%%
