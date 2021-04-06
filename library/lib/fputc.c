/* fputc and feof routines */
fputc(c, fd)
char c;
int fd;
{
    return (putc(c, fd));
}

feof(fd)
int fd;
{
    return (0);
}
