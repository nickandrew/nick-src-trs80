/* this code should test all combinations of pointers and operations */

char	gc,
	*pgc,
	**ppgc;

main(ac,pac,ppac)
char	ac,
	*pac,
	**ppac;
{

	gc = gc;
	gc = *pgc;
	gc = **ppgc;

	pgc = pgc;
	pgc = *ppgc;

	ppgc = ppgc;

	gc = ac;
	gc = *pac;
	gc = **ppac;

	pgc = pac;
	pgc = *ppac;

	ppgc = ppac;

/* pointer assignments */

	*pgc = gc;
	*pgc = **ppgc;

	*ppgc = *ppgc;
	*ppgc = ppgc;
	**ppgc = ppgc;
	**ppgc = *ppgc;

	*gc = ac;
	*gc = *pac;
	*gc = **ppac;

	*pgc = pac;
	*pgc = *ppac;

	**ppgc = ppac;
}
