n = int(input("Enter an Integer:"))
while n != 1:
    if n % 2 == 0:        #when n is even
        n = n / 2         #divide it by 2
        print(int(n))
    else:                   #when n is not even, means odd
        n = 3 * n + 1       #multiply it by 3 and add 1
        print(int(n))     
