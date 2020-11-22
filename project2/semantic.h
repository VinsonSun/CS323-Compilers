#ifndef SEMANTIC_H
#define SEMANTIC_H
#define HASH_TABLE_SIZE 0x3fff

#include "type.h"

typedef struct Type Type;
typedef struct FieldList FieldList;
typedef struct Var_hash_node Var_hash_node;
typedef struct Func_hash_node Func_hash_node;
typedef struct Type_node Type_node;
typedef struct Var_list_node Var_list_node;

Var_hash_node *var_hash_table[HASH_TABLE_SIZE + 1];
Func_hash_node *func_hash_table[HASH_TABLE_SIZE + 1];

typedef struct ASTNode ASTNode;

void semantic_func();
Var_hash_node* get_var_hash_node(char *key);
Func_hash_node* get_func_hash_node(char *key);
Type *get_exp_type(ASTNode *node);

#endif
