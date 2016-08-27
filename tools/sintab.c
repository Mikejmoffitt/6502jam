#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <stdint.h>

#define SIN_BIAS 0.0
#define COS_BIAS 0.0

void costab(float range_low, float range_hi, int coef, int len)
{
	float pos = range_low;
	float inc = (range_hi - range_low) / len;
	for (int i = 0; i < len; i++)
	{
		printf("\t.word $%04X\n", (uint16_t)(coef * (COS_BIAS + cosf(pos))) & 0xFFFF);
		pos += inc;
	}
}

void sintab(float range_low, float range_hi, int coef, int len)
{
	float pos = range_low;
	float inc = (range_hi - range_low) / len;
	for (int i = 0; i < len; i++)
	{
		printf("\t.word $%04X\n", (uint16_t)(coef * (SIN_BIAS + sinf(pos))) & 0xFFFF);
		pos += inc;
	}
}

int main(int argc, char **argv)
{
	if (argc < 6)
	{
		printf("Usage: %s [op] [range_low] [range_hi] [coef] [len] [label]\n", argv[0]);
		return 0;
	}
	if (argc >= 7)
	{
		printf("%s:\n", argv[6]);
		printf(".byte $%02X\n", atoi(argv[5]));
	}
	if (strncmp(argv[1], "sin", 4) == 0)
	{
		sintab(atof(argv[2]), atof(argv[3]), atoi(argv[4]), atoi(argv[5]));
	}
	else if (strncmp(argv[1], "cos", 4) == 0)
	{
		costab(atof(argv[2]), atof(argv[3]), atoi(argv[4]), atoi(argv[5]));
	}
	printf("\n");
	return 0;
}
