#ifndef TREE
#define TREE
#define MAX_CHILD 10
typedef struct Node
{
    int line;
    int visited;
    int code_visited;
    int type;
    char *name;
    int childNum;
    struct Node *child[MAX_CHILD];
    union Val{
        int i;
        float f;
        char *s;
    }val;
}Node;
Node *root;
Node *new_node(int line, char *nodeName, int type, void *val, int childNum, ...);
void print_tree();
#endif
