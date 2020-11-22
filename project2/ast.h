#ifndef AST
#define AST
#define MAX_CHILD 10

typedef struct ASTNode
{
    int line;
    int type;
    int status;
    char *name;
    int childNum;
    struct ASTNode *child[MAX_CHILD];
    union Val{
        int intVal;
        float floatVal;
        char *stringVal;
    }val;
}ASTNode;
ASTNode *root;
ASTNode *newASTNode(int line, char *nodeName, int type, void *val, int childNum, ...);
void traverse(ASTNode *t, int spaceNum);
#endif
