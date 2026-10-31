#include <stdio.h>

int main(void)
{
  char* greeting = "Hello, john!\n";
  char* actual = &(6[greeting]);
	printf("%s", actual);
	return 0;
}
