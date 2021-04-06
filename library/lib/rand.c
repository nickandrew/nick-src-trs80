/*  int rand()
**  srand(seed)    long seed;  (really int here!)
**  rand() uses the generator from Oh Pascal! p227
*/

int rndseed;

int rand()
{
    rndseed = ((25173 * rndseed) + 13849);
    return rndseed & 0x7fff;
}

srand(seed)
int seed;
{
    rndseed = seed;
}
