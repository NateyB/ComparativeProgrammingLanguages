#include<stdio.h>

// Does the processing
int handleComments(char c)
{
    if (c == '/')
    {
        char next;
        if ((next = getchar()) == '*') // Begin comment
        {
            while ((next = getchar()) != '*' && next != EOF)
                if ((next = getchar()) != '/')
                    continue;
        } else if (next == '/') // Begin comment
        {
            while ((next = getchar()) != '\n' && next != EOF)
                continue;
        } else {
            putchar(c);
            putchar(next);
        }
    }
    else {
        putchar(c);
    }

    return 0;
}


int main() {
    char n;
    while ((n = getchar()) != EOF)
        handleComments(n);

    return 0;
}
