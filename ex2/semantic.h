#ifndef _SEMANTIC_H_
#define _SEMANTIC_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

#define HASH_SIZE 65536  

#define INT_TYPE 1
#define FLOAT_TYPE 2
//基本类型（int float） 数组 结构体 函数
typedef enum Kind_ {
	BASIC, ARRAY, STRUCTURE, FUNCTION
}Kind;

typedef struct Type_ *TypePtr;
typedef struct FieldList_ *FieldList;

typedef struct Type_ {

	Kind kind;
	union{
		int basic_;

		struct {
			int size;
			TypePtr elem;
		}array_;

		FieldList structure_;

		struct{
			FieldList params;//结构体中的参数
			TypePtr funcType;
			int paramNum;//参数数量
		}function_;

	}u;
}Type_;

typedef struct FieldList_ {
	char *name;     //变量/函数/结构名
	TypePtr type;   //类型
	FieldList tail; //指向结构体或链表的下一维度
	int collision;  //hash值是否冲突
}FieldList_;

void traverseTree(Node *root);
FieldList VarDec(Node *root,TypePtr basictype);
TypePtr Specifier(Node *root);
void ExtDefList(Node *root);
void CompSt(Node *root,TypePtr funcType);
void DefList(Node *root);
void Stmt(Node *root,TypePtr funcType);
TypePtr Exp(Node* root);

unsigned int hash_pjw(char *name);
void initHashtable();
int insertSymbol(FieldList f);
int TypeEqual(TypePtr type1,TypePtr type2);
FieldList lookupSymbol(char *name,int function);//function 1,varible 0
void AllSymbol();

#endif
