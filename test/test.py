def sum(n):
	if (n <= 1):
		return n
	else:
		return sum(n - 1) + sum(n - 2)

x = sum(7)
print(x)