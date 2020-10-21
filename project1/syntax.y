%{
    #include "lex.yy.c"
    #include <stdio.h>
    #include "ast.h"
    void yyerror(const char*);
%}

%error-verbose
%locations
%union {
    ASTNode* node;
}

/* declared tokens */
%token <node> LEXEME_ERROR

%token <node> INT FLOAT CHAR
%token <node> ID TYPE
%token <node> DOT SEMI COMMA
%token <node> ASSIGN LE LT GE GT NE EQ PLUS MINUS STAR DIV AND OR NOT
%token <node> LP RP LB RB LC RC
%token <node> STRUCT RETURN IF ELSE WHILE

%type <node> Program ExtDefList ExtDef ExtDecList
%type <node> Specifier StructSpecifier
%type <node> VarDec FunDec VarList ParamDec
%type <node> CompSt StmtList Stmt
%type <node> DefList Def DecList Dec
%type <node> Exp Args

%nonassoc error
%right ASSIGN
%left OR
%left AND
%left LE LT GE GT NE EQ
%left PLUS MINUS
%left STAR DIV
%right NOT UMINUS
%left LP RP LB RB DOT

%%


/* High-level Definition */
Program : 
        ExtDefList{
            $$ = newASTNode(@1.first_line, "Program", 0, NULL, 1, $1);
            root = $$;
        }
    ;

ExtDefList : 
        ExtDef ExtDefList{ $$ = newASTNode(@1.first_line, "ExtDefList", 0, NULL, 2, $1, $2);}
    |   { $$ = NULL; }
    ;

ExtDef : 
        Specifier ExtDecList SEMI{ $$ = newASTNode(@1.first_line, "ExtDef", 0, NULL, 3, $1, $2, $3); }
    |   Specifier SEMI{ $$ = newASTNode(@1.first_line, "ExtDef", 0, NULL, 2, $1, $2); }
    |   Specifier FunDec CompSt{ $$ = newASTNode(@1.first_line, "ExtDef", 0, NULL, 3, $1, $2, $3); }
    ;

ExtDecList : 
        VarDec{ $$ = newASTNode(@1.first_line, "ExtDecList", 0, NULL, 1, $1);}
    |   VarDec COMMA ExtDecList{ $$ = newASTNode(@1.first_line, "ExtDecList", 0, NULL, 3, $1, $2, $3); }
    ;

/* Specifiers */
Specifier : 
        TYPE{ $$ = newASTNode(@1.first_line, "Specifier", 0, NULL, 1, $1); }
    |   StructSpecifier{ $$ = newASTNode(@1.first_line, "Specifier", 0, NULL, 1, $1); }
    ;

StructSpecifier : 
        STRUCT ID LC DefList RC{ $$ = newASTNode(@1.first_line, "StructSpecifier", 0, NULL, 5, $1, $2, $3, $4, $5); }
    |   STRUCT ID{ $$ = newASTNode(@1.first_line, "StructSpecifier", 0, NULL, 2, $1, $2); }
    ;

/* Declarators */
VarDec : 
        ID { $$ = newASTNode(@1.first_line, "VarDec", 0, NULL, 1, $1);   }
    |   VarDec LB INT RB{ $$ = newASTNode(@1.first_line, "VarDec", 0, NULL, 4, $1, $2, $3, $4); }
    ;

FunDec : 
        ID LP VarList error { ERROR_B(@1.last_line, "Missing closing parenthesis ')'"); }
    |   ID LP VarList RP{ $$ = newASTNode(@1.first_line, "FunDec", 0, NULL, 4, $1, $2, $3, $4); }
    |   ID LP error { ERROR_B(@1.last_line, "Missing closing parenthesis ')'"); }   
    |   ID LP RP{ $$ = newASTNode(@1.first_line, "FunDec", 0, NULL, 3, $1, $2, $3); } 
    ;

VarList : 
        ParamDec COMMA VarList{ $$ = newASTNode(@1.first_line, "VarList", 0, NULL, 3, $1, $2, $3); }
    |   ParamDec{ $$ = newASTNode(@1.first_line, "VarList", 0, NULL, 1, $1); }
    ;

