
int     sargc;
char    **sargv;

main(argc, argv)
int     argc, *argv;
        {

        parse();
        outside();
        trailer();
}

/*
**      process all input text
**
**      At this level, only static declarations,
**      defines, includes and function definitions
**      are legal...
*/

parse()
        {

}
