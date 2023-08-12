/*  int rand()
**  srand(seed)    long seed;  (really int here!)
**  rand() uses the generator from Oh Pascal! p227
*/

#include <stdlib.h>

int rndseed;

int rand(void)
{
    rndseed = ((25173 * rndseed) + 13849);
    return rndseed & 0x7fff;
}

void srand(unsigned int seed)
{
    rndseed = seed;
}
