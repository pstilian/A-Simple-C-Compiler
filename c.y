// I pledge my Honor that I have not cheated, and will not cheat, on this assignment Peter Stilian
/* DJ PARSER */

%code provides {
  #include "lex.yy.c"
  #include <stdio.h>
  #include "ast.h"

  #define YYSTYPE ASTree *

  ASTree *pgmAST;
 
  /* Function for printing generic syntax-error messages */
  void yyerror(const char *str) {
    printf("Syntax error on line %d at token %s\n",yylineno,yytext);
    printf("(This version of the compiler exits after finding the first ");
    printf("syntax error.)\n");
    exit(-1);
  }
}

%token CLASS ID EXTENDS MAIN NATTYPE BOOLTYPE
%token TRUELITERAL FALSELITERAL AND NOT IF ELSE FOR
%token NATLITERAL PRINTNAT READNAT PLUS MINUS TIMES EQUALITY GREATER
%token STATIC ASSIGN NUL NEW THIS DOT INSTANCEOF
%token SEMICOLON LBRACE RBRACE LPAREN RPAREN
%token ENDOFFILE

%right ASSIGN
%left AND
%nonassoc EQUALITY
%nonassoc GREATER
%left PLUS MINUS
%left TIMES
%right NOT
%nonassoc INSTANCEOF
%left DOT


%start pgm

%%

pgm : classlist MAIN LBRACE vardeclist exprlist RBRACE ENDOFFILE 
    ;

classlist: classlist classdeclaration
         |
         ;

classdeclaration: CLASS id EXTENDS id LBRACE staticdeclist vardeclist methodMaybe RBRACE
                ;

staticdeclist: staticdeclist staticvardec 
             |
             ;

staticvardec: STATIC type id SEMICOLON
            ;

vardeclist: vardeclist vardeclaration SEMICOLON
          |
          ;

vardeclaration: type id
              ;

methodMaybe: methdeclist
           |
           ;

methdeclist: methdeclist methdeclaration
           |methdeclaration
           ;

methdeclaration: type id LPAREN type id RPAREN LBRACE vardeclist exprlist RBRACE
               ;

type: NATTYPE
    | BOOLTYPE
    | id
    ;

exprlist: exprlist expr SEMICOLON {$$ = appendToChildrenList($1, $2);}
        ;

id: ID
   ;

expr: expr AND expr
    | expr GREATER expr
    | expr PLUS expr
    | expr MINUS expr
    | expr EQUALITY expr
    | expr TIMES expr
    | expr DOT id
    | id ASSIGN expr
    | expr DOT id ASSIGN expr
    | expr DOT id LPAREN expr RPAREN
    | id LPAREN expr RPAREN
    | NOT expr
    | LPAREN expr RPAREN
    | NEW id LPAREN RPAREN
    | NATLITERAL
    | TRUELITERAL
    | FALSELITERAL
    | NUL
    | IF LPAREN expr RPAREN LBRACE vardeclist exprlist RBRACE ELSE LBRACE vardeclist exprlist RBRACE
    | FOR LPAREN expr SEMICOLON expr SEMICOLON expr RPAREN LBRACE vardeclist exprlist RBRACE
    | THIS
    | expr INSTANCEOF id
    | PRINTNAT LPAREN expr RPAREN
    | READNAT LPAREN RPAREN
    |id
    ;

%%

int main(int argc, char **argv) {
  if(argc!=2) {
    printf("Usage: dj-parse filename\n");
    exit(-1);
  }
  yyin = fopen(argv[1],"r");
  if(yyin==NULL) {
    printf("ERROR: could not open file %s\n",argv[1]);
    exit(-1);
  }
  /* parse the input program */

  printAST(pgmAST);

  return yyparse();
}
