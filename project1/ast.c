#include "ast.h"
#include "syntax.tab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

ASTNode *newASTNode(int line, char *nodeName, int type, void *val, int childNum, ...){
    ASTNode *node = malloc(sizeof(ASTNode));
    node->line = line;
    node->type = type;
    node->childNum = childNum;
    node->name = malloc(strlen(nodeName) + 1);
    strcpy(node->name, nodeName);
    
    if(!strcmp(node->name, "INT")){
        node->val.intVal = atoi(yytext);
    }else if(node->name, "FLOAT"){
        node->val.floatVal = atof(yytext);
    }else if(type == CHAR){
        node->val.stringVal = (char*)val;
    }else if(type == ID || type == TYPE || type == GT || type == LT || type == LE || type == GE || type == NE || type == EQ){
        char* tmp = (char *)malloc(sizeof(char) * strlen(yytext));
        strcpy(tmp, yytext);
        node->stringVal = tmp;
    }else{
        node->val.intVal = 0;
    }
    
    va_list childs;
    if (childNum <= 0) {
        return node;
    }
    va_start(childs, childNum);
    for(int i=0; i<childNum; i++) {
        node->child[i] = va_arg(childs, ASTNode*);
    }
    va_end(childs);
    return node;
}

void traverse(ASTNode *node, int spaceNum){
    if(node == NULL)
        return;
    for(int i = 0; i < spaceNum; i++){
        printf(" ");
    }
    if(node->type == 0){
        printf("%s (%d)\n", node->name, node->line);
    }else if(node->type == INT){
        printf("%s: %u\n", node->name, node->val.intVal);
    }else if(node->type == FLOAT){
        printf("%s: %f\n", node->name, node->val.floatVal);
    }else if(node->type == CHAR || node->type == ID || node->type == TYPE){
        printf("%s: %s\n", node->name, node->val.stringVal);
    }else{
        printf("%s\n", node->name);
    }
    for(int i = 0; i < node->childNum; i++){
        traverse(node->child[i], spaceNum + 2);
    }
}
