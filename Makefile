parser  :  y.tab.c strtlb.c proj2.c proj3.c
  gcc y.tab.c strtlb.c proj2.c proj3.c -o parser
	
y.tab.c :  parser.y lex.yy.c proj2.h proj3.h
	yacc parser.y
lex.yy.c :  lexer.l strtlb.h token.h
	lex lexer.l	 
