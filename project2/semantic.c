#include "semantic.h"
#include "ast.h"
#include "syntax.tab.h"
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <stdio.h>


Type* handle_VarDec(ASTNode  *node, Type *basic_type);
Type* handle_StructSpecifier(ASTNode  *node);
Type* handle_Specifier(ASTNode  *node);
Type_node* handle_ParamDec(ASTNode  *node);
Type_node* handle_VarList(ASTNode  *node);
void handle_FunDec(ASTNode  *node, Type *return_type, int defined);
void handle_ExtDef(ASTNode  *node);
void handle_Def(ASTNode  *node);
Type *get_exp_type(ASTNode  *node);
void handle_Stmt(ASTNode  *node, Type *correct_type);
void handle_CompSt(ASTNode  *node, Type *correct_type, int func_flag);
int cur_depth = 0;

unsigned int hash_func(char *name){
    unsigned int val = 0;
    for(; *name; ++name){
        val = (val << 2) + *name;
        unsigned int i = val & ~HASH_TABLE_SIZE;
        if(i)
            val = (val ^ (i >> 12)) & HASH_TABLE_SIZE;
    }
    //printf("%d\n", val);
    return val;
}

Var_hash_node* get_var_hash_node(char *key){
    int id = hash_func(key);
    Var_hash_node *tmp = var_hash_table[id];
    Var_hash_node *ans = NULL;
    while(tmp != NULL){
        if(strcmp(key, tmp->name) == 0){
            ans = tmp;
        }
        tmp = tmp->next;
    }
    return ans;
}

Func_hash_node* get_func_hash_node(char *key){
    int id = hash_func(key);
    Func_hash_node *tmp = func_hash_table[id];
    while(tmp != NULL){
        if(strcmp(key, tmp->name) == 0){
            return tmp;
        }
        else{
            tmp = tmp->next;
        }
    }
    return NULL;
}

void semantic_error(int error_type, int line, char *name){
    char msg[100] = "\0";
    if(error_type == 1)
        sprintf(msg, "undefined variable: %s", name);
    else if(error_type == 2)
        sprintf(msg, "undefined function: %s", name);
    else if(error_type == 3)
        sprintf(msg, "redefine variable: %s", name);
    else if(error_type == 4)
        sprintf(msg, "redefine function: %s", name);
    else if(error_type == 5)
        sprintf(msg, "unmatching type on both sides of assignment");
    else if(error_type == 6)
        sprintf(msg, "left side in assignment is rvalue");
    else if(error_type == 7)
        sprintf(msg, "binary operation on non-number variables");
    else if(error_type == 8)
        sprintf(msg, "incompatiable return type");
    else if(error_type ==9)
        sprintf(msg, "%s", name);
    else if(error_type == 10)
        sprintf(msg, "indexing on non-array variable");
    else if(error_type == 11)
        sprintf(msg, "invoking non-function variable: %s", name);
    else if(error_type == 12)
        sprintf(msg, "indexing by non-integer");
    else if(error_type == 13)
        sprintf(msg, "accessing with non-struct variable");
    else if(error_type == 14)
        sprintf(msg, "no such member: %s", name);
    else if(error_type == 15)
        sprintf(msg, "redefine struct: %s", name);
    printf("Error type %d at Line %d: %s\n", error_type, line, msg);
}

void table_init(){
    for(int i = 0; i <= HASH_TABLE_SIZE; i++){
        var_hash_table[i] = NULL;
        func_hash_table[i] = NULL;
    }
}

static void node_type_check(ASTNode  *node, char *correct_name){
    if(node == NULL)
        printf("Error: %s NULL node\n", correct_name);
    node->status = 1;
    if(strcmp(node->name, correct_name) != 0){
        printf("It is a '%s' Node, not a '%s' Node\n",node->name, correct_name);
    }
}

