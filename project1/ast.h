#ifndef AST
#define AST
#define CHILD_MAX_NUM 10
extern char* yytext;

typedef struct ASTNode {
    int lineNum;
    char *name;
    int seqNum;
    struct ASTNode *child[CHILD_MAX_NUM];
    union val{
        int intVal;
        float floatVal;
        char *stringVal;
    }val;
}ASTNode;
ASTNode *root;
ASTNode *newASTNode(int lineNum, char* name, void *val);
void addChild(ASTNode *root, ASTNode *leaf);
void printAST();
#endif
