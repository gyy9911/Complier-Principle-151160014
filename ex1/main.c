#include <stdio.h>
//#include "syntree.h"
extern struct TreeNode* root ;
extern int yylineno;
extern int isError;
int main(int argc, char** argv) 
{ 
  	if (argc < 1){
		printf("Usage:./parser + filename + filename ...!!\n");
		return 1;
	}
	int i;
	for( i = 1 ; i < argc ; i++){
		printf("The result of compilering file: %s:\n",argv[i]);
		root = NULL;
		isError = 0;
		yylineno = 1;
		FILE* f = fopen(argv[i], "r"); 
	  	if (!f) 
	  	{ 
	    		perror(argv[i]); 
	    		return 1; 
	  	}
	  	yyrestart(f);
	  	yyparse();
		if(root != NULL && isError == 0)
			printTree(root,0);
		printf("=======================================================================\n");
	}
  	return 0; 
} 
