%{
    #include "lex.yy.c"
    #include <stdio.h>
    #include "ast.h"
    extern int error_num;
%}

%error-verbose
%locations

%union {
    ASTNode* node;
}

/* declared tokens */
%token <node> INT FLOAT CHAR ID
%token <node> SEMI COMMA
%token <node> ASSIGN LE LT GE GT NE EQ PLUS MINUS STAR DIV AND OR DOT NOT
%token <node> TYPE
%token <node> LP RP LB RB LC RC
%token <node> STRUCT RETURN IF ELSE WHILE

%type <node> Program ExtDefList ExtDef ExtDecList
%type <node> Specifier StructSpecifier
%type <node> VarDec FunDec VarList ParamDec
%type <node> CompSt StmtList Stmt
%type <node> DefList Def DecList Dec
%type <node> Exp Args


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
Program : ExtDefList{
    if($1 == NULL){
        $$ = newASTNode(yylineno, "Program", NULL);
    }
    else {
        $$ = newASTNode(@1.first_line, "Program", NULL);
    }
    addChild($$, $1);
    root = $$;
}
    ;

ExtDefList : ExtDef ExtDefList{
    $$ = newASTNode(@1.first_line, "ExtDefList", NULL);
    addChild($$, $1);
    addChild($$, $2);
}
    |{
    $$ = NULL;
}
    ;

ExtDef : Specifier ExtDecList SEMI{
    $$ = newASTNode(@1.first_line, "ExtDef", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Specifier SEMI{
    $$ = newASTNode(@1.first_line, "ExtDef", NULL);
    addChild($$, $1);
    addChild($$, $2);
}
    | Specifier FunDec CompSt{
    $$ = newASTNode(@1.first_line, "ExtDef", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Specifier FunDec SEMI{
    $$ = newASTNode(@1.first_line, "ExtDef", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
    }
    ;

ExtDecList : VarDec{
    $$ = newASTNode(@1.first_line, "ExtDecList", NULL);
    addChild($$, $1);
}
    | VarDec COMMA ExtDecList{
    $$ = newASTNode(@1.first_line, "ExtDecList", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    ;

/* Specifiers */
Specifier : TYPE{
    $$ = newASTNode(@1.first_line, "Specifier", NULL);
    addChild($$, $1);
}
    | StructSpecifier{
    $$ = newASTNode(@1.first_line, "Specifier", NULL);
    addChild($$, $1);
}
    ;

StructSpecifier : STRUCT ID LC DefList RC{
    $$ = newASTNode(@1.first_line, "StructSpecifier", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
    addChild($$, $4);
    addChild($$, $5);
}
    | STRUCT ID{
    $$ = newASTNode(@1.first_line, "StructSpecifier", NULL);
    addChild($$, $1);
    addChild($$, $2);
}
    ;

/* Declarators */
VarDec : ID{
    $$ = newASTNode(@1.first_line, "VarDec", NULL);
    addChild($$, $1);
}
    | VarDec LB INT RB{
    $$ = newASTNode(@1.first_line, "VarDec", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
    addChild($$, $4);
}
    | VarDec LB INT error{}
    ;

FunDec : ID LP VarList RP{
    $$ = newASTNode(@1.first_line, "FunDec", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
    addChild($$, $4);
}
    | ID LP RP{
    $$ = newASTNode(@1.first_line, "FunDec", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    ;

VarList : ParamDec COMMA VarList{
    $$ = newASTNode(@1.first_line, "VarList", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | ParamDec{
    $$ = newASTNode(@1.first_line, "VarList", NULL);
    addChild($$, $1);
}
    ;

ParamDec : Specifier VarDec{
    $$ = newASTNode(@1.first_line, "ParamDec", NULL);
    addChild($$, $1);
    addChild($$, $2);
}

/* Statements */
CompSt : LC DefList StmtList RC{
    $$ = newASTNode(@1.first_line, "CompSt", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
    addChild($$, $4);
}
    | error RC{}
    | LC DefList StmtList error{}
    ;

StmtList : Stmt StmtList{
    $$ = newASTNode(@1.first_line, "StmtList", NULL);
    addChild($$, $1);
    addChild($$, $2);
}
    |{
    $$ = NULL;
}
    ;

Stmt : Exp SEMI{
    $$ = newASTNode(@1.first_line, "Stmt", NULL);
    addChild($$, $1);
    addChild($$, $2);
}

    | CompSt{
    $$ = newASTNode(@1.first_line, "Stmt", NULL);
    addChild($$, $1);
}
    | RETURN Exp SEMI{
    $$ = newASTNode(@1.first_line, "Stmt", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}

    | IF LP Exp RP Stmt{
    $$ = newASTNode(@1.first_line, "Stmt", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
    addChild($$, $4);
    addChild($$, $5);
}
    | IF LP Exp RP Stmt ELSE Stmt{
    $$ = newASTNode(@1.first_line, "Stmt", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
    addChild($$, $4);
    addChild($$, $5);
    addChild($$, $6);
    addChild($$, $7);
}
    | WHILE LP Exp RP Stmt{
    $$ = newASTNode(@1.first_line, "Stmt", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
    addChild($$, $4);
    addChild($$, $5);
}
    | error SEMI{}
    ;

/* Local Definitions */
DefList : Def DefList{
    $$ = newASTNode(@1.first_line, "DefList", NULL);
    addChild($$, $1);
    addChild($$, $2);
}
    |{
    $$ = NULL;
}
    ;

Def : Specifier DecList SEMI{
    $$ = newASTNode(@1.first_line, "Def", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    ;

DecList : Dec{
    $$ = newASTNode(@1.first_line, "DecList", NULL);
    addChild($$, $1);
}
    | Dec COMMA DecList{
    $$ = newASTNode(@1.first_line, "DecList", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    ;

Dec : VarDec{
    $$ = newASTNode(@1.first_line, "Dec", NULL);
    addChild($$, $1);
}
    | VarDec ASSIGN Exp{
    $$ = newASTNode(@1.first_line, "Dec", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    ;

/* Expressions */
Exp : Exp ASSIGN Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Exp AND Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Exp OR Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Exp GE Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}   
    | Exp LT Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Exp GT Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Exp LE Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}   
    | Exp EQ Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Exp NE Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Exp PLUS Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Exp MINUS Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Exp STAR Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Exp DIV Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | LP Exp RP{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | MINUS Exp %prec UMINUS{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
}
    | NOT Exp{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
}
    | ID LP Args RP{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
    addChild($$, $4);
}
    | ID LP RP{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Exp LB Exp RB{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
    addChild($$, $4);
}
    | Exp DOT ID{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | ID{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
}
    | INT{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
}
    | CHAR{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
}
    | FLOAT{
    $$ = newASTNode(@1.first_line, "Exp", NULL);
    addChild($$, $1);
}
    | error RP{}
    | Exp LB Exp error{}
    ;

Args : Exp COMMA Args{
    $$ = newASTNode(@1.first_line, "Args", NULL);
    addChild($$, $1);
    addChild($$, $2);
    addChild($$, $3);
}
    | Exp{
    $$ = newASTNode(@1.first_line, "Args", NULL);
    addChild($$, $1);
}
    ;

%%

void yyerror(char const *msg){
    error_num++;
    printf("Error type B at Line %d: %s.\n", yylineno, msg);
}
