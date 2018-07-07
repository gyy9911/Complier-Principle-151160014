%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include <string.h>
    #include "syntax.tab.h"
    #include "tree.h"
    extern int errorNum;
	extern int structError;
    int theSameLine2 = 0;
%}
%option yylineno

SEMI ;
COMMA ,
ASSIGNOP =
RELOP >|<|>=|<=|==|!=
PLUS "+"
MINUS "-"
STAR "*"
DIV "/"
AND "&&"
OR "||"
DOT "."
NOT "!"
TYPE int|float
LP \(
RP \)
LB \[
RB \]
LC \{
RC \}
STRUCT struct
RETURN return
IF if
ELSE else
WHILE while
SPACE [ \r\n\t]+
DECNUM ([1-9][0-9]*)|0
OCT 0[0-7]*
OCT_ERROR 0[0-9A-WYZa-wyz][0-9A-Za-z]*
HEX 0[Xx][0-9a-fA-F]*
HEX_ERROR [0][Xx][0-9A-Za-z]*
INT {DECNUM}|{OCT}|{HEX}
FLOAT [0-9]*[.][0-9]+f?
ID [A-Za-z_][A-Za-z_0-9]*
COMMENT "//"
OTHER .

%%

{SEMI}  {
    yylval.node=newNode("SEMI",yytext);
    return(SEMI);
}
{COMMA} {
    yylval.node=newNode("COMMA",yytext);
    return(COMMA);
}
{ASSIGNOP} {
    yylval.node=newNode("ASSIGNOP",yytext);
    return ASSIGNOP;
}


{RELOP}     {
    yylval.node=newNode("RELOP",yytext);
    return RELOP;
}

{PLUS}      {
    yylval.node=newNode("PLUS",yytext);
    return PLUS;
}
{MINUS}     {
    yylval.node=newNode("MINUS",yytext);
    return MINUS;
}
{STAR}      {
    yylval.node=newNode("STAR",yytext);
    return STAR;
}
{DIV}       {
    yylval.node=newNode("DIV",yytext);
    return DIV;
}
{AND}       {
    yylval.node=newNode("AND",yytext);
    return AND;
}
{OR}        {
    yylval.node=newNode("OR",yytext);
    return OR;
}
{DOT}       {
    yylval.node=newNode("DOT",yytext);
    return DOT;
}
{NOT}       {
    yylval.node=newNode("NOT",yytext);
    return NOT;
}
{TYPE}      {
    yylval.node=newNode("TYPE",yytext);
    return TYPE;
}
{LP}        {
    yylval.node=newNode("LP",yytext);
    return LP;
}
{RP}        {
    yylval.node=newNode("RP",yytext);
    return RP;
}
{LB}        {
    yylval.node=newNode("LB",yytext);
    return LB;
}
{RB}        {
    yylval.node=newNode("RB",yytext);
    return RB;
}
{LC}        {
    
    yylval.node=newNode("LC",yytext);
    return LC;
}
{RC}        {
    yylval.node=newNode("RC",yytext);
    return RC;
}
{STRUCT}    {
	structError++;
    yylval.node=newNode("STRUCT",yytext);
    return STRUCT;
}
{RETURN}    {
    yylval.node=newNode("RETURN",yytext);
    return RETURN;
}
{IF}        {
    yylval.node=newNode("IF",yytext);
    return IF;
}
{ELSE}      {
    yylval.node=newNode("ELSE",yytext);
    return ELSE;
}
{WHILE}     {
    yylval.node=newNode("WHILE",yytext);
    return WHILE;
}
{SPACE}     {}


{OCT}       {
    char *end = NULL;
    int l = (int)strtol(yytext, &end, 8);
    snprintf(yytext, 10,"%d",l);
    yylval.node=newNode("INT",yytext);
    return INT;
}
{OCT_ERROR} {
    errorNum++;
    printf("Error type A at Line %d: Illegal octal number '%s'\n", yylineno, yytext);
    return INT;
}
{HEX}       {
    char *end = NULL;
    int l = (int)strtol(yytext, &end, 16);
    snprintf(yytext, 10,"%d",l);
    yylval.node=newNode("INT",yytext);
    return INT;
}
{HEX_ERROR} {
    errorNum++;
    printf("Error type A at Line %d: Illegal hexadecimal number '%s'\n", yylineno, yytext);
    return INT;
}
{INT}       {
    yylval.node=newNode("INT",yytext);
    return INT;
}
{FLOAT}     {
    yylval.node=newNode("FLOAT",yytext);
    return FLOAT;
}

{ID}        {
    yylval.node=newNode("ID",yytext);
    return ID;
}

{OTHER} {
    errorNum++;
    if(theSameLine2 != yylineno){
        printf("Error type A at line %d: Mysterious character \"%s\".\n",yylineno,yytext);
        theSameLine2 = yylineno;
    }
    
}
{COMMENT} {
        printf("Error type A at line %d: Mysterious character \"%s\".\n",yylineno,yytext);
        theSameLine2 = yylineno;  
}


%%

int yywrap() {
    return 1;
}


  
