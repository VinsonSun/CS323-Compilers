#ifndef TRANSLATEH
#define TRANSLATEH 

#include "inter.h"
// #include "symbol.h"
#include"ast.h"

typedef struct arg_list_t arg_list;
typedef struct arglist_t arglist;

struct arg_list_t{
    operand* op;
    arg_list* next;
};

struct arglist_t{
    arg_list* head;
};

void translate_program(ASTNode* root);
void translate_extdeflist(ASTNode* root, intercodes* codes);
void translate_extdef(ASTNode* root, intercodes* codes);
void translate_compst(ASTNode* root, intercodes* codes);
void translate_stmtlist(ASTNode* root, intercodes* codes);
void translate_deflist(ASTNode* root, intercodes* codes);
void translate_def(ASTNode* root, intercodes* codes);
void translate_declist(ASTNode* root, intercodes* codes);
void translate_dec(ASTNode* root, intercodes* codes);
void translate_vardec(ASTNode* root, intercodes* codes);

symbol* struct_array_offset(ASTNode* root,int *offset,array_list** array_head,intercodes* codes,int *temp);
symbol* struct_array_type(ASTNode* root, int *dim);
intercodes* translate_array_struct1(ASTNode* root,operand* op);
intercodes* translate_array_struct2(ASTNode* root,operand* op);

intercodes* translate_exp(ASTNode* root,operand* op);
intercodes* translate_stmt(ASTNode* root);
intercodes* translate_cond(ASTNode* root,int label1,int label2);
intercodes* translate_args(ASTNode* root,arglist** arg_head);

intercodes* array_assignop(ASTNode* root);
int exp_int(ASTNode* root);
int exp_id(ASTNode* root);

#endif