%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include<stdarg.h>
	#include "lex.yy.c"
	
	struct Node *root;
	struct Node* newNode(char *type,int num,...);

	void printTree(struct Node *p,int depth);
	int _(char* ch);

	int isError;//是否有词法或语法错误
%}

//定义类型
//node的定义在.l中
%union{struct Node *node;}
//终结符
%token <node>INT FLOAT TYPE ID SEMI COMMA
%right <node>ASSIGNOP NOT
%left  <node>PLUS MINUS STAR DIV RELOP AND OR 
%left  <node>DOT LP RP LB RB LC RC
%nonassoc <node>STRUCT RETURN IF ELSE WHILE
//非终结符
%type <node>Program ExtDefList ExtDef ExtDecList
%type <node>Specifier StructSpecifier OptTag Tag
%type <node>VarDec FunDec VarList ParamDec
%type <node>CompSt StmtList Stmt
%type <node>DefList Def DecList Dec
%type <node>Exp Args


%%

Program		:	ExtDefList			{$$=newNode("Program",1,$1);root=$$;}
		;
ExtDefList	:	ExtDef ExtDefList		{$$=newNode("ExtDefList",2,$1,$2);}
		|	/*empty*/			{$$=NULL;}
		;
ExtDef		:	Specifier ExtDecList SEMI	{$$=newNode("ExtDef",3,$1,$2,$3);}
		|	Specifier SEMI			{$$=newNode("ExtDef",2,$1,$2);}
		|	Specifier FunDec CompSt		{$$=newNode("ExtDef",3,$1,$2,$3);}
		|	error SEMI			{isError = 1;}
		;
ExtDecList	:	VarDec				{$$=newNode("ExtDecList",1,$1);}
		|	VarDec COMMA ExtDecList		{$$=newNode("ExtDecList",3,$1,$2,$3);}
		;


Specifier	:	TYPE				{$$=newNode("Specifier",1,$1);}
		|	StructSpecifier			{$$=newNode("Specifier",1,$1);}		
		;
StructSpecifier	:	STRUCT OptTag LC DefList RC	{$$=newNode("StructSpecifier",5,$1,$2,$3,$4,$5);}
		|	STRUCT Tag			{$$=newNode("StructSpecifier",2,$1,$2);}
		;
OptTag		:	ID				{$$=newNode("OptTag",1,$1);}
		|	/*empty*/			{$$=NULL;}
		;
Tag		:	ID				{$$=newNode("Tag",1,$1);}
		;


VarDec		:	ID				{$$=newNode("VarDec",1,$1);}
		|	VarDec LB INT RB		{$$=newNode("VarDec",4,$1,$2,$3,$4);}
		;
FunDec		:	ID LP VarList RP		{$$=newNode("FunDec",4,$1,$2,$3,$4);}
		|	ID LP RP			{$$=newNode("FunDec",3,$1,$2,$3);}
		|	error RP			{isError = 1;}
		;
VarList		:	ParamDec COMMA VarList		{$$=newNode("VarList",3,$1,$2,$3);}
		|	ParamDec			{$$=newNode("VarList",1,$1);}
		;
ParamDec	:	Specifier VarDec		{$$=newNode("ParamDec",2,$1,$2);}
		|	error COMMA			{isError = 1;} 
		|	error RB			{isError = 1;} 
		;


CompSt		:	LC DefList StmtList RC		{$$=newNode("CompSt",4,$1,$2,$3,$4);}
		|	error RC			{isError = 1;}
		;
StmtList	:	Stmt StmtList			{$$=newNode("StmtList",2,$1,$2);}
		|	/*empty*/			{$$=NULL;}
		;
Stmt		:	Exp SEMI			{$$=newNode("Stmt",2,$1,$2);}
		|	CompSt				{$$=newNode("Stmt",1,$1);}
		|	RETURN Exp SEMI			{$$=newNode("Stmt",3,$1,$2,$3);}
		|	IF LP Exp RP Stmt ELSE Stmt	{$$=newNode("Stmt",7,$1,$2,$3,$4,$5,$6,$7);}
		|	WHILE LP Exp RP Stmt		{$$=newNode("Stmt",5,$1,$2,$3,$4,$5);}
		|	error SEMI			{isError = 1;}
		;



