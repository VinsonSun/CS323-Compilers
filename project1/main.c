#include <stdio.h>
#include "ast.h"
extern int yyparse();
extern int yyrestart();
int error_num = 0;
int main(int argc, char **argv){
    if (argc > 1){
        FILE *f = fopen(argv[1], "r");
        yyrestart(f);
        yyparse();
        if(error_num==0)
            printTree();
    }
    return 0;
}
