int add_a_and_b(int a, int b)
{
    return _add_a_and_b(a, b);
}

int _add_a_and_b(int a, int b)
{
    return a + b;
}

a = 123;

int main()
{
    int x = 123;
    return add_a_and_b(a, x);
}