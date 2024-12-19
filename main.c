//main.c

#include <stdio.h>

extern int add(int a, int b);

int minus(int a, int b)
{
	return a-b;
}

int main(int argc, char **argv)
{
	int a = 10, b = 100;
	printf("hello world\n");
	if( a < b )
		printf("a + b = %d\n", add(a, b));
	else
		printf("a - b = %d\n", minus(a, b));
	return 0;
}
