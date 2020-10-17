#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "syntax.tab.h"
#include "ast.h"
int space_num = 0;

ASTNode* newASTNode(int lineNum, char* name, void *val){
    ASTNode* node = (ASTNOde*)malloc(sizeof(ASTNode));
    node->lineNum = lineNum;
    strcpy(node->name, name);
    node->seqNum = 0;
    node->isToken = 0;
    if(!strcmp(node->name, "INT")){
        node->val.intVal = atoi(yytext);
    } else if (!strcmp(node->name, "FLOAT")){
        node->val.floatVal = atof(yytext);
    } else {
        char* temp = (char *)malloc(sizeof(char) * strlen(yytext));
        strcpy(temp, yytext);
        node->stringVal = temp;
    }
    for(int i=0; i<CHILD_MAX_NUM; i++) {
        node->child[i] = NULL;
    }
}

void addChild(ASTNode *root, ASTNode *leaf){
    root->child[root->seqNum++] = leaf;
}
void traverse(ASTNode *node){
    if(node == NULL) return;
    for(int i=0; i<space_num; i++) {
        printf(" ");
    }
    if(!strcmp(node->name, "ID") || !strcmp(node->name, "TYPE") || !strcmp(node->name, "CHAR")){
        printf(": %s\n", node->stringVal);
    }else if(!strcmp(node->name. "INT")){
        printf(": %d\n", node->intVal);
    }else if(!strcmp(node->name, "FLOAT")){
        printf(": %f\n", node->floatVal);
    }else if(node->isToken == 0) {
        printf(" (%d)\n, node->lineNum");
    }else {
        printf("\n");
    }

    space_num += 2;
    for(int i=0; i<node->seqNum; i++){
        traverse(node->child[i]);
    }
    space_num -= 2;
}
void printTree(){
    space_num = 0;
    traverse(root);
}

