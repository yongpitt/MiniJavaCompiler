
#include "strtlb.h"   

int last_in_table = -1;
char *current = str_tlb;   
   /* functions to process symbol_table */
int search_table(char *rs,int len)
   {
     int i; 
     
     if(last_in_table == -1)
       return(-1); 
     for(i=0; i<=last_in_table; i++)
       {
       if(len == string_table[i].length)
       if(!strncasecmp(rs,string_table[i].real_string,len))
         {
           return(i);
         }
       }  
     return(-1);
   }
   
int put_in_table(char *rs,Token_Type type,int len)
   {
     int exist;
     if(last_in_table == LIMIT1-1)
     {
       printf("string_table overflow!!! \n");
       return(-1);
     }
     

     
     exist = search_table(rs,len);
     if(exist == -1)
     {       
       strncpy(current,rs,len);
       last_in_table++;  
       string_table[last_in_table].real_string = current;
       string_table[last_in_table].tist = type;
       string_table[last_in_table].length = len;
       
       current += len;
       current[0] = '\0';
       current++ ;
       
       return(last_in_table);
     }
     else
     return(exist);  
   }