Type* my_int_type = NULL;;
Type* my_float_type = NULL;
Type* new_type(int basic){
    if(basic == INT_TYPE){
        if(my_int_type == NULL){
            my_int_type = malloc(sizeof(Type));
            my_int_type->kind = BASIC;
            my_int_type->u.basic = INT_TYPE;
        }
        return my_int_type;
    }
    else if(basic == FLOAT_TYPE){
        if(my_float_type == NULL){
            my_float_type = malloc(sizeof(Type));
            my_float_type->kind = BASIC;
            my_float_type->u.basic = FLOAT_TYPE;
        }
        return my_float_type;
    }
    printf("Unknown basic type\n");
    return NULL;
}

int type_equal(Type *a, Type *b){
    if(a == NULL || b == NULL){
        //error has been detected
        return 1;
    }
    if(a->kind != b->kind){
        return 0;
    }
    else{
        if(a->kind == BASIC){
            return a->u.basic == b->u.basic;
        }
        else if(a->kind == ARRAY){
            return type_equal(a->u.array.elem, b->u.array.elem);
        }
        else if(a->kind == STRUCTURE){
            FieldList *tmpa = a->u.structure;
            FieldList *tmpb = b->u.structure;
            while(tmpa != NULL && tmpb != NULL){
                if(type_equal(tmpa->type, tmpb->type)){
                    tmpa = tmpa->next;
                    tmpb = tmpb->next;
                }
                else return 0;
            }
            if(tmpa != NULL || tmpb != NULL)
                return 0;
            else return 1;
        }
    }
    return 0;
}


void insert_to_val_table(char *name, int line, Type *type){
    Var_hash_node *existed_node = get_var_hash_node(name);
    if(existed_node != NULL){
        if(type->kind == STRUCTURE){
            semantic_error(15, line, name);
            return;
        }
        else if(existed_node->type->kind == STRUCTURE){
            semantic_error(3, line, name);
        }
        else {
            //in the same scope
            if(existed_node->depth == cur_depth){
                semantic_error(3, line, name);
                return;
            }
        }
    }
    unsigned int i = hash_func(name);
    Var_hash_node *node = malloc(sizeof(Var_hash_node));
    node->name = malloc(strlen(name) + 1);
    strcpy(node->name, name);
    node->next = node->last = NULL;
    node->line = line;
    node->type = type;
    node->depth = cur_depth;
    node->op = NULL;
    if(var_hash_table[i] == NULL){
        var_hash_table[i] = node;
    }
    else{
        Var_hash_node *tmp = var_hash_table[i];
        while(tmp->next != NULL){
            tmp = tmp->next;
        }
        node->last = tmp;
        tmp->next = node;
    }
}

int paralist_equal(Type_node *para1, Type_node *para2){
    while(para1 != NULL && para2 != NULL){
        if(!type_equal(para1->type, para2->type))
            return 0;
        else{
            para1 = para1->next;
            para2 = para2->next;
        }
    }
    if(para1 != NULL || para2 != NULL)
        return 0;
    else return 1;
}


int func_equal(Func_hash_node *func1, Func_hash_node *func2){
    if(type_equal(func1->return_type, func2->return_type)){
        if(paralist_equal(func1->para_type_list, func2->para_type_list))
            return 1;
    }
    return 0;
}

void insert_to_func_table(char *name, int line, Type *return_type, Type_node* para_type_list, int defined){
    unsigned int i = hash_func(name);
    Func_hash_node *node = malloc(sizeof(Func_hash_node));
    node->name = malloc(strlen(name) + 1);
    strcpy(node->name, name);
    node->next = node->last = NULL;
    node->whether_dec = 0;
    node->whether_def = defined;
    node->line = line;
    node->return_type = return_type;
    node->para_type_list = para_type_list;
    if(func_hash_table[i] == NULL){
        func_hash_table[i] = node;
    }
    else{
        Func_hash_node *tmp = func_hash_table[i];
        while(tmp->next != NULL){
            tmp = tmp->next;
        }
        node->last = tmp;
        tmp->next = node;
    }
}

