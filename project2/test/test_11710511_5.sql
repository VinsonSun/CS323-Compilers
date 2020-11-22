struct X {
	int v = 0;
}

int test1() {
	struct X x;
	int y = 1;
	y = y + x;
}
