/* get an integer from a buffer (byte order independent) */

int	getw(cp)
char	*cp;
{
	return (*cp & 255) + ((cp[1] & 255) << 8);
}

/* put an integer into a buffer (byte order independent) */

putw(addr,word)
char	*addr;
int	word;
{
	*addr++ = (word & 255);
	*addr++ = (word>>8) & 255;
}

