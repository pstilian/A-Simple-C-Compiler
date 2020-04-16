/* LEXER for DJ */

%option yylineno

%{
  #define DEBUG 0
  typedef YYTOKENTYPE Token;
  Token scanned(Token t);
%}

wspace [ \t\r\n]+
ident [a-zA-Z][a-zA-Z0-9]*


%%

bool		{return scanned(BOOLTYPE);}
class		{return scanned(CLASS);}
nat		{return scanned(NATTYPE);} 
extends		{return scanned(EXTENDS);}
main		{return scanned(MAIN);}
static		{return scanned(STATIC);}
this		{return scanned(THIS);}
printNat	{return scanned(PRINTNAT);}
readNat		{return scanned(READNAT);}
instanceof	{return scanned(INSTANCEOF);}
true		{return scanned(TRUELITERAL);}
false		{return scanned(FALSELITERAL);}
null		{return scanned(NUL);}
new		{return scanned(NEW);}
for		{return scanned(FOR);}
if		{return scanned(IF);}
else		{return scanned(ELSE);}
[0-9]+		{return scanned(NATLITERAL);}
{ident}		{return scanned(ID);}
"&&"		{return scanned(AND);}
"!"		{return scanned(NOT);}
"+"		{return scanned(PLUS);}
"-"		{return scanned(MINUS);}
"*"		{return scanned(TIMES);}
"="		{return scanned(ASSIGN);}
">"		{return scanned(GREATER);}
"{"		{return scanned(LBRACE);}
"}"		{return scanned(RBRACE);}
"("		{return scanned(LPAREN);}
")"		{return scanned(RPAREN);}
"."		{return scanned(DOT);}
";"		{return scanned(SEMICOLON);}
"=="		{return scanned(EQUALITY);}

"//"	{ char c = input();
	  while(c !='\n' && c != EOF) c = input();}

{wspace} { /*skip whitespace*/ }
<<EOF>>		{return scanned(ENDOFFILE);}

.		{ if(DEBUG) printf("\n");
		  printf("Lex error on line %d: Illegal character %s\n",
				yylineno,yytext);
		  exit(-1);
		}

%%

/* process and return scanned token t */
Token scanned(Token t) {
  if(DEBUG==0) return t;

  switch(t) {
	case CLASS: printf("CLASS "); return t;
	case ID:	printf("ID(%s) ", yytext); return t;
	case EXTENDS: printf("EXTENDS "); return t;
	case MAIN:	printf("MAIN "); return t;
	case NATTYPE: printf("NATTYPE "); return t;
	case BOOLTYPE: printf("BOOLTYPE "); return t;
	case TRUELITERAL: printf("TRUELITERAL "); return t;
	case FALSELITERAL: printf("FALSELITERAL "); return t;
	case AND:	printf("AND "); return t;
	case NOT:	printf("NOT "); return t;
	case IF:	printf("IF "); return t;
	case ELSE:	printf("ELSE "); return t;
	case FOR:	printf("FOR "); return t;
	case NATLITERAL: printf("NATLITERAL(%s) ", yytext); return t;
	case PRINTNAT: printf("PRINTNAT "); return t;
	case READNAT: printf("READNAT "); return t;
	case PLUS:	printf("PLUS "); return t;
	case MINUS: printf("MINUS "); return t;
	case TIMES: printf("TIMES "); return t;
	case EQUALITY: printf("EQUALITY "); return t;
	case GREATER: printf("GREATER "); return t;
	case STATIC: printf("STATIC "); return t;
	case ASSIGN: printf("ASSIGN "); return t;
	case NUL:	printf("NUL "); return t;
	case NEW:	printf("NEW ");	return t;
	case THIS:	printf("THIS "); return t;
	case DOT:	printf("DOT "); return t;
	case INSTANCEOF: printf("INSTANCEOF "); return t;
	case SEMICOLON: printf("SEMICOLON "); return t;
	case LBRACE: printf("LBRACE "); return t;
	case RBRACE: printf("RBRACE "); return t;
	case LPAREN: printf("LPAREN "); return t;
	case RPAREN: printf("RPAREN "); return t;
	case ENDOFFILE: printf("ENDOFFILE\n"); return t;

  } 
}
