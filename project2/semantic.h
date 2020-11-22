#ifndef SEMANTIC_H
#define SEMANTIC_H
#define HASH_TABLE_SIZE 0x3fff

#include "type.h"

typedef struct ASTNode ASTNode;

void semantic_func();
Var_hash_node* get_var_hash_node(char *key);
Func_hash_node* get_func_hash_node(char *key);
Type *get_exp_type(ASTNode *node);

#endif
