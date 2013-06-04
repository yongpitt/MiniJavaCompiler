%{  /* Lex Analyzer for MINI JAVA */


//#include <stdio.h>
//#include <ctype.h>
//#include <stdlib.h>
//#include <string.h>
//#include "token.h"

#include "strtlb.h"


/* global variables definitions and declarations */
//int yyline, yycolumn; 

extern YYSTYPE yylval;
    

   
%}
   
    
%option case-insensitive   

newline       [\n]
delim         [ \t]+



decl          declarations
enddecl       enddeclarations
int           int
method        method
program       program
val           val
while         while
class         class
else          else
if            if
return        return
void          void

identifier    [a-zA-Z][0-9a-zA-Z]*

integercons   [0-9]+
stringcons    '[^'\n]*'

errid         [0-9]+{identifier}

commentbegin       \/\*
   
%%

{newline}     {yyline++; yycolumn = 0;}
{delim}       {yycolumn += yyleng;}

{decl}        {yycolumn += yyleng; return(DECLARATIONSnum);}
{enddecl}     {yycolumn += yyleng; return(ENDDECLARATIONSnum);}
{int}         {yycolumn += yyleng; return(INTnum);}
{method}      {yycolumn += yyleng; return(METHODnum);}
{program}     {yycolumn += yyleng; return(PROGRAMnum);}
{val}         {yycolumn += yyleng; return(VALnum);}
{while}       {yycolumn += yyleng; return(WHILEnum);}
{class}       {yycolumn += yyleng; return(CLASSnum);}
{else}        {yycolumn += yyleng; return(ELSEnum);}
{if}          {yycolumn += yyleng; return(IFnum);}
{return}      {yycolumn += yyleng; return(RETURNnum);}
{void}        {yycolumn += yyleng; return(VOIDnum);}


{errid}       {yycolumn += yyleng; 
               printf("ERROR at line %d column %d: %s\n", yyline, yycolumn, "wrong ID");}


{identifier}  {
               int j;
               yycolumn += yyleng; 
               j = put_in_table(yytext,IDtype,yyleng); 
               yylval.intg = j;   
               return(IDnum);
              }
{stringcons}  {
               int k;
               yycolumn += yyleng; 
               k = put_in_table(yytext,SCONSTtype,yyleng);  
               yylval.intg = k; 
               return(SCONSTnum);
              }
              
{integercons} {
               yycolumn += yyleng; 
               yylval.intg = atoi(yytext);           
               return(ICONSTnum);
              }
              

"\'"          {yycolumn += yyleng; }
"\\"          {yycolumn += yyleng; }

{commentbegin}  {  
                 yycolumn += yyleng;
                 match();

                }                   
      
"&&"          {yycolumn += yyleng; return(ANDnum);}
":="          {yycolumn += yyleng; return(ASSGNnum);}
"."           {yycolumn += yyleng; return(DOTnum);}
"="           {yycolumn += yyleng; return(EQUALnum);}  
">"           {yycolumn += yyleng; return(GTnum);}
"["           {yycolumn += yyleng; return(LBRACnum);}
"("           {yycolumn += yyleng; return(LPARENnum);}
"!="          {yycolumn += yyleng; return(NEnum);}
"||"          {yycolumn += yyleng; return(ORnum);}  
"]"           {yycolumn += yyleng; return(RBRACnum);}
")"           {yycolumn += yyleng; return(RPARENnum);}
";"           {yycolumn += yyleng; return(SEMInum);}
","           {yycolumn += yyleng; return(COMMAnum);}
"/"           {yycolumn += yyleng; return(DIVIDEnum);}  
"=="          {yycolumn += yyleng; return(EQnum);}
">="          {yycolumn += yyleng; return(GEnum);}
"{"           {yycolumn += yyleng; return(LBRACEnum);}
"<="          {yycolumn += yyleng; return(LEnum);}
"<"           {yycolumn += yyleng; return(LTnum);}  
"-"           {yycolumn += yyleng; return(MINUSnum);}
"!"           {yycolumn += yyleng; return(NOTnum);}
"+"           {yycolumn += yyleng; return(PLUSnum);}
"}"           {yycolumn += yyleng; return(RBRACEnum);}  
"*"           {yycolumn += yyleng; return(TIMESnum);}



%%

match()  {
                char nextchar;
                  do{
                     nextchar = input();
                     yycolumn++;
                     switch ( nextchar ){
                     case '*':  nextchar = input();
                       if ( nextchar == '/')
                            {
                              yycolumn++;
                              return;
                            }
                     break;
                     case '\n': yyline++;
                       yycolumn=0;
                       break;
                     case 0:  printf("EOF found in comment");
                     exit(0);
                     default:   break;
                                        }
                   } while(1);
                   
       }
