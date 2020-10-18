#include "ast.h"
#include "syntax.tab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
int space_num = 0;


Node *new_node(int line, char *nodeName, int type, void *val, int childNum, ...){
    Node *node = malloc(sizeof(Node));
    node->line = line;
    node->type = type;
    node->visited = node->code_visited = 0;
    node->name = malloc(strlen(nodeName) + 1);
    strcpy(node->name, nodeName);
    
    va_list childs;
    if (childNum < 0) return node;
    va_start(childs, childNum);
    for(int i=0; i<childNum; i++) {
        node->child[i] = va_arg(childs, Node*);
        printf(node->child[i]->name);
    }
    va_end(childs);
    
    if(type == INT){
        node->val.i = *(int *)val;
    }else if(type == FLOAT){
        node->val.f = *(float *)val;
    }else if(type == CHAR){
        node->val.s = (char*)val;
    }else if(type == ID || type == TYPE || type == GT || type == LT || type == LE || type == GE || type == NE || type == EQ){
        node->val.s = malloc(strlen(val) + 1);
        strcpy(node->val.s, val);
    }else{
        node->val.i = 0;
    }
    return node;
}

void pre_order(Node *t){
    printf("1 time\n");
    if(t == NULL)
        return;
    for(int i = 0; i < space_num; i++){
        printf(" ");
    }
    if(t->type == 0){
        printf("%s (%d)\n", t->name, t->line);
    }
    else if(t->type == INT){
        printf("%s: %u\n", t->name, t->val.i);
    }
    else if(t->type == FLOAT){
        printf("%s: %f\n", t->name, t->val.f);
    }
    else if(t->type == CHAR){
        printf("%s: %s\n",t->name, t->val.s);
    }
    else if(t->type == ID || t->type == TYPE){
        printf("%s: %s\n", t->name, t->val.s);
    }
    else{
        printf("%s\n", t->name);
    }
    space_num += 2;
    for(int i = 0; i < t->childNum; i++){
        pre_order(t->child[i]);
    }
    space_num -= 2;
}

void print_tree(){
    space_num = 0;
    pre_order(root);
}
