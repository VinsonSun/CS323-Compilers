#ifndef AST
#define AST
extern char* yytext;
#define CHILD_MAX_NUM = 50
typedef struct ASTNode {
    int lineNum;
    char* name;
    int seqNum;
    struct AST *child[CHILD_MAX_NUM];
    union val{
        int intVal;
        float floatVal;
        char* stringVal;
    }val;
}ASTNode;
ASTNode *root;
ASTNode* newASTNode(int lineNum, char* name, void *val);
void addChild(ASTNode *root, ASTNode *leaf);
void printAST;
#endif
