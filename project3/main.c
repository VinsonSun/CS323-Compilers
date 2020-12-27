#include <stdio.h>
#include "syntax.tab.h"
#include "ast.h"
#include "inter.h"
#include "translate.h"

extern int yylex (void);
extern void yyrestart (FILE *input_file);
extern FILE* yyin;
extern int yylineno;
FILE* output;

int error_num = 0;

int main(int argc, char **argv) {
    if (argc > 1){
        FILE *f = fopen(argv[1], "r");
        if(argc==3)
            output = fopen(argv[2], "w+");
        else
            output = fopen("workdir/a.ir", "w+");
        if (!f){
            perror(argv[1]);
            return 1;
        }
        yyrestart(f);
        yyparse();
        if(error_num==0)
            translate_program(root);
            fclose(output);
    }
    return 0;
}