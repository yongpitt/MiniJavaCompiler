
#define LIMIT1 500   
#define LIMIT2 1000



typedef enum {IDtype,SCONSTtype} Token_Type; 

char str_tlb[LIMIT2];     
     
struct StringTableItem
{
   Token_Type tist;
   char *real_string;
   int length;
}string_table[LIMIT1];

int search_table(char *rs,int len);

int put_in_table(char *rs,Token_Type type,int len);
