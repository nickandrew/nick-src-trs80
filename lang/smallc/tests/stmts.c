int	x;

main() {

	return;
	x=100;
	goto fred;

	if (x) {
		x= 3;
	}

fred:	if (x) {
		x= 4;
	} else {
		x= 5;
	}

	for (3;3;3) {
		x= 6;
	}

	do {
		x= 7;
	} while (1);

	while (1) {
		x= 8;
	}

	switch(4) {
		case 1 : x= 9;
		case 2 : x= 10;
			 break;
		default : x= 11;
			  break;
	}

}
