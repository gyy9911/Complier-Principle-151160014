//这是flex的测试代码
%{
#include <stdio.h>
%}

%%
[0-9]+	printf("NUMBER");

[a-zA-Z]+	printf("WORD");
%%

