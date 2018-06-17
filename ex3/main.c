#include <stdlib.h>
#include <stdio.h>
#include "tree.h"
#include "semantic.h"
#include "intercode.h"

extern void yyrestart(FILE *);
extern int yyparse();
extern int yylineo;

Node *Root = NULL;
int errorNum = 0;
int theSameLine = 0;
int semanticError = 0;
int structError = 0;

void myerror(char *msg)
{
	if (theSameLine != yylineno)
	{
		printf("Error type B at line %d: %s\n", yylineno, msg);
		theSameLine = yylineno;
	}
}

int main(int argc, char **argv)
{
	FILE *fp;
	if (argc < 2)
	{
		printf("使用以下命令: ./complier test.cmm out.ir.\n\n");
		return 1;
	}
	else
	{
		fp = fopen(argv[1], "r");
	}
	if (!fp)
	{
		printf("无法打开文件.\n\n");
		perror(argv[1]);
		return 1;
	}

	yylineno = 1;

	yyrestart(fp);
	yyparse();

	if (structError == 0 && errorNum == 0)
	{
		initHashtable();
		initIRList();
		traverseTree(Root);
		if (argc == 2)
		{
			writeCode("stdout");
		}
		else if (argc == 3)
		{
			writeCode(argv[2]);
		}
	}
	else
	{
		printf("error！\n");
	}

	return 0;
}
