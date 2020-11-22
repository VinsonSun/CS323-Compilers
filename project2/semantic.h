#ifndef SEMANTIC_H
#define SEMANTIC_H
#define HASH_TABLE_SIZE 0x3fff

enum{
    INT_TYPE, FLOAT_TYPE, CHAR_TYPE
};

typedef struct Type{
    enum{BASIC, ARRAY, STRUCTURE} kind;
    union{
        int basic;
        struct{
            Type* elem;
            int size;
        }array;
        FieldList* structure;
    }u;
};

typedef struct FieldList{
    char* name;
    Type* type;
    FieldList *next;
};

typedef struct Var_hash_node
{
    char *name;
    int line;
    int depth;
    Type *type;
    struct _Operand *op;
    Var_hash_node *next;
    Var_hash_node *last;
};

typedef struct Type_node{
    Type *type;
    Type_node *next;
    char *name;
};

typedef struct Func_hash_node{
    char *name;
    int line;
    int whether_dec;
    int whether_def;
    Func_hash_node *next;
    Func_hash_node *last;
    Type *return_type;
    Type_node* para_type_list;
};

typedef struct Var_list_node{
    Var_hash_node *node;
    Var_list_node *next;
};

typedef struct ASTNode ASTNode;

Var_hash_node *var_hash_table[HASH_TABLE_SIZE + 1];
Func_hash_node *func_hash_table[HASH_TABLE_SIZE + 1];
void semantic_func();
Var_hash_node* get_var_hash_node(char *key);
Func_hash_node* get_func_hash_node(char *key);
Type *get_exp_type(ASTNode *node);

#endif
