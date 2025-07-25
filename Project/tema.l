/* Urse Adrian Dinu 331CC */

%{
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>

// Nodul stivei
typedef struct node {
    int contains[6];
    int count;
    struct node *next;
}node;

typedef struct stiva {
    struct node *top;
}stiva;

// Funtie care initializeaza stiva
void init_stack(struct stiva **stack)
{
    *stack = (stiva*)malloc(sizeof(struct stiva));
    (*stack)->top = NULL;
}

// Functie care adauga un nod in varful stivei
void push(struct stiva **stack, int v[6], int k)
{
    struct node *newnode = malloc(sizeof(struct node));
    for(int i = 0; i < 6; i++)
    {
        newnode->contains[i] = v[i];
    }
    newnode->count = k;
    newnode->next = (*stack)->top;
    (*stack)->top = newnode;
}

// Functie care elimina nodul din varful stivei
void pop(stiva **stack)
{
    if((*stack)->top != NULL) {
        struct node *aux =(*stack)->top;
        (*stack)->top = (*stack)->top->next;
        free(aux);
    }
    else
    {
        printf("Stack is empty\n");
    }
}

// Functie care printeaza nodurile din stiva
void print_stack(stiva *stack)
{
    struct node *aux = stack->top;
    while (aux)
    {
        printf("count = %d\n", aux->count);
        for(int i = 0; i < 6; i++)
        {
            printf("%d ",aux->contains[i]);
        }
        printf("\n");
        aux = aux->next;
    }
}

stiva *stack;        // Stiva obiectelor
char path[1000];     // Calea obiectelor
char temp[1000];

%}
%s IN_OBJ IN_ARRAY VALUE IGNORE_WHITESPACES
%option stack

