/* DJ PARSER */

%code provides {
  #include <stdio.h>
  #include "lex.yy.c"
  #include "ast.h"


  #define YYSTYPE ASTree *

  /*Global pgmAst ASTree */
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

%start pgm


/*The below precedence was derived from the AST in the doc */
%right ASSIGN /*Lowest Precedence */
%left AND
%nonassoc EQUALITY
%nonassoc GREATER
%left PLUS MINUS/*Lower Precedence */
%left TIMES /*Higher Precedence */
%right NOT
%nonassoc INSTANCEOF
%left DOT /* Highest */


%%

/* Initial Grammar */
pgm : cdl MAIN LBRACE rvdl el RBRACE ENDOFFILE
    {
        /*Create a null root program node */
        pgmAST = newAST(PROGRAM,0,0,0,yylineno);  

        /* Append the cdl AST*/        
        pgmAST = appendToChildrenList(pgmAST, $1);

        /* Append the rvdl AST */
        pgmAST = appendToChildrenList(pgmAST, $4);

        /* Append the el AST */
        pgmAST = appendToChildrenList(pgmAST, $5);
        
        /*appendToChildrenList(pgmAST, newAST(EXPR_LIST, $5, 0, 0, yylineno));*/

        /*printAST(pgmAST);*/
        

        return 0;
    }
    ;




/*Class Declaration Non Terminal */
/*Purpose of having non-empty defined mdl and seperate rvdl rules
  is to prevent ambiguity as a result of shift-reduce error when
  trying to parse a variable declaration of type ID or ID ID which 
  is the same as a prefix function declartion of type ID or ID ID */
cdl : cdl CLASS id EXTENDS id LBRACE svdl rvdl mdl RBRACE
    {
        
        $$ = newAST(CLASS_DECL, 0, 0, 0, yylineno);
 
        $$ = appendToChildrenList($$, $3);
        $$ = appendToChildrenList($$, $5);

        $$ = appendToChildrenList($$, $7);
        $$ = appendToChildrenList($$, $8);
        $$ = appendToChildrenList($$, $9);
        

        $$ = appendToChildrenList($1, $$);
    }

    | cdl CLASS id EXTENDS id LBRACE svdl rvdl RBRACE
    {
        $$ = newAST(CLASS_DECL, 0, 0, 0, yylineno);

        $$ = appendToChildrenList($$, $3);
        $$ = appendToChildrenList($$, $5);

        $$ = appendToChildrenList($$, $7);
        $$ = appendToChildrenList($$, $8);
        
        $$ = appendToChildrenList($$, newAST(METHOD_DECL_LIST, 0, 0, 0, yylineno));

        $$ = appendToChildrenList($1, $$);
    }
    |
    {
        $$ = newAST(CLASS_DECL_LIST, 0, 0, 0, yylineno);
    }
    ;

/* TypeName Terminal*/
/*type   : NATTYPE 
       | BOOLTYPE 
       ;*/

id : ID
   {
       char *identifier = strdup(yytext);
       $$ = newAST(AST_ID, 0, 0, identifier, yylineno);
   }
   ;

/*Variable Definition prefix Terminal*/
type : NATTYPE 
     {
         $$ = newAST(NAT_TYPE, 0, 0, 0, yylineno);
     }
     | id 
     {
         $$ = $1;
     }
     | BOOLTYPE 
     {
         $$ = newAST(BOOL_TYPE, 0, 0, 0, yylineno);
     }
     ;

/* Regular Variable Declartion List */
rvdl : rvdl type id SEMICOLON
     {
        $$ = newAST(VAR_DECL, $2 ,0 ,0, yylineno);
        $$ = appendToChildrenList($$, $3);

        $$ = appendToChildrenList($1, $$);
     }
     |
     {
         $$ = newAST(VAR_DECL_LIST, 0, 0, 0, yylineno);
     }
     ; 

/* Static Variable Declaration List Non-Terminal*/
svdl : svdl STATIC type id SEMICOLON
     {
         $$ = newAST(STATIC_VAR_DECL, $3, 0, 0, yylineno);
         $$ = appendToChildrenList($$, $4);

         $$ = appendToChildrenList($1, $$);
     }
     |
     {
         $$ = newAST(STATIC_VAR_DECL_LIST, 0, 0, 0, yylineno);
     }
     ;

/* method declaration list Non-Terminal
  made non empty to combat shift-reduce
  error in cdl rule 1*/ 
mdl  : mdl type id LPAREN type id RPAREN LBRACE rvdl el RBRACE
     {
         $$ = newAST(METHOD_DECL, $2, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $3);
         $$ = appendToChildrenList($$, $5);
         $$ = appendToChildrenList($$, $6);
         $$ = appendToChildrenList($$, $9);
         $$ = appendToChildrenList($$, $10);

         $$ = appendToChildrenList($1, $$);

     }
     | type id LPAREN type id RPAREN LBRACE rvdl el RBRACE
     {
         $$ = newAST(METHOD_DECL, $1, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $2);
         $$ = appendToChildrenList($$, $4);
         $$ = appendToChildrenList($$, $5);
         $$ = appendToChildrenList($$, $8);
         $$ = appendToChildrenList($$, $9);

         $$ = appendToChildrenList(newAST(METHOD_DECL_LIST, 0, 0, 0, yylineno), $$);
     }
     ;

/*main grammar
main : MAIN LBRACE rvdl el RBRACE
     ;*/

/* Variable expression block Non-Terminal
veb : LBRACE rvdl el RBRACE 
    ;
*/
/* Expression List */
el  : el expr SEMICOLON
    {
        $$ = appendToChildrenList($1, $2); 
    }
    | expr SEMICOLON
    {
        $$ = newAST(EXPR_LIST, $1, 0, 0, yylineno);
    }
    ;

/* Actual Expressions */
expr : expr MINUS expr         /* expression1 - expression2 */
     {
         $$ = newAST(MINUS_EXPR, $1, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $3);
     }
     | expr PLUS expr          /* expression1 + expression2 */
     {
         $$ = newAST(PLUS_EXPR, $1, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $3);
     }
     | expr TIMES expr         /* expression1 * expression2 */
     {
         $$ = newAST(TIMES_EXPR, $1, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $3);
     }
     | expr EQUALITY expr      /* expression1 == expression2 */
     {
         $$ = newAST(EQUALITY_EXPR, $1, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $3);
     }
     | expr GREATER expr          /* expression1 < expression2*/
     {
         $$ = newAST(GREATER_THAN_EXPR, $1, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $3);
     }
     | expr AND expr           /* expression1 && expression2 */
     {
         $$ = newAST(AND_EXPR, $1, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $3);
     }
     | NOT expr                /* !expression */
     {
         $$ = newAST(NOT_EXPR, $2, 0, 0, yylineno);
     }
     /*End Arithmetic expressions 
     */
     | IF LPAREN expr RPAREN LBRACE el RBRACE ELSE LBRACE el RBRACE
     {
        $$ = newAST(IF_THEN_ELSE_EXPR, $3, 0, 0, yylineno);

        $$ = appendToChildrenList($$, $6);

        $$ = appendToChildrenList($$, $10);
     }
     | FOR LPAREN expr SEMICOLON expr SEMICOLON expr RPAREN LBRACE el RBRACE
     {
         $$ = newAST(FOR_EXPR, $3, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $5);

         $$ = appendToChildrenList($$, $7);

         $$ = appendToChildrenList($$, $10);
     }
     | id LPAREN expr RPAREN /* id(expression) */
     {
         $$ = newAST(METHOD_CALL_EXPR, 0, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $1);

         $$ = appendToChildrenList($$, $3);
     }
     | LPAREN expr RPAREN /* (expression) */
     {
         $$ = $2;
     }
     | PRINTNAT LPAREN expr RPAREN /* printNat(expr) */
     {
         $$ = newAST(PRINT_EXPR, 0, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $3);
     }
     | THIS 
     {
         $$ = newAST(THIS_EXPR, 0, 0, 0, yylineno);
     }
     | id ASSIGN expr /* ID = expr */
     {
         $$ = newAST(ASSIGN_EXPR, 0, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $1);

         $$ = appendToChildrenList($$, $3);

     }
     | expr DOT id           /* expression1.id expression */
     {
         $$ = newAST(DOT_ID_EXPR, $1, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $3);
     }
     | expr DOT id ASSIGN expr /* expr.id = expr2 */
     {
         $$ = newAST(DOT_ASSIGN_EXPR, $1, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $3);

         $$ = appendToChildrenList($$, $5);
     }
     | expr DOT id LPAREN expr RPAREN /* expr.id(expr) */
     {
         $$ = newAST(DOT_METHOD_CALL_EXPR, $1, 0, 0, yylineno); 

         $$ = appendToChildrenList($$, $3);

         $$ = appendToChildrenList($$, $5);
     }
     | expr INSTANCEOF id    /*instanceof expression */
     {
         $$ = newAST(INSTANCEOF_EXPR, 0, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $1);

         $$ = appendToChildrenList($$, $3);
     }
     | NEW id LPAREN RPAREN  /*constructor expression */
     {
         $$ = newAST(NEW_EXPR, 0, 0, 0, yylineno);

         $$ = appendToChildrenList($$, $2);
     }
     | READNAT LPAREN RPAREN /*readNat() expression */ 
     {
         $$ = newAST(READ_EXPR, 0, 0, 0, yylineno);
     }
     | TRUELITERAL           /*True literal*/
     {
         $$ = newAST(TRUE_LITERAL_EXPR, 0, 1, 0, yylineno);
     }
     | FALSELITERAL          /*False literal */
     {
         $$ = newAST(FALSE_LITERAL_EXPR, 0, 0, 0, yylineno);
     }
     | NUL                   /* NUL literal */
     {
         $$ = newAST(NULL_EXPR, 0, 0, 0, yylineno);
     }
     | id /*ID is a possible expr on its own */
     {
         $$ = newAST(ID_EXPR, $1, 0, yytext, yylineno);

     }
     | NATLITERAL /*expr can possibly be a nat literal */
     {
         $$ = newAST(NAT_LITERAL_EXPR, 0, atoi(yytext), 0, yylineno);
     }
     ;
	
%%

int main(int argc, char **argv) {

  FILE *out;
  char *outfile;
  int temp, i;
  char check[4] = {0};

  int len = strlen(argv[1]);

  strncpy(check, &argv[1][len-3], 3);

  if(strcmp(check, ".dj"))
  {
      printf("Invalid file extension\n");
      exit(0);
  }

  outfile = malloc(len + 3);

  strncpy(outfile, argv[1], len);

  strncpy(&outfile[len-3], ".dism", strlen(".dism")+1);

  out = fopen(outfile, "w");
    
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
  yyparse();
  printAST(pgmAST);
}