ParamDec : 
        Specifier VarDec{ $$ = newASTNode(@1.first_line, "ParamDec", 0, NULL, 2, $1, $2); }
    ;
    
    
/* Statements */
CompSt : 
        LC DefList StmtList RC{ $$ = newASTNode(@1.first_line, "CompSt", 0, NULL, 4, $1, $2, $3, $4); }
    |   LC DefList StmtList DefList error{ ERROR_B(@3.last_line, "Missing specifier"); }
    ;

StmtList : 
        Stmt StmtList{ $$ = newASTNode(@1.first_line, "StmtList", 0, NULL, 2, $1, $2); }
    |   {   $$ = NULL; }
    ;

Stmt : 
        Exp SEMI{ $$ = newASTNode(@1.first_line, "Stmt", 0, NULL, 2, $1, $2); }
    |   CompSt{ $$ = newASTNode(@1.first_line, "Stmt", 0, NULL, 1, $1); }
    |   RETURN Exp error { ERROR_B(@1.last_line, "Missing semicolon ';'"); }
    |   RETURN Exp SEMI{ $$ = newASTNode(@1.first_line, "Stmt", 0, NULL, 3, $1, $2, $3); }
    |   IF LP Exp RP Stmt{ $$ = newASTNode(@1.first_line, "Stmt", 0, NULL, 5, $1, $2, $3, $4, $5); }
    |   IF LP Exp RP Stmt ELSE Stmt{ $$ = newASTNode(@1.first_line, "Stmt", 0, NULL, 7, $1, $2, $3, $4, $5, $6, $7); }
    |   WHILE LP Exp RP Stmt{ $$ = newASTNode(@1.first_line, "Stmt", 0, NULL, 5, $1, $2, $3, $4, $5); }
    ;

/* Local Definitions */
DefList : 
        Def DefList{ $$ = newASTNode(@1.first_line, "DefList", 0, NULL, 2, $1, $2); }
    |   {$$ = NULL;}
    ;

Def : 
        Specifier DecList error { ERROR_B(@1.last_line, "Missing semicolon ';'"); }
    |   Specifier DecList SEMI{ $$ = newASTNode(@1.first_line, "Def", 0, NULL, 3, $1, $2, $3);}
    ;

DecList : 
        Dec{ $$ = newASTNode(@1.first_line, "DecList", 0, NULL, 1, $1); }
    |   Dec COMMA DecList{ $$ = newASTNode(@1.first_line, "DecList", 0, NULL, 3, $1, $2, $3); }
    ;

Dec : 
        VarDec{ $$ = newASTNode(@1.first_line, "Dec", 0, NULL, 1, $1); }
    |   VarDec ASSIGN Exp{ $$ = newASTNode(@1.first_line, "Dec", 0, NULL, 3, $1, $2, $3);}
    ;

/* Expressions */
Exp : 
        Exp ASSIGN Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   Exp AND Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   Exp OR Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   Exp GE Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }   
    |   Exp LT Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   Exp GT Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   Exp LE Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }   
    |   Exp EQ Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   Exp NE Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   Exp PLUS Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   Exp MINUS Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   Exp STAR Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   Exp DIV Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   LP Exp RP{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   MINUS Exp %prec UMINUS{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 2, $1, $2); }
    |   NOT Exp{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 2, $1, $2); }
    |   ID LP Args error { ERROR_B(@1.last_line, "Missing closing parenthesis ')'"); }
    |   ID LP Args RP{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 4, $1, $2, $3, $4); }
    |   ID LP RP{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   Exp LB Exp RB{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 4, $1, $2, $3, $4); }
    |   Exp DOT ID{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 3, $1, $2, $3); }
    |   ID{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 1, $1); }
    |   INT{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 1, $1); }
    |   FLOAT{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 1, $1);}
    |   CHAR{ $$ = newASTNode(@1.first_line, "Exp", 0, NULL, 1, $1); }
    |   Exp LEXEME_ERROR Exp {}
    |   LEXEME_ERROR {}
    ;

Args : 
        Exp COMMA Args{ $$ = newASTNode(@1.first_line, "Args", 0, NULL, 3, $1, $2, $3); }
    |   Exp{ $$ = newASTNode(@1.first_line, "Args", 0, NULL, 1, $1); }
    ;

%%

void yyerror(const char *s){
}
