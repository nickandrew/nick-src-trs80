heir13(lval)
int	lval[];
	{
	int	k;
	char	*ptr;

	if (match("++"))	{
		if (heir13(lval) == 0)	{
			needlval();
			return (0);
		}

		step(inc, lval);
		return (0);
	}
	else if (match("--"))	{
		if (heir13(lval) == 0)	{
			needlval();
			return (0);
		}

		step(dec, lval);
		return (0);
	}
	else if (match("~"))	{
		if (heir13(lval))
			rvalue(lval);

		com();
#ifdef	PHASE2
		lval[4] = ~lval[4];
#endif
		return (0);
	}
	else if (match("!"))	{
		if (heir13(lval))
			rvalue(lval);

		lneg();
#ifdef	PHASE2
		lval[4] = !lval[4];
#endif
		return (0);
	}
	else if (match("-"))	{
		if (heir13(lval))
			rvalue(lval);

		neg();
		lval[4] = -lval[4];
		return (0);
	}
	else if (match("*"))	{
		if (heir13(lval))
			rvalue(lval);

		if (ptr = lval[0])
			lval[1] = ptr[TYPE];
		else
			lval[1] = CINT;

		lval[2] = lval[3] = 0;
		return (1);
	}
	else if (match("&"))	{
		if (heir13(lval) == 0)	{
			error("illegal address");
			return (0);
		}

		ptr = lval[0];
		lval[2] = ptr[TYPE];

		if (lval[1])
			return (0);

		address(ptr);
		lval[1] = ptr[TYPE];
		return (0);
	}
	else	{
		k = heir14(lval);

		if (match("++"))	{
			if (k == 0)	{
				needlval();
				return (0);
			}

			step(inc, lval);
			dec(lval[2] >> 2);
			return (0);
		}
		else if (match("--"))	{
			if (k == 0)	{
				needlval();
				return (0);
			}

			step(dec, lval);
			inc(lval[2] >> 2);
			return (0);
		}
		else
			return (k);
	}
}

heir14(lval)
int	*lval;
	{
	int	k, const, val, lval2[8];
	char	*ptr, *before, *start;

	k = primary(lval);
	ptr = lval[0];
	blanks();

	if ((ch == '[') | (ch == '('))	{
		lval[5] = 1;

		while (1)	{
			if (match("["))	{
				if (ptr == 0)	{
					error("can't subscript");
					junk();
					needtoken("]");
					return(0);
				}
				else if (ptr[IDENT] == POINTER)
					rvalue(lval);
				else if (ptr[IDENT] != ARRAY)	{
					error("can't subscript");
					k = 0;
				}

				setstage(&before, &start);
				lval2[3] = 0;
				plunge2(0, 0, heir1, lval2, lval2);
				needtoken("]");

				if (lval2[3])	{
					clearstage(before, 0);

					if (lval2[4])	{
						if (ptr[TYPE] == CINT)
							const2(lval2[4] << LBPW);
						else
							const2(lval2[4]);

						add();
					}
				}
				else	{
					if (ptr[TYPE] == CINT)
						doublereg();

					add();
				}

				lval[0] = lval[2] = 0;
				lval[1] = ptr[TYPE];
				k = 1;
			}
			else if (match("("))	{
				if (ptr == 0)
					callfunction(0);
				else if (ptr[IDENT] != FUNCTION)	{
					rvalue(lval);
					callfunction(0);
				}
				else
					callfunction(ptr);

				k = lval[0] = lval[3] = 0;
			}
			else
				return (k);
		}
	}

	if (ptr == 0)
		return (k);

	if (ptr[IDENT] == FUNCTION)	{
		address(ptr);
		return (0);
	}

	return (k);
}

primary(lval)
int	*lval;
	{
	char	*ptr;
	int	k;

	if (match("("))	{
		k = heir1(lval);
		needtoken(")");
		return (k);
	}

	putint(0, lval, 8 << LBPW);

	if (symname(ssname, YES))	{
		if (ptr = findloc(ssname))	{
			if (ptr[IDENT] == LABEL)	{
				experr();
				return (0);
			}

			getloc(ptr);
			lval[0] = ptr;
			lval[1] = ptr[TYPE];

			if (ptr[IDENT] == POINTER)	{
				lval[1] = CINT;
				lval[2] = ptr[TYPE];
			}

			if (ptr[IDENT] == ARRAY)	{
				lval[2] = ptr[TYPE];
				return (0);
			}
			else
				return (1);
		}

		if (ptr = findglb(ssname))
			if (ptr[IDENT] != FUNCTION)	{
				lval[0] = ptr;
				lval[1] = 0;

				if (ptr[IDENT] != ARRAY)	{
					if (ptr[IDENT] == POINTER)
						lval[2] = ptr[TYPE];

					return (1);
				}

				address(ptr);
				lval[1] = lval[2] = ptr[TYPE];
				return (0);
			}

		ptr = addsym(ssname, FUNCTION, CINT, 0, &glbptr, STATIC);
		lval[0] = ptr;
		lval[1] = 0;
		return (0);
	}

	if (constant(lval) == 0)
		experr();

	return (0);
}

experr()
	{

	error("invalid expression");
	const(0);
	junk();
}

callfunction(ptr)
char	*ptr;
	{
	int	nargs, const, val;

	nargs = 0;
	blanks();

	if (ptr == 0)
		push();

	while (streq(lptr, ")") == 0)	{
		if (endst())
			break;

		expression(&const, &val);

		if (ptr == 0)
			swapstk();

		push();
		nargs = nargs + BPW;

		if (match(",") == 0)
			break;
	}

	needtoken(")");

	if (streq(ptr + NAME, "CCARGC") == 0)
		loadargc(nargs >> LBPW);

	if (ptr)
		call(ptr + NAME);
	else
		callstk();

	csp = modstk(csp + nargs, YES);
}
