%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "tree.h"
    #include "lex.yy.c"
    extern int yylineno;
    void myerror(char *msg);//自定义报错信息
    extern Node* Root;//语法树根节点
    extern int errorNum;//错误数量
    int yyerror(char const *msg);
%}

%union {
    struct Abstract_Tree* node;
}

//terminal token
%token <node> INT FLOAT ID SEMI COMMA ASSIGNOP RELOP PLUS MINUS STAR DIV 
%token <node> AND OR DOT NOT TYPE LP RP LB RB LC RC STRUCT RETURN IF ELSE WHILE

//association
%right ASSIGNOP  
%left OR 
%left AND 
%left RELOP
%left PLUS MINUS 
%left STAR DIV
%right NOT
%left DOT LB RB LP RP

//noassociation
%nonassoc LOWER_THAN_ELSE 
%nonassoc ELSE

//non-terminal type
%type <node> Program ExtDefList ExtDef ExtDecList Specifier
%type <node> StructSpecifier OptTag Tag VarDec FunDec VarList
%type <node> ParamDec CompSt StmtList Stmt DefList Def DecList
%type <node> Dec Exp Args



%%

//High-level Definitions

Program     : ExtDefList        {$$=newNode("Program","");addChild(1, $$, $1);Root=$$;}
            ;

ExtDefList  : ExtDef ExtDefList     {$$=newNode("ExtDefList","");addChild(2, $$, $1, $2);}
            |  /* empty*/           {$$=NULL;}
            ;
                
ExtDef      : Specifier ExtDecList SEMI     {$$=newNode("ExtDef","");addChild(3, $$, $1, $2, $3);}
            | Specifier SEMI                {$$=newNode("ExtDef","");addChild(2, $$, $1, $2);}    
            | Specifier FunDec CompSt       {$$=newNode("ExtDef","");addChild(3, $$, $1, $2, $3);}
	    | Specifier FunDec SEMI	    {errorNum++;myerror("Syntax error, near \';\'");}
            | Specifier error               {errorNum++;myerror("Syntax error, near \'}\'");}
            ;
ExtDecList  : VarDec                        {$$=newNode("ExtDecList","");addChild(1, $$, $1);}
            | VarDec COMMA ExtDecList       {$$=newNode("ExtDecList","");addChild(3, $$, $1, $2, $3);}
            ;

            

//Specifiers

Specifier   : TYPE                  {$$=newNode("Specifier","");addChild(1, $$, $1);}
            | StructSpecifier       {$$=newNode("Specifier","");addChild(1, $$, $1);}
            ;
            
StructSpecifier : STRUCT OptTag LC DefList RC   {$$=newNode("StructSpecifier","");addChild(5, $$, $1, $2, $3, $4, $5);}
                | STRUCT Tag                    {$$=newNode("StructSpecifier","");addChild(2, $$, $1, $2);}
		//| error Tag	    		{errorNum++; myerror("Syntax error, missing \'struct\'");}在一些情况下会和缺少;冲突
                ;
            
OptTag  : ID                {$$=newNode("OptTag","");addChild(1, $$, $1);}
        | /* empty*/        {$$=NULL;}
        ;
        
Tag     : ID                {$$=newNode("Tag","");addChild(1, $$, $1);}
        ;


//4.Declarators

VarDec      : ID                            {$$=newNode("VarDec","");addChild(1, $$, $1);}
            | VarDec LB INT RB              {$$=newNode("VarDec","");addChild(4, $$, $1, $2, $3, $4);}
	    | VarDec LB error RB	    {errorNum++; myerror("Syntax error, near \']\'");}
            ;
            
FunDec      : ID LP VarList RP              {$$=newNode("FunDec","");addChild(4, $$, $1, $2, $3, $4);}
            | ID LP RP                      {$$=newNode("FunDec","");addChild(3, $$, $1, $2, $3);}
            ;
            
VarList     : ParamDec COMMA VarList        {$$=newNode("VarList","");addChild(3, $$, $1, $2, $3);}
            | ParamDec                      {$$=newNode("VarList","");addChild(1, $$, $1);}
            ;
            
ParamDec    : Specifier VarDec              {$$=newNode("ParamDec","");addChild(2, $$, $1, $2);}
            ;

            
//Statements

CompSt      : LC DefList StmtList RC        {$$=newNode("CompSt","");addChild(4, $$, $1, $2, $3, $4);}
            | LC DefList StmtList error     {errorNum++;myerror("missing \'}\'");}
            ;
            
StmtList    : Stmt StmtList                 {$$=newNode("StmtList","");addChild(2, $$, $1, $2);}
            | /*empty*/                     {$$=NULL;}
            ;
            