ASTNode* get_id_node(ASTNode  *Vardec){
    node_type_check(Vardec, "VarDec");
    ASTNode  *tmp = Vardec;
    while(tmp->type != ID){
        tmp = tmp->child[0];
    }
    return tmp;
}

static Type* get_id_type(ASTNode  *Vardec, Type *basic_type){
    node_type_check(Vardec, "VarDec");
    Type *ans = basic_type;
    while(Vardec->childNum == 4){
        Type *new_type = malloc(sizeof(Type));
        new_type->kind = ARRAY;
        new_type->u.array.size = Vardec->child[2]->val.intVal;
        new_type->u.array.elem = ans;
        ans = new_type;
        Vardec = Vardec->child[0];
    }
    return ans;
}

Type* get_field_type(FieldList *field, char *id){
    FieldList *tmp = field;
    while(tmp != NULL){
        if(strcmp(tmp->name, id) == 0){
            return tmp->type;
        }
        tmp = tmp->next;
    }
    return NULL;
}

int equal_args_type(Type_node *para_list, ASTNode  *args){
    node_type_check(args, "Args");
    while(args != NULL && para_list != NULL){
        if(!type_equal(para_list->type, get_exp_type(args->child[0])))
            return 0;
        else{
            para_list = para_list->next;
            args = args->child[2];
        }
    }
    if(args != NULL || para_list != NULL)
        return 0;
    else return 1;
}

Type* handle_Func_exp(ASTNode  *node){
    node_type_check(node, "Exp");
    node_type_check(node->child[1], "LP");
    char *name = node->child[0]->val.stringVal;
    Func_hash_node *func = get_func_hash_node(name);
    if(func == NULL){
        if(get_var_hash_node(name) != NULL)
            semantic_error(11, node->line, name);
        else semantic_error(2, node->line, name);
        return NULL;
    }
    else{
        if(node->childNum == 3){
            if(func->para_type_list != NULL){
                semantic_error(9, node->line, name);
                return NULL;
            }
            else return func->return_type;
        }
        else if(node->childNum == 4){
            if(!equal_args_type(func->para_type_list, node->child[2])){
                int expect = 0;
                struct _Type_node *b = func->para_type_list;
                while(b!=NULL){
                    b=b->next;
                    expect++;
                }
                int got = node->child[2]->childNum;
                char error_msg[100]="\0";
                if(expect!=got){
                    sprintf(error_msg, "invalid argument number for %s, expect %d, got %d", name, expect,got);
                }else{
                    sprintf(error_msg, "invalid argument type for %s", name);
                }
                semantic_error(9, node->line, error_msg);
                return NULL;
            }
            else return func->return_type;
        }
    }
}


