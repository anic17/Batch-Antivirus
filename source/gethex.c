#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void Help()
{
	printf("gethex - Get the first n bytes of a file\nUsage: gethex <file> <bytemax>\n\nExample:\ngethex main.c 10\nWill read the first 10 bytes of the file 'main.c' and will display them on screen\n\nMade by anic17 for Batch Antivirus: https://github.com/anic17/Batch-Antivirus\n");
}

int main(int argc, char* argv[])
{
	if(argc < 3 || !strcmp(argv[1], "--help"))
	{
		Help();
		return 0;
	}
	FILE* fp = fopen(argv[1], "rb");
	int max = atoi(argv[2]);
	if(!fp || max <= 0)
	{
		return 1;
	}
	
	int c=0, cnt=0;
	while((c = fgetc(fp)) != EOF && ++cnt <= max)
	{
		printf("%02x", c);
	}
	return max;
}
	