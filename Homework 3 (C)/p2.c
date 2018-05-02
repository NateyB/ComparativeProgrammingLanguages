#include<stdlib.h>
#include<stdio.h>
#include<stdbool.h>
#include<ctype.h>

enum letters {A, C, G, T};
static const char reverse[] = {'A', 'C', 'G', 'T'};

static const int word_size = 10;
static const int branch_factor = T + 1;
static const int max_index = 1 << 2*word_size;


enum charType {WS, VALID, OTHER};


// ********************************
// BEGIN LINKED LIST IMPLEMENTATION
// ********************************
struct node {
    int data;
    struct node* next;
};

typedef struct LinkedNodes {
    struct node* head;
    struct node* tail;
    int size;
} LinkedList;

// Add to the end
void add(LinkedList* list, int num)
{
    struct node* addition = malloc(sizeof(*addition));
    addition -> data = num;
    addition -> next = NULL;

    list -> size++;

    if (list -> size == 1) {
        list -> head = addition;
        list -> tail = addition;
    } else {
        list -> tail -> next = addition;
        list -> tail = addition;
    }
}

LinkedList* newList()
{
    LinkedList* newOne = malloc(sizeof(*newOne));
    newOne -> head = NULL;
    newOne -> tail = NULL;
    newOne -> size = 0;

    return newOne;
}
// ********************************
//  END LINKED LIST IMPLEMENTATION
// ********************************

static LinkedList* counts[max_index];


// Converts the chromosome letters to numbers, for storing in the trie.
int hashChar(char c)
{
    switch (c) {
        case 'a':
        case 'A': return A;

        case 'c':
        case 'C': return C;

        case 'g':
        case 'G': return G;

        case 't':
        case 'T': return T;
    }

    fprintf(stderr, "Character '%c' (\\%d) unrecognized. Terminating.\n", c, c);
    exit(1);
}

char* convertToBaseFour(int number)
{
    char* num = malloc(sizeof(*num)*(word_size + 1));
    num[word_size] = 0;

    for (int i = word_size - 1; i >= 0; i--)
    {
        num[word_size - i - 1] = reverse[number / (1 << 2*i)];
        number %= (1 << 2*i);
    }

    return num;
}

int getIndex(char word[])
{
    int index = 0;
    for (int i = word_size - 1; i >= 0; i--)
        index += hashChar(word[i]) * (1 << 2*i);

    return index;
}

void addWord(char word[], int location)
{
    add(counts[getIndex(word)], location);
}


// Converts a linked list of integers to an array
int* toArray(LinkedList* ints) {
    int* indices = malloc((ints -> size + 1) * sizeof(int));
    struct node* current = ints -> tail -> next;
    for (int i = 0; i < ints -> size; i++)
    {
        indices[i] = current -> data;
        current = current -> next;
    }
    indices[ints -> size] = 0;

    return indices;
}

void initLinkedLists()
{
    for (int i = 0; i < max_index; i++)
        counts[i] = newList();
}

enum charType getType(char c)
{
    if (c == 'a' || c == 'c' || c == 'g' || c == 't'
           || c == 'A' || c == 'C' || c == 'G' || c == 'T')
           return VALID;
    if (isspace(c))
        return WS;

    return OTHER;
}

void skipUntilNewline(FILE* chromFile)
{
    char current;
    while ((current = fgetc(chromFile)) != '\n')
        continue;
}


int run(FILE* chromFile)
{
    skipUntilNewline(chromFile);
    int sequence_length = 0; // The number of valid consecutive characters
    int count = 0;
    char word[word_size + 1] = {0};

    char current;
    while ((current = fgetc(chromFile)) != EOF)
    {
        switch (getType(current))
        {
            case VALID: sequence_length++;
                        if (sequence_length >= word_size)
                        {
                            // Shift to the right
                            for (int i = word_size; i > 0; i--)
                                word[i] = word[i - 1];
                            word[0] = current;
                            addWord(word, count - word_size + 1);
                        } else {
                            for (int i = sequence_length; i > 0; i--)
                                word[i] = word[i - 1];
                            word[0] = current;
                        }
                        count++;
                        break;

            case WS:    continue;

            case OTHER: sequence_length = 0;
                        count++;
                        break;

            default:    fprintf(stderr, "%s\n",
                        "Did not account for an enum charType. Terminating.");
                        exit(2);
        }
    }

    fclose(chromFile);

    return 0;
}

void init() {
    initLinkedLists();
}

void output() {
    for (int i = 0; i < max_index; i++) {
        LinkedList* counter = counts[i];
        if (counter -> size == 0) // TODO Remove before submission
            continue;
        struct node* head = counter -> head;
        printf("%s", convertToBaseFour(i));
        while (counter -> size > 1) {
            printf(" %d,", head -> data);
            head = head -> next;
            counter -> size--;
        }
        printf(" %d\n", head -> data);
    }
}


int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "%s%s\n", "Expected exactly one argument—the filepath",
            " to the chromosome. Terminating.");
        return 1;
    }

    init();
    run(fopen(argv[1], "r"));
    output();

    return 0;
}
