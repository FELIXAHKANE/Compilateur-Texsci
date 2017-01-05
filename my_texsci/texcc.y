%{
  #include <stdio.h>
  #include <stdlib.h>
  #define TEXCC_ERROR_GENERAL 4

  void yyerror(char*);

  // Functions and global variables provided by Lex.
  int yylex();
  void texcc_lexer_free();
  extern FILE* yyin;
%}

%union {
  int ivalue;
  char* name;
  char* string;
}

%token TEXSCI_BEGIN TEXSCI_END BLANKLINE RETOUR
%token LOCAL MBOX
%token INTEGER LEFTARROW IN
%token INT 
%token PLUS FOIS
%token PRINTINT PRINTTEXT
%token <string> STRING
%token <name> ID 


%%

algorithm_list:
    algorithm_list algorithm
  | algorithm
  ;

algorithm:
    TEXSCI_BEGIN '{' ID '}' definitions BLANKLINE instruction_list TEXSCI_END
    {
      fprintf(stderr, "[texcc] info: algorithm \"%s\" parsed\n", $3);
      free($3);
    }
  ;

definitions:
    local_list
  | { printf("NO DEFINITIONS\n");}
  ;

instruction_list:
    instruction_list instruction
    { printf("MULTIPLE INSTRUCTION\n");}
  | instruction
    { printf("Enter instruction\n");}
  ;

instruction:
    '$' ID LEFTARROW expr2 '$' RETOUR
    {
      printf("EXPR ARITHMETIQUE\n");
    }
  | '$' MBOX '{' print '}' '$' RETOUR
    {
      printf("MBOX\n");
    }
  | 
    { printf("NO INSTRUCTION\n");}
  ;

expr2:
    expr1
  | expr1 PLUS expr2
    { printf("ADDITION\n");}
  ;

expr1:
    valeur
    { printf("AFFECTATION\n");}
  | ID
  ;

valeur:
    INT
    ;

print:
    PRINTINT '(' '$' ID '$' ')'
    { printf("PRINTINT\n");}
  | PRINTTEXT '(' '$' STRING '$' ')'
    { printf("PRINTTEXT\n");}
  | { printf("NO PRINT \n");}
  ;

local_list:
    LOCAL '{' '$' declaration_list '$' '}'
    { printf("LOCAL LIST\n");}
  ;

declaration_list:
   declaration_list ',' declaration
    { printf("MULTIPLE DECLARATION\n");}
  |  declaration
    { printf("DECLARATION\n");}
  ;

declaration:
    ID IN type
    { printf("DECLARATION\n");}
  ;

type:
    INTEGER
  ;

%%

int main(int argc, char* argv[]) {
  if (argc == 2) {
    if ((yyin = fopen(argv[1], "r")) == NULL) {
      fprintf(stderr, "[texcc] error: unable to open file %s\n", argv[1]);
      exit(TEXCC_ERROR_GENERAL);
    }
  } else {
    fprintf(stderr, "[texcc] usage: %s input_file\n", argv[0]);
    exit(TEXCC_ERROR_GENERAL);
  }

  yyparse();
  fclose(yyin);
  texcc_lexer_free();
  return EXIT_SUCCESS;
}
