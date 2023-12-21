/* stricmp.c */

#include <ctype.h>
#include <string.h>

int stricmp(const char *s1, const char *s2) {
	char c;

	while (*s1 && *s2) {
		c = tolower(*s1) - tolower(*s2);
		if (c) {
			return c;
		}

		++s1;
		++s2;
	}

	c = *s1 - *s2;
	return c;
}