Type* get_exp_type(ASTNode* node){
    node_type_check(node, "Exp");
    if(node->childNum == 1){
        if(node->child[0]->type == ID){
            Var_hash_node *tmp = get_var_hash_node(node->child[0]->val.stringVal);
            if(tmp == NULL){
                semantic_error(1, node->line, node->child[0]->val.stringVal);
                return NULL;
            }
            return tmp->type;
        }
        else if(node->child[0]->type == FLOAT){
            return new_type(FLOAT_TYPE);
        }
        else if(node->child[0]->type == INT){
            return new_type(INT_TYPE);
        }
        else printf("Unknown type\n");
    }
    else if(node->childNum == 3){
        if(strcmp(node->child[0]->name, node->child[2]->name) == 0){
            //Exp xx Exp
            int oper = node->child[1]->type;
            Type *type1 = get_exp_type(node->child[0]);
            Type *type2 = get_exp_type(node->child[2]);
            if(oper == PLUS || oper == MINUS || oper == MUL || oper == DIV){
                if(type_equal(type1, type2)){
                    //Exp1.type == Exp2.type
                    if(type1 == NULL || type2 == NULL)
                        return NULL;
                    else return type1;
                }
                else{
                    semantic_error(7, node->line, NULL);
                    return NULL;
                }
            }
            else if(oper == AND || oper == OR){
                if(type1 == NULL || type2 == NULL)//error has occurred before
                    return NULL;
                if(type1->u.basic != INT_TYPE || type2->u.basic != INT_TYPE){
                    semantic_error(7, node->line, NULL);
                    return NULL;
                }
                else{
                    return new_type(INT_TYPE);
                }
            }
            else if(oper == NE|| oper==LE){
                if(type_equal(type1, type2)){
                    return new_type(INT_TYPE);
                }
                else{
                    semantic_error(7, node->line, NULL);
                    return NULL;
                }
            }
            else if(oper == ASSIGN){
                ASTNode  *exp = node->child[0];
                if(exp->childNum == 1 && exp->child[0]->type == ID
                   || exp->childNum == 3 && exp->child[1]->type == DOT
                   || exp->childNum == 4 && exp->child[1]->type == LB){
                    if(type_equal(type1, type2)){
                        //Exp1.type == Exp2.type
                        return type1;
                    }
                    else{
                        semantic_error(5, node->line, NULL);
                        return NULL;
                    }
                }
                else{
                    semantic_error(6, node->line, NULL);
                    return NULL;
                }
            }
        }
        else if(node->child[0]->type == LP){
            // LP Exp RP
            return get_exp_type(node->child[1]);
        }
        else if(node->child[1]->type == DOT){
            //Exp DOT ID TODO
            Type *type = get_exp_type(node->child[0]);
            if(type == NULL || type->kind != STRUCTURE){
                semantic_error(13, node->line, NULL);
            }
            else{
                char *id = node->child[2]->val.stringVal;
                Type *field_type = get_field_type(type->u.structure, id);
                if(field_type == NULL){
                    semantic_error(14, node->line, id);
                }
                return field_type;
            }
        }
        else if(node->child[0]->type == ID){
            //Func()
            return handle_Func_exp(node);
        }
    }
    else if(node->childNum == 2){
        if(node->child[0]->type == MINUS){
            return get_exp_type(node->child[1]);
        }
        else if(node->child[0]->type == NOT){
            Type *type = get_exp_type(node->child[1]);
            if(type == NULL)//error has occurred before
                return NULL;
            if(type->u.basic != INT_TYPE){
                semantic_error(7, node->line, NULL);
                return NULL;
            }
            else{
                return new_type(INT_TYPE);
            }
        }
    }
    else if(node->childNum == 4){
        if(node->child[0]->type == ID){
            //Func(args)
            return handle_Func_exp(node);
        }
        else if(node->child[1]->type == LB){
            Type *type = get_exp_type(node->child[0]);
            if(type == NULL || type->kind != ARRAY){
                semantic_error(10, node->line, "Exp");
                return NULL;
            }
            else if(!type_equal(get_exp_type(node->child[2]), my_int_type)){
                semantic_error(12, node->line, "Exp");
                return NULL;
            }
            return type->u.array.elem;
        }
    }
}

Type* handle_VarDec(ASTNode  *node, Type *basic_type){
    node_type_check(node, "VarDec");
    ASTNode  *ID_node = get_id_node(node);
    Type *ID_type = get_id_type(node, basic_type);
    insert_to_val_table(ID_node->val.stringVal, ID_node->line, ID_type);
    return ID_type;
}

FieldList* handle_struct_VarDec(ASTNode  *node, Type *basic_type){
    node_type_check(node, "VarDec");
    ASTNode  *ID_node = get_id_node(node);
    Type *ID_type = get_id_type(node, basic_type);
    FieldList *field = malloc(sizeof(FieldList));
    field->name = ID_node->val.stringVal;
    field->type = ID_type;
    field->next = NULL;
    return field;
}

