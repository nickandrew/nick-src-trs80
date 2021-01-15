main() {
	int	(*fp)(),func1(),func2();
	int	func3();

	fp = func1;

	(*fp)(4);
	(fp)(4);
}

func1(arg)
int	arg;
{
	return arg;
}
