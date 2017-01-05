%{
  #include <stdlib.h>
  #include <string.h>
  #include "y.tab.h"
%}

%s texsci

begin     "\\begin{texsci}"
end       "\\end{texsci}"
blankline "\\BlankLine"
local     "\\Local"
mbox      "\\mbox"

integer   "\\Integer"


leftarrow "\\leftarrow"
in        "\\in"

printint "printInt"
printtext "printText"

id        [a-zA-Z_][a-zA-Z0-9_]*
int       -?[0-9]+
float     -?[0-9]+.[0-9]+
bool      "\\true"|"\\false"

dollar    "$"
retour    "\\;"


string \"(\\.|[^"])*\" 

%%

{begin}             { BEGIN(texsci);   // Start TexSci scanning mode
                      return TEXSCI_BEGIN;
                    }
<texsci>{end}       { BEGIN(INITIAL); // Reset to default scanning mode
                      return TEXSCI_END;
                    }

<texsci>{blankline} { printf("BLANKLINE"); return BLANKLINE; }
<texsci>[{}]        { return yytext[0]; }
<texsci>[()]        { return yytext[0]; }
[\n]                { }


<texsci>{local}     { printf("LOCAL"); return LOCAL; }

<texsci>{integer}   { printf("INTEGER");  return INTEGER; }

<texsci>{leftarrow} { printf("LEFTARROW"); return LEFTARROW; }
<texsci>{in}        { printf("IN");  return IN; }

<texsci>{dollar}   { return yytext[0]; }

<texsci>{retour}   { return RETOUR; }

<texsci>[+]        { return PLUS; }

<texsci>[*]        { return FOIS; }

<texsci>{mbox}     { return MBOX; }

<texsci>{printint} { return PRINTINT; }
<texsci>{printtext} { return PRINTTEXT; }

<texsci>[,]        { return yytext[0]; }

<texsci>{id}        { yylval.name = strdup(yytext);
                      return ID;
                    }
<texsci>{int}       {
                      printf("INT ");
                      yylval.ivalue = atoi(yytext);
                      return INT;
                    }

<texsci>{string}    { return STRING; }

.                  { }

%%

/*
 * texcc_lexer_free function:
 * this function frees the memory allocated for the lexer. It frees
 * flex's buffer (it supposes there is only one buffer) since flex does
 * never free it itself.
 */
void texcc_lexer_free() {
  yy_delete_buffer(YY_CURRENT_BUFFER);
  free(yy_buffer_stack);
}
