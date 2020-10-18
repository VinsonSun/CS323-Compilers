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

%option yylineno

%x IN_COMMENT
    /* keywords */
TYPE    "int"|"float"|"char"
STRUCT  "struct"
IF      "if"
ELSE    "else"
WHILE   "while"
RETURN  "return"
DOT     "."
SEMI    ";"
COMMA   ","
ASSIGN  "="
LT      "<"
LE      "<="
GT      ">"
GE      ">="
NE      "!="
EQ      "=="
PLUS    "+"
MINUS   "-"
MUL     "*"
DIV     "/"
AND     "&&"
OR      "||"
NOT     "!"
LP      "("
RP      ")"
LB      "["
RB      "]"
LC      "{"
RC      "}"

INT                 [+-]?[0-9]+
HEX_INT             [+-]?0x[0-9a-fA-F]+
WRONG_HEX_INT       [+-]?0x[0-9a-zA-Z]+

FLOAT               [-+]?(([0-9]+\.?[0-9]*)|([0-9]*\.?[0-9]+))

CHAR                '(([ -~])|(\\x[0-9a-fA-F]{2}))'
WRONG_HEX_CHAR      '\\x[0-9a-zA-Z]*'
ID                  [_a-zA-Z][_a-zA-Zs0-9]*
WRONG_ID            [_a-zA-Zs0-9]*

SINGLE_LINE_COMMENT \/\/[^\n]*
MULTI_LINE_COMMENT  \/\*.*\*\/

%%

{STRUCT} {
    yylval.node = newASTNode(yylineno, "STRUCT", STRUCT, NULL, 0);
    return STRUCT;
}
{RETURN} {
    yylval.node = newASTNode(yylineno, "RETURN", RETURN, NULL, 0);
    return RETURN;
}
{IF} {
    yylval.node = newASTNode(yylineno, "IF", IF, NULL, 0);
    return IF;
}
{ELSE} {
    yylval.node = newASTNode(yylineno, "ELSE", ELSE, NULL, 0);
    return ELSE;
}
{WHILE} {
    yylval.node = newASTNode(yylineno, "WHILE", WHILE, NULL, 0);
    return WHILE;
}
{TYPE} {
    char *s = malloc(strlen(yytext) + 1);
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "TYPE", TYPE, s, 0);
    return TYPE;
}
{INT} {
    unsigned int val = atol(yytext);
    yylval.node = newASTNode(yylineno, "INT", INT, &val, 0);
    return INT;
}
{FLOAT} {
    float val = strtof(yytext, NULL);
    yylval.node = newASTNode(yylineno, "FLOAT", FLOAT, &val, 0);
    return FLOAT;
}
{WRONG_HEX_INT} {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, yytext);
    error_num++;
    int val = 0;
    yylval.node = newASTNode(yylineno, "ERROR", ERROR, NULL, 0);
    return Error;
}
{HEX_INT} {
    unsigned int val = 0;
    sscanf(yytext, "%x", &val);
    yylval.node = newASTNode(yylineno, "INT", INT, &val, 0);
    return INT;
}
{ID} {
    char *s = malloc(strlen(yytext) + 1);
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "ID", ID, s, 0);
    return ID;
}
{WRONG_ID} {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, yytext);
    yylval.node = newASTNode(yylineno, "ERROR", ERROR, NULL, 0);
    return Error;
}
{CHAR} {
    char *s = malloc(strlen(yytext) + 1);
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "CHAR", CHAR, s, 0);
    return CHAR;
}
{WRONG_HEX_CHAR} {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, yytext);
    yylval.node = newASTNode(yylineno, "ERROR", ERROR, NULL, 0);
    return Error;
    
}
{SEMI} {
    yylval.node = newASTNode(yylineno, "SEMI", SEMI, NULL, 0);
    return SEMI;
}
{COMMA} {
    yylval.node = newASTNode(yylineno, "COMMA", COMMA, NULL, 0);
    return COMMA;
}
{ASSIGN} {
    yylval.node = newASTNode(yylineno, "ASSIGN", ASSIGN, NULL, 0);
    return ASSIGN;
}
{GT} {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "GT", GT, s, 0);
    return GT;
}
{LT} {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "LT", LT, s, 0);
    return LT;
}
{GE} {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "GE", GE, s, 0);
    return GE;
}
{LE} {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "LE", LE, s, 0);
    return LE;
}
{EQ} {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "EQ", EQ, s, 0);
    return EQ;
}
{NE} {
    char s[3] = "";
    strcpy(s, yytext);
    yylval.node = newASTNode(yylineno, "NE", NE, s, 0);
    return NE;
}

{PLUS} {
    yylval.node = newASTNode(yylineno, "PLUS", PLUS, NULL, 0);
    return PLUS;
}
{MINUS} {
    yylval.node = newASTNode(yylineno, "MINUS", MINUS, NULL, 0);
    return MINUS;
}
{MUL} {
    yylval.node = newASTNode(yylineno, "STAR", STAR, NULL, 0);
    return STAR;
}
{DIV} {
    yylval.node = newASTNode(yylineno, "DIV", DIV, NULL, 0);
    return DIV;
}
{AND} {
    yylval.node = newASTNode(yylineno, "AND", AND, NULL, 0);
    return AND;
}
{OR} {
    yylval.node = newASTNode(yylineno, "OR", OR, NULL, 0);
    return OR;
}
{DOT} {
    yylval.node = newASTNode(yylineno, "DOT", DOT, NULL, 0);
    return DOT;
}
{NOT} {
    yylval.node = newASTNode(yylineno, "NOT", NOT, NULL, 0);
    return NOT;
}
{LP} {
    yylval.node = newASTNode(yylineno, "LP", LP, NULL, 0);
    return LP;
}
{RP} {
    yylval.node = newASTNode(yylineno, "RP", RP, NULL, 0);
    return RP;
}
{LB} {
    yylval.node = newASTNode(yylineno, "LB", LB, NULL, 0);
    return LB;
}
{RB} {
    yylval.node = newASTNode(yylineno, "RB", RB, NULL, 0);
    return RB;
}
{LC} {
    yylval.node = newASTNode(yylineno, "LC", LC, NULL, 0);
    return LC;
}
{RC} {
    yylval.node = newASTNode(yylineno, "RC", RC, NULL, 0);
    return RC;
}
{SINGLE_LINE_COMMENT}   ;

"/*"  BEGIN(IN_COMMENT);

\n      ;
[\t ]+ ;
.       {
    printf("Error type A at Line %d: unknown lexeme %s\n", yylineno, yytext);
    yylval.node = newASTNode(yylineno, "ERROR", ERROR, NULL, 0);
    return Error;
}
<IN_COMMENT>{
"*/"      BEGIN(INITIAL);
[^*\n]+   // eat comment in chunks
"*"       // eat the lone star
\n        ;
}
%%