LEFT_BRACE "{"
RIGHT_BRACE "}"
LEFT_BRACKET "["
RIGHT_BRACKET "]"
QUOTES ["]
LETTER [A-Za-z]
DIGIT [0-9]
WORD [^\\"]+
STRING \"{WORD}\"
WHITESPACE [ \r\n\t]*
SIGN [+-]

%%
    /* Starea initiala */

    /* Radacine este obiect */
<INITIAL>{LEFT_BRACE}{WHITESPACE} {
        int v[6] = {0};
        push(&stack, v, 0);
        yy_push_state(IN_OBJ);
    }

    /* Radacina este lista */
<INITIAL>{LEFT_BRACKET}{WHITESPACE} {
        int v[6] = {0};
        push(&stack, v, 0);
        yy_push_state(IN_ARRAY);
    }

    /* Starea IN_OBJ */

    /* 
        Intalnesc o cheie dupa care urmeaza ':'', 
        copiez string-ul in var. temp
        si fac trecerea la starea VALUE, pentru 
        a analiza tipul valorii
    */

<IN_OBJ>{STRING}: {

    char x[100];
    strncpy(x, yytext + 1, yyleng-3);
    x[yyleng - 3] = '\0';
    if(stack->top->next == NULL) {
        sprintf(temp,"%s",x);
    }
    else {
        sprintf(temp," -> %s",x);
    }
    yy_push_state(VALUE);
}

    /* 
        Intalnesc o cheie dupa care urmeaza ' ', 
        copiez string-ul in var. temp
        si fac trecerea la starea IGNORE_WHITESPACES, pentru 
        a citi toate whitespace-urile pana la ':'
    */

<IN_OBJ>{STRING}[ \r\n\t] {
    char x[100];
    strncpy(x, yytext + 1, yyleng-3);
    x[yyleng - 3] = '\0';
    if(stack->top->next == NULL) {
        sprintf(temp,"%s",x);
    }
    else {
        sprintf(temp," -> %s",x);
    }
    yy_push_state(IGNORE_WHITESPACES);
}

    /* 
        Intalnesc '}', s-a terminat obiectul curent,
        ii afisez continutul, updatez calea,
        il elimin din stiva de obiecte, 
        revin la starea precedenta prin yy_pop_state.
    */

<IN_OBJ>{RIGHT_BRACE} {
        if(stack->top->next == NULL) {
            printf("radacina contine ");
        }
        else {
            printf("%s contine ",path);
        }

        int k = 0;
        for(int i = 0; i < 6; i++) {
            if(stack->top->contains[i] == 1) {
                k++;
            }
        }

        if(stack->top->contains[0] == 1) {
            if(k > 1) {
                printf("numere, ");
            }
            else {
                printf("numere");
            }
            k--;
        }

        if(stack->top->contains[1] == 1) {
             if(k > 1) {
                printf("siruri, ");
             }
             else
             {
                printf("siruri");
             }
             k--;
        }

        if(stack->top->contains[2] == 1) {
            if(k > 1) {
                printf("booleeni, ");
            }
            else
            {
                 printf("booleeni");
            }
            k--;
        }

        if(stack->top->contains[3] == 1) {
            if(k > 1) { 
                printf("liste, ");
            }
            else
            {
                printf("liste");
            }
            k--;
        }

        if(stack->top->contains[4] == 1) {
            if(k > 1) {
                printf("obiecte, ");
            }
            else {
                printf("obiecte");
            }
            k--;
        }

        if(stack->top->contains[5] == 1) {
            if(k > 1) {
                printf("null, ");
            }
            else {
                printf("null");
            }
            k--;
        }


        if(path[strlen(path)-1]==']') {
            if(strlen(path)==3) {
                path[0]='\0';
            }
            else {
                path[strlen(path)-4]= '\0';
            }

        }
        else {
            int index = strlen(path) - 1;
            while(path[index]!= '-' && index>=0) {
                index--;
            }
            if(index == -1) {
                path[0] ='\0';
            }
            else {
                path[index -1] = '\0';
            }
        }
        yy_pop_state();
        pop(&stack);
        printf("\n");
    }

     /* Starea WHITESPACE */
     
     /* 
        Citesc toate whitespace-urile pana la :,
        fac trecerea la starea VALUE, pentru a analiza tipul
        valorii
     */

<IGNORE_WHITESPACES>{WHITESPACE}: {
    yy_pop_state();
    yy_push_state(VALUE);
}

    /* Starea VALUE */
    
    /* Obiectul curent contine un alt obiect */
    
    /* 
        Concatenez la cale temp, setez la 1 tipul obiect,
        pentru nodul din varful stivei, creez un nod nou,
        pe care il adaug in stiva de obiecte, 
        pun starea curenta in stiva, si fac trecerea 
        la starea IN_OBJ
    */

<VALUE>{WHITESPACE}{LEFT_BRACE} {
    strcat(path,temp);
    stack->top->contains[4] = 1;
    int v[6] = {0};
    push(&stack, v, 0);
    yy_pop_state();
    yy_push_state(IN_OBJ);
}

    /* Obiectul curent contine o lista de obiecte */
    
    /* 
        Concatenez la cale temp, setez la 1 tipul lista,
        pentru nodul din varful stivei, creez un nod nou,
        pe care il adaug in stiva, pun starea curenta in stiva,
        si fac trecerea la starea IN_ARRAY
    */

<VALUE>{WHITESPACE}{LEFT_BRACKET}[^" tnf0-9\[\]] {
    yyless(yyleng - 1);
    strcat(path,temp);
    stack->top->contains[3] = 1;
    int v[6] = {0};
    push(&stack, v, 0);
    yy_pop_state();
    yy_push_state(IN_ARRAY);
    }

    /* Obiectul curent contine liste */
    
    /* 
        Setez la 1 tipul lista pentru nodul din varful stivei,
        revin la starea precedenta prin yy_pop_state.
    */

<VALUE>{WHITESPACE}{LEFT_BRACKET}[" tnf0-9\[\]] {
    stack->top->contains[3] = 1;
    yy_pop_state();
    }
    
    /* Obiectul curent contine siruri */

    /* 
        Setez la 1 tipul siruri pentru nodul din varful stivei,
        revin la starea precedenta prin yy_pop_state.
    */

<VALUE>{WHITESPACE}{QUOTES} {
        stack->top->contains[1] = 1;
         yy_pop_state();
    }

    /* Obiectul curent contine numere */

    /* 
        Setez la 1 tipul numere pentru nodul din varful stivei,
        revin la starea precedenta prin yy_pop_state.
    */

<VALUE>{WHITESPACE}{DIGIT} {
        stack->top->contains[0] = 1;
        yy_pop_state();
    }

<VALUE>{WHITESPACE}{SIGN} {
        stack->top->contains[0] = 1;
        yy_pop_state();
    }

    /* Obiectul curent contine booleeni */

    /* 
        Setez la 1 tipul booleeni pentru nodul din varful stivei,
        revin la starea precedenta prin yy_pop_state.
    */

<VALUE>{WHITESPACE}"t" {
        stack->top->contains[2] = 1;
        yy_pop_state();
    }

<VALUE>{WHITESPACE}"f" {
        stack->top->contains[2] = 1;
        yy_pop_state();
    }

    /* Obiectul curent contine null */

    /* 
        Setez la 1 tipul null pentru nodul din varful stivei,
        revin la starea precedenta prin yy_pop_state.
    */
    
<VALUE>{WHITESPACE}"n" {
        stack->top->contains[5] = 1;
        yy_pop_state();
    }


     /* Starea IN_ARRAY */

     /* 
        Intalnesc o '{', adaug la cale indexul elementului curent,
        incrementez count-ul nodului din varf, creez un nod nou,
        pe care il adaug in stiva, pun starea curenta in stiva,
        si fac trecerea la starea IN_OBJ
    */
    
<IN_ARRAY>{WHITESPACE}{LEFT_BRACE} {
    if(stack->top->next == 0 ) {
        sprintf(temp,"[%d]",stack->top->count);
    }
    else {
        sprintf(temp," [%d]",stack->top->count);
    }
    stack->top->count++;
    int v[6] = {0};
    push(&stack, v, 0);
    strcat(path,temp);
    yy_push_state(IN_OBJ);
    }


    /* 
        Intalnesc o ']', lista s-a terminat,
        updatez calea, elimin nodul din varful stivei,
        revin la starea precedenta prin yy_pop_state
    */

<IN_ARRAY>{RIGHT_BRACKET} {
    int index = strlen(path) - 1;
    while(path[index]!= '-' && index>=0) {
        index--;
    }
    if(index == -1) {
        path[0] = '\0';
    }
    else {
        path[index -1] = '\0';
    }
    stack->top->count = 0;
    pop(&stack);
    yy_pop_state();
    }

.|\n {;}
%%

int main(int argc, char *argv[]) {
    init_stack(&stack);
    yyin = fopen(argv[1],"r"); 
    yylex();
    return 0;
}