Type* handle_StructSpecifier(ASTNode  *node){
    node_type_check(node, "StructSpecifier");
    Type *type = malloc(sizeof(Type));
    type->kind = STRUCTURE;
    type->u.structure = NULL;
    FieldList *last_node = type->u.structure;
    if(node->childNum == 5){
        ASTNode  *DefList = node->child[3];
        while(DefList != NULL && DefList->childNum == 2){
            DefList->status = 1;
            ASTNode  *Def = DefList->child[0];
            //handle type
            Type *basic_type = handle_Specifier(Def->child[0]);
            //handle variable
            ASTNode  *Declist_node = Def->child[1];
            while(1){
                ASTNode  *Dec_node = Declist_node->child[0];
                ASTNode  *Vardec_node = Dec_node->child[0];
                if(Dec_node->childNum == 1){
                    FieldList* field = handle_struct_VarDec(Vardec_node, basic_type);


                        if(last_node == NULL){
                            type->u.structure = last_node = field;
                        }
                        else{
                            last_node->next = field;
                            last_node = field;
                        }

                }
                if(Declist_node->childNum > 1){
                    Declist_node = Declist_node->child[2];
                }
                else break;
            }
            DefList = DefList->child[1];
        }
        if(node->child[1] != NULL){
            ASTNode  *id_node = node->child[1];
            insert_to_val_table(id_node->val.stringVal, id_node->line, type);
        }
    }
    else if(node->childNum == 2){
        char *name = node->child[1]->val.stringVal;
        Var_hash_node *hash_node = get_var_hash_node(name);
        type = hash_node->type;
    }
    return type;
}

Type* handle_Specifier(ASTNode  *node){
    node_type_check(node, "Specifier");
    Type *type;
    ASTNode  *type_node = node->child[0];
    if(type_node->type == TYPE){
        if(strcmp(type_node->val.stringVal, "int") == 0){
            type = new_type(INT_TYPE);
        }
        else if(strcmp(type_node->val.stringVal, "float") == 0){
            type = new_type(FLOAT_TYPE);
        }
    }
    else if(strcmp(type_node->name, "StructSpecifier") == 0){
        type = handle_StructSpecifier(type_node);

    }
    return type;
}

Type_node* handle_ParamDec(ASTNode  *node){
    node_type_check(node, "ParamDec");
    Type *type = handle_Specifier(node->child[0]);
    type = handle_VarDec(node->child[1], type);
    Type_node* type_node = malloc(sizeof(Type_node));
    ASTNode  *ID = get_id_node(node->child[1]);
    type_node->type = type;
    type_node->next = NULL;
    type_node->name = ID->val.stringVal;
    return type_node;
}

Type_node* handle_VarList(ASTNode  *node){
    node_type_check(node, "VarList");
    ASTNode  *cur_node = node;
    Type_node *type_node = handle_ParamDec(node->child[0]);
    if(node->childNum > 1){
        type_node->next = handle_VarList(node->child[2]);
    }
    return type_node;
}

void handle_FunDec(ASTNode  *node, Type *return_type, int defined){
    node_type_check(node, "FunDec");
    char *name = node->child[0]->val.stringVal;
    int line = node->child[0]->line;
    Type_node *para_list = NULL;
    if(node->childNum == 4){
        para_list = handle_VarList(node->child[2]);
    }
    Func_hash_node *old_func = get_func_hash_node(name);
    if(old_func == NULL)
        insert_to_func_table(name, line, return_type, para_list, defined);
    else{
        if(type_equal(return_type, old_func->return_type) && paralist_equal(para_list, old_func->para_type_list)){
            if(old_func->whether_def == 0){
                old_func->whether_def = defined;
            }
            else{
                if(defined == 1){//redefine function
                    semantic_error(4, node->line, name);
                }
            }
        }
        else{
            if(defined == 1 && old_func->whether_def == 1)
                semantic_error(4, node->line, name);
        }
    }
}

