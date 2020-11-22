#ifndef TYPE_H
#define TYPE_H

enum{
    INT_TYPE, FLOAT_TYPE, CHAR_TYPE
};

struct Type{
    enum{BASIC, ARRAY, STRUCTURE} kind;
    union{
        int basic;
        struct{
            Type* ele;
            int size;
        }array;
        FieldList* structure;
    }u;
};

struct FieldList{
    char* name;
    Type* type;
    FieldList *next;
};

struct Var_hash_node
{
    char *name;
    int line;
    int depth;
    Type *type;
    struct _Operand *op;
    Var_hash_node *next;
    Var_hash_node *last;
};

struct Type_node{
    Type *type;
    Type_node *next;
    char *name;
};

struct Func_hash_node{
    char *name;
    int line;
    int whether_dec;
    int whether_def;
    Func_hash_node *next;
    Func_hash_node *last;
    Type *return_type;
    Type_node* para_type_list;
};

struct Var_list_node{
    Var_hash_node *node;
    Var_list_node *next;
};

#endif
