%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);

/* simple symbol table */
typedef struct var {
    char *name;
    int   value;
    struct var *next;
} var;

var *vars = NULL;

int  get_var(const char *name);
void set_var(const char *name, int value);
%}

%union {
    int   ival;
    char *sval;
}

/* tokens */
%token <ival> NUMBER
%token <sval> ID
%token PRINT IF ELSE WHILE
%token ASSIGN SEMICOLON PLUS MINUS MUL DIV LPAREN RPAREN LBRACE RBRACE
%token EQ GT LT

/* operator precedence */
%left PLUS MINUS
%left MUL  DIV
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

/* non‑terminal value types */
%type <ival> expr condition statement
/* stmt_list & compound_stmt carry no semantic value -> no type */

%%
program:
    stmt_list                { /* parsed successfully */ }
    ;

stmt_list:
      /* empty */
    | stmt_list statement
    ;

statement:
      ID ASSIGN expr SEMICOLON
        { set_var($1, $3); free($1); }
    | PRINT expr SEMICOLON
        { printf("%d\n", $2); }
    | IF LPAREN condition RPAREN statement %prec LOWER_THAN_ELSE
        { if ($3) { /* execute */ } }
    | IF LPAREN condition RPAREN statement ELSE statement
        { if ($3) { /* execute $5 */ } else { /* execute $7 */ } }
    | WHILE LPAREN condition RPAREN statement
        {
          while ($3) {
              /* interpret the body later (AST recommended) */
              break; /* placeholder */
          }
        }
    | compound_stmt
    ;

compound_stmt:
    LBRACE stmt_list RBRACE
    ;

condition:
      expr GT expr   { $$ = ($1 > $3); }
    | expr LT expr   { $$ = ($1 < $3); }
    | expr EQ expr   { $$ = ($1 == $3); }
    ;

expr:
      expr PLUS  expr  { $$ = $1 + $3; }
    | expr MINUS expr  { $$ = $1 - $3; }
    | expr MUL   expr  { $$ = $1 * $3; }
    | expr DIV   expr
        { if ($3==0){ yyerror("division by zero"); $$=0; } else $$=$1/$3; }
    | LPAREN expr RPAREN { $$ = $2; }
    | NUMBER            { $$ = $1; }
    | ID
        { $$ = get_var($1); free($1); }
    ;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int get_var(const char *name) {
    for (var *v = vars; v; v = v->next)
        if (strcmp(v->name, name)==0) return v->value;
    fprintf(stderr, "Undefined variable: %s\n", name);
    return 0;
}

void set_var(const char *name, int value) {
    for (var *v = vars; v; v = v->next) {
        if (strcmp(v->name, name)==0) { v->value = value; return; }
    }
    var *nv = malloc(sizeof *nv);
    nv->name = strdup(name);
    nv->value = value;
    nv->next = vars;
    vars = nv;
}

int main(void) {
    printf("Enter program:\n");
    return yyparse();
}