Stmt    : Exp SEMI                                      {$$=newNode("Stmt","");addChild(2, $$, $1, $2);}
        | CompSt                                        {$$=newNode("Stmt","");addChild(1, $$, $1);}
        | RETURN Exp SEMI                               {$$=newNode("Stmt","");addChild(3, $$, $1, $2, $3);}
	| RETURN error SEMI				{errorNum++;myerror("Syntax error, after return");}
        | IF LP Exp RP Stmt %prec LOWER_THAN_ELSE       {$$=newNode("Stmt","");addChild(5, $$, $1, $2, $3, $4, $5);}
        | IF LP Exp RP Stmt ELSE Stmt                   {$$=newNode("Stmt","");addChild(7, $$, $1, $2, $3, $4, $5, $6, $7);}
        | IF LP Exp RP error ELSE Stmt                  {errorNum++;myerror("Missing \";\"");}
        | WHILE LP Exp RP Stmt                          {$$=newNode("Stmt","");addChild(5, $$, $1, $2, $3, $4, $5);}
	| Exp error					{errorNum++;myerror("Syntax error, before \'}\'");}
        ;


//Local Definitions

DefList : Def DefList               {$$=newNode("DefList","");addChild(2, $$, $1, $2);}
        | /*empty*/                 {$$=NULL;}
        ;
        
Def     : Specifier DecList SEMI    {$$=newNode("Def","");addChild(3, $$, $1, $2, $3);}
	| Specifier error SEMI	    {errorNum++;myerror("Syntax error, near \';\'");}
        ;

DecList : Dec                       {$$=newNode("DecList","");addChild(1, $$, $1);}
        | Dec COMMA DecList         {$$=newNode("DecList","");addChild(3, $$, $1, $2, $3);}
        ;
        
Dec     : VarDec                    {$$=newNode("Dec","");addChild(1, $$, $1);}
        | VarDec ASSIGNOP Exp       {$$=newNode("Dec","");addChild(3, $$, $1, $2, $3);}
        ;
            
            
//Expressions
Exp     : Exp ASSIGNOP Exp      {$$=newNode("Exp","");addChild(3, $$, $1, $2, $3);}
        | Exp AND Exp           {$$=newNode("Exp","");addChild(3, $$, $1, $2, $3);}
        | Exp OR Exp            {$$=newNode("Exp","");addChild(3, $$, $1, $2, $3);}
        | Exp RELOP Exp         {$$=newNode("Exp","");addChild(3, $$, $1, $2, $3);}
        | Exp PLUS Exp          {$$=newNode("Exp","");addChild(3, $$, $1, $2, $3);}
        | Exp MINUS Exp         {$$=newNode("Exp","");addChild(3, $$, $1, $2, $3);}
        | Exp STAR Exp          {$$=newNode("Exp","");addChild(3, $$, $1, $2, $3);}
        | Exp DIV Exp           {$$=newNode("Exp","");addChild(3, $$, $1, $2, $3);}
        | LP Exp RP             {$$=newNode("Exp","");addChild(3, $$, $1, $2, $3);}
        | MINUS Exp             {$$=newNode("Exp","");addChild(2, $$, $1, $2);}
        | NOT Exp               {$$=newNode("Exp","");addChild(2, $$, $1, $2);}
        | ID LP Args RP         {$$=newNode("Exp","");addChild(4, $$, $1, $2, $3, $4);}
	    | ID LP error		    {errorNum++;myerror("Syntax error, after \'(\'");}
        | ID LP RP              {$$=newNode("Exp","");addChild(3, $$, $1, $2, $3);}
        | Exp LB Exp RB         {$$=newNode("Exp","");addChild(4, $$, $1, $2, $3, $4);}
        | Exp LB error 	        {errorNum++;myerror("Syntax error, near \'[\'");}
        | Exp DOT ID            {$$=newNode("Exp","");addChild(3, $$, $1, $2, $3);}
        | ID                    {$$=newNode("Exp","");addChild(1, $$, $1);}
        | INT                   {$$=newNode("Exp","");addChild(1, $$, $1);}
        | FLOAT                 {$$=newNode("Exp","");addChild(1, $$, $1);}
        ;
    
Args        : Exp COMMA Args        {$$=newNode("Args","");addChild(3, $$, $1, $2, $3);}
            | Exp                   {$$=newNode("Args","");addChild(1, $$, $1);}
            ;

%%

int yyerror(char const *msg)
{
    //printf("Error type B at line %d: %s\n", yylineno, msg);
}
