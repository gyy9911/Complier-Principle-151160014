#ifndef _OBJECT_CODE_H_
#define _OBJECT_CODE_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "intercode.h"
#include "semantic.h"

typedef struct Var_t
{
	int reg_no;		//寄存器编号
	Operand op;		// 操作符类型
	struct Var_t *next;
} VarDesciptor;

typedef struct RegDesciptor
{ 
	char name[6];		//寄存器名
	int old;		//存储的时间
	struct Var_t *var;
} RegDesciptor;

typedef struct StkDesciptor
{
	int length;
	int from;
	int old[1024];
	VarDesciptor *varstack[1024];
} StkDesciptor;

void writeAllObject(FILE *fp);

#endif
