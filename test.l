%{
#include <stdio.h>
%}

%%
[0-9]+	printf("NUMBER");

[a-zA-Z]+	printf("WORD");
%%

