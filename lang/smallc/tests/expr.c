int	x,y;
int	*ip;
char	c,d;
char	*cp;

main() {
	x = *ip;

	ip = &x;

	x = -y;

	x = !y;

	x = ~y;

	x = ++y;

	x = --y;

	x = y++;

	x = y--;

	x = x * y;

	x = x / y;

	x = x % y;

	x = x + y;

	x = x - y;

	x = y << 1;

	x = y >> 1;

	x = x < y;

	x = x > y;

	x = x <= y;

	x = x >= y;

	x = x == y;

	x = x != y;

	x = x & y;

	x = x ^ y;

	x = x | y;

	x = x && y;

	x = x || y;

	x = 1;

	x += 1;

	x -= 1;

	x *= y;

	x /= y;

	x %= y;

	x >>= y;

	x <<= y;

	x &= y;

	x ^= y;

	x |= y;

}
