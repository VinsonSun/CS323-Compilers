#ifndef AST
#define AST
#define MAX_CHILD 10
typedef struct ASTNode
{
    int line;
    int type;
    char *name;
    int childNum;
    struct Node *child[MAX_CHILD];
    union Val{
        int intVal;
        float floadVal;
        char *stringVal;
    }val;
}ASTNode;
ASTNode *root;
ASTNode *newASTNode(int line, char *nodeName, int type, void *val, int childNum, ...);
void traverse(Node *t, int spaceNum);
#endif