void handle_ExtDef(ASTNode  *node){//node shoule be a ExtDef
    node_type_check(node, "ExtDef");
    //handle type
    Type *basic_type = handle_Specifier(node->child[0]);
    //handle variable
    if(strcmp(node->child[1]->name, "ExtDecList") == 0){
        ASTNode *ExtDecList_node = node->child[1];
        while(1){
            ASTNode *Vardec_node = ExtDecList_node->child[0];
            handle_VarDec(Vardec_node, basic_type);
            if(ExtDecList_node->childNum > 1){
                ExtDecList_node = ExtDecList_node->child[2];
            }
            else break;
        }
    }
    else if(strcmp(node->child[1]->name, "FunDec") == 0){
        ASTNode *FunDec_node = node->child[1];
        if(node->child[2]->type == SEMI){
            handle_FunDec(FunDec_node, basic_type, 0);
        }
        else if(strcmp(node->child[2]->name, "CompSt") == 0){
            cur_depth++;
            handle_FunDec(FunDec_node, basic_type, 1);
            handle_CompSt(node->child[2], basic_type, 1);
        }
        else
            printf("Uknown FunDec\n");

    }
}

void handle_Def(ASTNode *node){
    node_type_check(node, "Def");
    //handle type
    Type *basic_type = handle_Specifier(node->child[0]);
    //handle variable
    ASTNode *Declist_node = node->child[1];
    while(1){
        ASTNode *Dec_node = Declist_node->child[0];
        ASTNode *Vardec_node = Dec_node->child[0];
        if(Dec_node->childNum == 1){
            handle_VarDec(Vardec_node, basic_type);
        }
            //Dec -> VarDec ASSIGNOP Exp
        else if(Dec_node->childNum == 3){
            Type *type = handle_VarDec(Vardec_node, basic_type);
            if(!type_equal(type, get_exp_type(Dec_node->child[2]))){
                semantic_error(5, Dec_node->line, NULL);
            }

        }
        if(Declist_node->childNum > 1){
            Declist_node = Declist_node->child[2];
        }
        else break;
    }
}

void handle_DefList(ASTNode *node){
    if(node == NULL)
        return;
    node_type_check(node, "DefList");
    ASTNode *DefList = node;
    while(DefList != NULL && DefList->childNum == 2){
        DefList->status = 1;
        handle_Def(DefList->child[0]);
        DefList = DefList->child[1];
    }
}

void handle_CompSt(ASTNode *node, Type *correct_type, int func_flag){
    node_type_check(node, "CompSt");
    if(!func_flag){//there is not a funcDec before it
        cur_depth++;
    }
    handle_DefList(node->child[1]);
    ASTNode *StmtList = node->child[2];
    while(StmtList != NULL && StmtList->childNum > 1){
        handle_Stmt(StmtList->child[0], correct_type);
        StmtList = StmtList->child[1];
    }
}

void handle_Stmt(ASTNode *node, Type *correct_type){
    node_type_check(node, "Stmt");
    if(node->child[1] != NULL && node->child[1]->type == LP){
        //IF/WHILE LP EXP RP
        if(!type_equal(my_int_type, get_exp_type(node->child[2])))
            semantic_error(7, node->line, NULL);
        handle_Stmt(node->child[4], correct_type);
        if(node->childNum == 7){
            handle_Stmt(node->child[6], correct_type);
        }
    }
    else if(node->child[0]->type == RETURN){
        if(!type_equal(correct_type, get_exp_type(node->child[1])))
            semantic_error(8, node->line, NULL);
    }
    else if(strcmp(node->child[0]->name, "CompSt") == 0){
        handle_CompSt(node->child[0], correct_type, 0);
    }
    else if(node->child[1]->type == SEMI){//Exp SEMI
        get_exp_type(node->child[0]);
    }
    else{
        printf("Error, unknown Stmt");
    }
}

void add_var(ASTNode *node){
    if(strcmp(node->name, "ExtDef") == 0){
        handle_ExtDef(node);
    }
    else if(strcmp(node->name, "DefList") == 0 && node->status == 0){
        handle_DefList(node);
    }
    else if(strcmp(node->name, "Exp") == 0){
        get_exp_type(node);
    }
}

static void tree_search(ASTNode *node){
    if(node == NULL || node->status == 1) return;
    add_var(node);
    for(int i = 0; i < node->childNum; i++){
        if(node->child[i] != NULL){
            tree_search(node->child[i]);
        }
    }
}

void semantic_func(){
    table_init();
    tree_search(root);
}