DefList		:	Def DefList			{$$=newNode("DefList",2,$1,$2);}
		|	/*empty*/			{$$=NULL;}
		;
Def		:	Specifier DecList SEMI		{$$=newNode("Def",3,$1,$2,$3);}
		|	error SEMI			{isError = 1;}
		;
DecList		:	Dec				{$$=newNode("DecList",1,$1);}
		|	Dec COMMA DecList		{$$=newNode("DecList",3,$1,$2,$3);}		

		;
Dec		:	VarDec				{$$=newNode("Dec",1,$1);}
		|	VarDec ASSIGNOP	Exp		{$$=newNode("Dec",3,$1,$2,$3);}
		;


Exp		:	Exp ASSIGNOP Exp		{$$=newNode("Exp",3,$1,$2,$3);}
		|	Exp AND Exp			{$$=newNode("Exp",3,$1,$2,$3);}
		|	Exp OR Exp			{$$=newNode("Exp",3,$1,$2,$3);}
		|	Exp RELOP Exp			{$$=newNode("Exp",3,$1,$2,$3);}
		|	Exp PLUS Exp			{$$=newNode("Exp",3,$1,$2,$3);}
		|	Exp MINUS Exp			{$$=newNode("Exp",3,$1,$2,$3);}
		|	Exp STAR Exp			{$$=newNode("Exp",3,$1,$2,$3);}
		|	Exp DIV Exp			{$$=newNode("Exp",3,$1,$2,$3);}
		|	LP Exp RP			{$$=newNode("Exp",3,$1,$2,$3);}
		|	MINUS Exp			{$$=newNode("Exp",2,$1,$2);}
		|	NOT Exp				{$$=newNode("Exp",2,$1,$2);}
		|	ID LP Args RP			{$$=newNode("Exp",4,$1,$2,$3,$4);}
		|	ID LP RP			{$$=newNode("Exp",3,$1,$2,$3);}
		|	Exp LB Exp RB			{$$=newNode("Exp",4,$1,$2,$3,$4);}
		|	Exp DOT ID			{$$=newNode("Exp",3,$1,$2,$3);}
		|	ID				{$$=newNode("Exp",1,$1);}
		|	INT				{$$=newNode("Exp",1,$1);}
		|	FLOAT				{$$=newNode("Exp",1,$1);}
		;
Args		:	Exp COMMA Args			{$$=newNode("Args",3,$1,$2,$3);}
		|	Exp				{$$=newNode("Args",1,$1);}
		;

%%


yyerror(char* msg)
{
	fprintf(stderr,"Error: type B at line %d:%s\n",yylineno,msg);
}

struct Node* newNode(char *type,int num,...)
{
	struct Node *current = (struct Node *)malloc(sizeof(struct Node));//当前节点
	struct Node *temp = (struct Node *)malloc(sizeof(struct Node));
	current->isToken = 0;
	va_list nodeList;
	va_start(nodeList,num);//获取可变参数
	temp = va_arg(nodeList,struct Node*);
	current->line = temp->line;
	strcpy(current->type,type);
	current->firstChild = temp;

	int i;
	for(i = 1 ; i < num ; i++)
	{
		temp->nextSibling = va_arg(nodeList,struct Node*);
		if(temp->nextSibling != NULL)
			temp = temp->nextSibling;
	}
	temp->nextSibling = NULL;
	va_end(nodeList);
	return current;
}

void printTree(struct Node *p,int depth)
{
	
	if(p == NULL) return;
	int i;
	for(i = 0 ; i < depth ; i++)
		printf("  ");
	if(!p->isToken)
	{
		printf("%s (%d)\n", p->type, p->line);
		printTree(p->firstChild , depth+1);
	}
	else
	{
		if(strcmp(p->type,"INT") == 0)
			printf("%s: %d\n", p->type, atoi(p->text));
		else if(strcmp(p->type,"FLOAT") == 0)
			printf("%s: %f\n", p->type, atof(p->text));
		else if(strcmp(p->type,"TYPE") == 0 || strcmp(p->type,"ID") == 0)
			printf("%s: %s\n", p->type, p->text);
		else
			printf("%s\n", p->type);
	}
	printTree(p->nextSibling , depth);
}



