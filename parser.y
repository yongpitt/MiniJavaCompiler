%{  /* Parser Specification for MINI JAVA */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "proj2.h"
#include "proj3.h"

/* global variables definitions and declarations*/
   
 tree type_ptr,tem_ptr,type_method;
 extern int yylex();
 int yycolumn,yyline;
 int yywrap(void);
 void yyerror(char *s);
 //int yylex();
 FILE *treelst;
 int is_val;
 
/* global variables definition for semantic analyizer */ 
 int num_main = 0;
 char *method_name;
 int type_dim = 0; 
 int st_id_classdecl;
 int st_id_methdecl;
 int st_id;
 int var_decl_dim;
 int var_use_dim;    //the above two dims should be matched when semantic check is performed
 int num_para;
 int num_argu;   //the above two should be matched when semantic check is performed
 int varid_in_st;
 int methodid_in_st;
 int classid_in_st;
 int num_para_inst;
%}

%token <intg> IDnum
%token <intg> ICONSTnum
%token <intg> SCONSTnum

%token EOFnum 
%token ANDnum
%token ASSGNnum
%token DECLARATIONSnum
%token DOTnum
%token ENDDECLARATIONSnum
%token EQUALnum
%token GTnum
%token INTnum
%token LBRACnum
%token LPARENnum
%token METHODnum
%token NEnum
%token ORnum
%token PROGRAMnum
%token RBRACnum
%token RPARENnum
%token SEMInum
%token VALnum
%token WHILEnum
%token CLASSnum
%token COMMAnum
%token DIVIDEnum
%token ELSEnum
%token EQnum
%token GEnum
%token IFnum
%token LBRACEnum
%token LEnum
%token LTnum
%token MINUSnum
%token NOTnum
%token PLUSnum
%token RBRACEnum
%token RETURNnum
%token TIMESnum
%token VOIDnum   

%token ERRIDnum        
%token ENTERnum        
%token TABnum          
%token QUOTEnum          
%token BACKSnum        
%token COMMENTnum      
%token ENDLESSCOMMENTnum
 
%type <tptr> Program
%type <tptr> ClassDecl ClassDecl_m
%type <tptr> ClassBody
%type <tptr> Decls Decls_l
%type <tptr> FieldDecl FieldDecl_m VarDEQVarIlComma_m
%type <tptr> VariableDeclId EQVarI_l 
%type <tptr> VariableInitializer VariableInitializerComma_m
%type <tptr> ArrayInitializer
%type <tptr> ArrayCreationExpression BRACExpression_m
%type <tptr> MethodDecl MethodDecl_m BRAC_m
%type <tptr> FormalParameterList FormalParameterList_l VALINTIDSemi_m VALINTID VALINT IDComma_m
%type <tptr> Block
%type <tptr> Type Type_a Type_b Type_ab Type_m
%type <tptr> StatementList StatementSemi_m
%type <tptr> Statement 
%type <tptr> AssignmentStatement
%type <tptr> MethodCallStatement ExpressionComma_ml
%type <tptr> ReturnStatement Expression_l
%type <tptr> IfStatement ElsePart
%type <tptr> WhileStatement
%type <tptr> Expression
%type <tptr> SimpleExpression SimpleExpression_b AfterOp
%type <tptr> Term
%type <tptr> Factor
%type <tptr> UnsignedConstant
%type <tptr> Variable Variable_a


%start Program 


%%

Program :  PROGRAMnum 
           { printf("******************semantic analysis results******************\n \n"); STInit(); }
           IDnum SEMInum ClassDecl_m 
           { 
             $$ = MakeTree(ProgramOp,$5,NullExp()) ; 
             
             if (num_main > 1)
             printf("Semantic error: there are %d main() functions \n", num_main);
             STPrint();
             printtree($$,0); 
            
           }  
        ;

ClassDecl_m :  ClassDecl
               {$$ = MakeTree(ClassOp,NullExp(),$1); }   
            |  ClassDecl_m ClassDecl  
               {$$ = MkLeftC(MakeTree(ClassOp,NullExp(),$2),$1); }
            ;
               
               
ClassDecl :  CLASSnum IDnum
               { 
                st_id_classdecl = InsertEntry($2);
                if(st_id_classdecl)
                {
                  SetAttr(st_id_classdecl,PREDE_ATTR,false);
                  SetAttr(st_id_classdecl,KIND_ATTR,CLASS);
                }
                OpenBlock();
               }
             ClassBody
             {
              $$ = MakeTree(ClassDefOp,$4,MakeLeaf(STNode,st_id_classdecl));
              CloseBlock();  
             }    
          ;


ClassBody :  LBRACEnum Decls_l RBRACEnum
             {$$ = $2; }
          |  LBRACEnum Decls_l MethodDecl_m RBRACEnum
             {$$ = MkLeftC($2,$3); }
          ;
           
Decls_l :   
            {$$ = NullExp(); } 
        |   Decls
            {$$ = $1; }
        ;
MethodDecl_m :  MethodDecl    
                {$$ = MakeTree(BodyOp,NullExp(),$1);  }
              | MethodDecl_m MethodDecl
                {$$ = MkLeftC(MakeTree(BodyOp,NullExp(),$2),$1); }
              ;
           
Decls :   DECLARATIONSnum ENDDECLARATIONSnum
          { $$ = NullExp(); }
      |   DECLARATIONSnum FieldDecl_m ENDDECLARATIONSnum
          { $$ = $2;  } 
      ;
        
FieldDecl_m :   FieldDecl    
                { $$ = MakeTree(BodyOp,NullExp(),$1);  }
             |  FieldDecl_m FieldDecl
                { $$ = MkLeftC(MakeTree(BodyOp,NullExp(),$2),$1);  }
           ;
           
           
                   
FieldDecl :  Type VarDEQVarIlComma_m SEMInum
             { type_dim = 0;  $$ = $2; }
          ;
          
VarDEQVarIlComma_m :  VariableDeclId EQVarI_l
                      {
                        tem_ptr = MakeTree(CommaOp,$1,MakeTree(CommaOp,type_ptr,$2));
                        $$ = MakeTree(DeclOp,NullExp(),tem_ptr);
                      }
                   |  VarDEQVarIlComma_m COMMAnum VariableDeclId EQVarI_l
                      { 
                       // tem_ptr = MakeTree(DeclOp,NullExp(),MakeTree(CommaOp,$1,MakeTree(CommaOp,type_ptr,$3)));
                       // $$ = MkLeftC(tem_ptr,$1);
                      }
                   ;
                   

EQVarI_l :  
            { $$ = NullExp();   }
         |  EQUALnum VariableInitializer
            { $$ = $2;   }
         ;
                 



VariableDeclId :  IDnum 
                  { 
                    st_id = InsertEntry($1);
                   // $$ = MakeLeaf(STNode,st_id);
                    if(st_id)
                     { 
                      SetAttr(st_id, PREDE_ATTR, false);
                      SetAttr(st_id, TYPE_ATTR, type_ptr);
                      if(!type_dim)
                        SetAttr(st_id, KIND_ATTR, VAR);
                      else
                       {
                        SetAttr(st_id, KIND_ATTR, ARR);
                        SetAttr(st_id, DIMEN_ATTR, type_dim);  //DIMEN_ATTR 0 indicate the variable is a scalar 
                       }
                      }                       //this is for the consistency when compare decl_dim with use_dim
                     $$ = MakeLeaf(STNode,st_id);
                  }
               |  IDnum
                  { var_decl_dim = 1; }
                  BRAC_m
                  {
                    st_id = InsertEntry($1); 
                   // $$ = MakeLeaf(STNode,st_id); 
                    if(st_id)
                     { 
                      SetAttr(st_id, PREDE_ATTR, false);
                      SetAttr(st_id, TYPE_ATTR, type_ptr);
                      SetAttr(st_id, KIND_ATTR, ARR);       // here should be ARR or VAR ???????
                      SetAttr(st_id, DIMEN_ATTR, var_decl_dim);
                     // $$ = MakeLeaf(STNode,st_id);
                     }
                    $$ = MakeLeaf(STNode,st_id);
                  }
               ;
               
BRAC_m :  LBRACnum RBRACnum
           { var_decl_dim = 1;  }
        |  BRAC_m LBRACnum RBRACnum
           { var_decl_dim++;  }
        ;
        
VariableInitializer :  Expression 
                       { $$ = $1; }
                    |  ArrayInitializer
                       { $$ = $1; }
                    |  ArrayCreationExpression
                       { $$ = $1; }
                       
ArrayInitializer :  LBRACEnum VariableInitializerComma_m RBRACEnum
                       { $$ = MakeTree(ArrayTypeOp,$2,type_ptr); }
                 ;
                 
VariableInitializerComma_m :  VariableInitializer
                         { $$ = MakeTree(CommaOp,NullExp(),$1);  }
                      |  VariableInitializerComma_m COMMAnum VariableInitializer
                         { $$ = MkLeftC(MakeTree(CommaOp,NullExp(),$3),$1);  }
                      ;
                      
ArrayCreationExpression :  INTnum BRACExpression_m
                           { $$ = MakeTree(ArrayTypeOp,$2,MakeLeaf(INTEGERTNode,0));  }
                        ;
                        
BRACExpression_m :  LBRACnum Expression RBRACnum
                    { $$ = MakeTree(BoundOp,NullExp(),$2);  }
                 |  BRACExpression_m LBRACnum Expression RBRACnum
                    { $$ = MkLeftC(MakeTree(BoundOp,NullExp(),$3),$1);  }
                    
MethodDecl :  METHODnum Type IDnum LPARENnum
              {
                       method_name = getname($3);
                       if(!strncmp(method_name, "main", 4))
                         num_main++;
 
	            	type_method = $2;  //later the type_ptr will be overwirte by FormalParameterList_l
              	st_id_methdecl = InsertEntry($3);   //so we need another variable to keep this type information
              	num_para = 0;
              	
              	if(st_id_methdecl)
              		{
              			SetAttr(st_id_methdecl, PREDE_ATTR, false);
              			SetAttr(st_id_methdecl, KIND_ATTR, PROCE);	
              	  }
              	OpenBlock();
              } 
	            FormalParameterList_l RPARENnum Block  
	            {
	            	if(st_id_methdecl)
              		{
              			SetAttr(st_id_methdecl, ARGNUM_ATTR, num_para);	
              			//$$ = MakeTree(MethodOp,MakeTree(HeadOp,MakeLeaf(IDNode,$3),$5),$7);
              	  }
	            	$$ = MakeTree(MethodOp,MakeTree(HeadOp,MakeLeaf(STNode,st_id_methdecl),$6),$8);
	            	CloseBlock();
	            }
    
                        //need to be changed to keep the type information ??????       
           |  METHODnum VOIDnum IDnum LPARENnum 
             {
                  method_name = getname($3);
                  if(!strncmp(method_name, "main", 4))
                      num_main++;

             	  type_method = NullExp(); //the method type is null
                st_id_methdecl = InsertEntry($3);
              	num_para = 0;
              	
              	if(st_id_methdecl)
              		{
              			SetAttr(st_id_methdecl, PREDE_ATTR, false);
              			SetAttr(st_id_methdecl, KIND_ATTR, PROCE);	
              	  }
              	OpenBlock();  
              } 
            FormalParameterList_l RPARENnum Block  
              {
	            	if(st_id_methdecl)
              		{
              			SetAttr(st_id_methdecl, ARGNUM_ATTR, num_para);	
              			//$$ = MakeTree(MethodOp,MakeTree(HeadOp,MakeLeaf(IDNode,$3),$5),$7);
              	  }
	            	$$ = MakeTree(MethodOp,MakeTree(HeadOp,MakeLeaf(STNode,st_id_methdecl),$6),$8);
	            	CloseBlock();
	            }
           ;
           
FormalParameterList_l :         
                          { $$ = NullExp();  }
                      |   FormalParameterList
                          { $$ = $1;  }
                      ;
                      
FormalParameterList :    VALINTIDSemi_m
                         { $$ = MakeTree(SpecOp,$1,type_ptr);  }
                    ;

VALINTIDSemi_m  :   VALINTID
                { $$ = $1;  }
            |   VALINTIDSemi_m SEMInum VALINTID
                { $$ = MkRightC($3,$1);  }
            ;



VALINTID  :   VALINT IDComma_m
              { $$ = $2;  } 
            ;

VALINT :  INTnum
          { is_val = 0; }
       |  VALnum INTnum
          { is_val = 1; }
       ;
       
IDComma_m :  IDnum
             {    
              num_para++;
              st_id = InsertEntry($1);
              
              if(is_val&&st_id)
              	{ 
              		SetAttr(st_id, PREDE_ATTR, false);
              		SetAttr(st_id, KIND_ATTR, VALUE_ARG);
              		SetAttr(st_id, TYPE_ATTR, type_ptr);
              		
              		tem_ptr = MakeTree(CommaOp,MakeLeaf(STNode,st_id),MakeLeaf(INTEGERTNode,0)); 
                  $$ = MakeTree(VArgTypeOp,tem_ptr,NullExp());
                }
              else if((!is_val)&&st_id)
                {
                	SetAttr(st_id, PREDE_ATTR, false);
              		SetAttr(st_id, KIND_ATTR, REF_ARG);
              		SetAttr(st_id, TYPE_ATTR, type_ptr);
                	tem_ptr = MakeTree(CommaOp,MakeLeaf(STNode,st_id),MakeLeaf(INTEGERTNode,0));
                  $$ = MakeTree(RArgTypeOp,tem_ptr,NullExp());                   
                }
             }
          |  IDComma_m COMMAnum IDnum
             { 
             	 num_para++;
             	 st_id = InsertEntry($3);
             	 if(st_id)
             	 {
                 tem_ptr = MakeTree(CommaOp,MakeLeaf(STNode,st_id),MakeLeaf(INTEGERTNode,0));
                 if(is_val)  
                  {
                    SetAttr(st_id, PREDE_ATTR, false);
                    SetAttr(st_id, KIND_ATTR, VALUE_ARG);
                    SetAttr(st_id, TYPE_ATTR, type_ptr);		
                    tem_ptr = MakeTree(VArgTypeOp,tem_ptr,NullExp());
                  }
                 else
                  {
                    SetAttr(st_id, PREDE_ATTR, false);
                    SetAttr(st_id, KIND_ATTR, REF_ARG);
                    SetAttr(st_id, TYPE_ATTR, type_ptr);	
                    tem_ptr = MakeTree(RArgTypeOp,tem_ptr,NullExp());
                  } 
                 $$ = MkRightC(tem_ptr,$1);
               }
             }
          ;  
          
               

Block :   Decls_l StatementList
          { $$ = MakeTree(BodyOp,$1,$2);  }
       ;
       



/* Old version for Type

Type :  IDorINTBRACDOT_ml IDorINTBRAC_ml
           {     }
        ; 

IDorINTBRAC_ml :  IDorINT BRAC_ml
                   {     }
               ;

IDorINTBRAC_m :   IDorINT BRAC_m
                  {     }
               ;

BRAC_ml :         
            {    }     
        |   BRAC_m
            {    }
        ;       

IDorINT  :   IDnum
             {     }
         |   INTnum 
             {     }
         ;


IDorINTBRACDOT_ml :     
                       {    }
                  |    IDorINTBRAC_m
                       {    }
                  |    IDorINTBRACDOT_m DOTnum IDorINTBRAC_m 
                       {     }
                  ;   

*/




Type:   
        Type_ab  {   $$ = $1;  type_ptr = $$;  }
        |   Type_ab Type_m  { $$ = MkRightC($2,$1);  type_ptr = $$; }
        ;

Type_a:
        IDnum   {   $$ = MakeLeaf(IDNode,$1); }
        |   INTnum  {   $$ = MakeLeaf(INTEGERTNode,0); }
        ;        
Type_b:
        Type_a LBRACnum RBRACnum  { type_dim = 1;  $$ = MakeTree(TypeIdOp,$1,MakeTree(IndexOp,NullExp(),NullExp()));     }
        |   Type_b LBRACnum RBRACnum  
        {   type_dim++; $$ = MkRightC(MakeTree(IndexOp,NullExp(),NullExp()),$1);     }  
        ;
Type_ab:
        Type_a  {   $$ = MakeTree(TypeIdOp,$1,NullExp());   }
        |   Type_b  {   $$ = $1;    }
        ;

Type_m:
        DOTnum Type_ab   {   $$ = MakeTree(FieldOp,$2,NullExp());    }
        |   Type_m DOTnum Type_ab     {   $$ = MkRightC(MakeTree(FieldOp,$3,NullExp()),$1);   }
        ;








           

StatementList :  LBRACEnum StatementSemi_m RBRACEnum
                 { $$ = $2; }
              ;

StatementSemi_m :  Statement 
                   { $$ = MakeTree(StmtOp,NullExp(),$1);  }
                |  StatementSemi_m SEMInum Statement 
                   { $$ = MkLeftC(MakeTree(StmtOp,NullExp(),$3),$1);  }
                ;   
               
Statement :   
              { $$ = NullExp();  }
          |   AssignmentStatement  
              { $$ = $1;  }
          |   MethodCallStatement
              { $$ = $1;  }
          |   ReturnStatement
              { $$ = $1;  }
          |   IfStatement
              { $$ = $1;  }
          |   WhileStatement
              { $$ = $1;  } 
          ;
          
              
AssignmentStatement :  Variable 
		                    {
		                      if(GetAttr(varid_in_st, DIMEN_ATTR)!= var_use_dim)
		                    	error_msg(INDX_MIS, CONTINUE, GetAttr(varid_in_st, NAME_ATTR), 0);		
		                    }
	                    ASSGNnum Expression    
                        {
                        	$$=MakeTree(AssignOp, MakeTree(AssignOp, NullExp(), $1), $4);
                        }
                    ;
                    
MethodCallStatement :  Variable LPARENnum 
	                     {
	                     	num_argu = 0;
	                    // 	if(temp_variable_entry)
	                     	//	{
	                  	//		 error_msg(ARGUMENTS_NUM2, CONTINUE, GetAttr(temp_variable_entry, NAME_ATTR) , 0);			
		                   //   }
	                     	num_para_inst = GetAttr(varid_in_st, ARGNUM_ATTR);
		                    
		                    
	                     }
	                     ExpressionComma_ml RPARENnum
                       { 
                        if(num_para_inst!= num_argu)
			                  	error_msg(ARGUMENTS_NUM2, CONTINUE, GetAttr(varid_in_st, NAME_ATTR), 0);			
		                    num_para_inst = 0;            	
                       	$$ = MakeTree(RoutineCallOp,$1,$4); 
                       }
                    ;
                   
ExpressionComma_ml :  
                      { $$ = NullExp();  }
                   |  Expression
                      { $$ = MakeTree(CommaOp,$1,NullExp()); num_argu++; }
                   |  ExpressionComma_ml COMMAnum Expression 
                      { $$ = MkRightC(MakeTree(CommaOp,$3,NullExp()),$1); num_argu++; }
                   ;
                 
ReturnStatement :  RETURNnum Expression_l
                   { $$ = MakeTree(ReturnOp,$2,NullExp());  }
                 ;
                 
Expression_l : 
                { $$ = NullExp();  } 
             |  Expression 
                { $$ = $1; }
             ;
             
IfStatement :   IFnum Expression StatementList
                {  $$ = MakeTree(IfElseOp,NullExp(),MakeTree(CommaOp,$2,$3));  } 
            |   IFnum Expression StatementList ELSEnum ElsePart
                {  $$ = MakeTree(IfElseOp,$5,$3);  }
            ;     
         
ElsePart :  
            { $$ = NullExp();   }
         |  StatementList
            { $$ = MakeTree(IfElseOp,NullExp(),MakeTree(CommaOp,NullExp(),$1));   }
         |  IfStatement
            { $$ = $1;   }
         ; 
              
WhileStatement :  WHILEnum Expression StatementList 
                  { $$ = MakeTree(LoopOp,$2,$3);   }
               ;
                
Expression :  SimpleExpression 
              { $$ = $1;  }
           |  SimpleExpression LTnum SimpleExpression 
              {$$=MakeTree(LTOp, $1, $3);}
           |  SimpleExpression LEnum SimpleExpression 
              {$$=MakeTree(LEOp, $1, $3);} 
           |  SimpleExpression EQnum SimpleExpression 
              {$$=MakeTree(EQOp, $1, $3);}              
           |  SimpleExpression NEnum SimpleExpression 
              {$$=MakeTree(NEOp, $1, $3);} 
           |  SimpleExpression GEnum SimpleExpression 
              {$$=MakeTree(GEOp, $1, $3);}
           |  SimpleExpression GTnum SimpleExpression 
              {$$=MakeTree(GTOp, $1, $3);}
           ;   


/*old simpleexpression
            
SimpleExpression :  Term OpTerm_ml
                    { $$=MkLeftC($1,$2);  }
                 |  PLUSnum Term OpTerm_ml
                    { $$=MakeTree($  }
                 |  MINUSnum Term OpTerm_ml   
                    {   }
                 ;

      
AfterOp :  PLUSnum
           { $$=MakeTree(AddOp,NullExp(),NullExp());  }
        |  MINUSnum
           { $$=MakeTree(SubOp,NullExp(),NullExp());  }
        |  ORnum
           { $$=MakeTree(OrOp,NullExp(),NullExp());  }
        ;
       
   
OpTerm_ml :  
            { $$=NullExp();   }
          | AfterOp Term
            { $$=MkRightC($2,$1);   }
          | OpTerm_ml AfterOp Term              
            { $$=MkLeftC(MkRightC($3,$2),$1);   }
          ;
 old simpleexpression*/


SimpleExpression :   SimpleExpression_b
                     { $$=$1;   }
                 |   PLUSnum SimpleExpression_b
                     { $$=$2;   }  /* this point may need change */
                 |   MINUSnum SimpleExpression_b
                     { $$=MakeTree(SubOp,$2,NullExp());  } /* this point may need change */
                 ; 

SimpleExpression_b :  Term 
                    { $$=MakeTree(AddOp,NullExp(),$1);  }
                 |  SimpleExpression_b AfterOp Term  
                    { MkRightC($3,$2); $$=MkLeftC($2,$1); }
                 ;
                 
AfterOp :  PLUSnum
           { $$=MakeTree(AddOp,NullExp(),NullExp());  }
        |  MINUSnum
           { $$=MakeTree(SubOp,NullExp(),NullExp());  }
        |  ORnum
           { $$=MakeTree(OrOp,NullExp(),NullExp());  }
        ;



          
Term:
        Factor
            {$$=$1;}
        |
        Term TIMESnum Factor
            {$$=MakeTree(MultOp,$1, $3);}
        |
        Term DIVIDEnum Factor
            {$$=MakeTree(DivOp, $1,$3);}
        |
        Term ANDnum Factor
            {$$=MakeTree(AndOp, $1, $3);}
        ;
                        
            

Factor :  UnsignedConstant
          { $$=$1;  }
       |  Variable 
          { 
          	$$=$1;
          
		        if(GetAttr(varid_in_st, DIMEN_ATTR)!= var_use_dim)
			      error_msg(INDX_MIS, CONTINUE, GetAttr(varid_in_st, NAME_ATTR), 0);
		
          }
       |  MethodCallStatement
          { $$=$1;  }
       |  LPARENnum Expression RPARENnum
          { $$=$2;  }
       |  NOTnum Factor
          { $$=$2;  }
       ;
       
UnsignedConstant :  ICONSTnum 
                    { $$=MakeLeaf(NUMNode, $1);   }
                 |  SCONSTnum
                    { $$=MakeLeaf(STRINGNode, $1);  }
                 ;
/* old version variable            
Variable :  IDnum ExpressionormlorDOTID_ml
            { $$=MakeTree(VarOp,MakeLeaf(IDNode,$1),$2); }
         ;
         
ExpressionormlorDOTID :  LBRACnum ExpressionComma_m RBRACnum
                         { $$=$2;  }
                      |  DOTnum IDnum
                         { $$=MakeTree(FieldOp,MakeLeaf(IDNode,$2),NullExp());  }
                      ;
                      
ExpressionormlorDOTID_ml :
                            { $$=NullExp();   }
                         |  ExpressionormlorDOTID
                            { $$=MakeTree(SelectOp,$1,NullExp());  }
                         |  ExpressionormlorDOTID_ml ExpressionormlorDOTID
                            { $$=MkRightC(MakeTree(SelectOp,$2,NullExp()),$1);  }
                         ;
                         
            
            
ExpressionComma_m :   Expression
                      { $$=MakeTree(IndexOp,$1,NullExp());  }
                   |  ExpressionComma_m COMMAnum Expression 
                      { $$=MkRightC(MakeTree(IndexOp,$3,NullExp()),$1); }
                   ;           
            
 */
 
 
 
Variable:
        IDnum
            {
             varid_in_st = LookUp($1);
             if(!varid_in_st)
	            {
	             error_msg(UNDECLARATION, CONTINUE, $1, 0);			
	           //  st_id = InsertEntry($1);
	           //  varid_in_st = st_id;
		          }
		          
		          //st_id = InsertEntry($1);  // to avoid redundent error messages;
		          
            	$$=MakeTree(VarOp, MakeLeaf(STNode, LookUp($1)),NullExp());
               
		          var_use_dim = 0;	
            }
        |
        Variable LBRACnum Variable_a RBRACnum
            {
                $$=$1;
                tem_ptr=$1;
                while(!IsNull(RightChild(tem_ptr)))
                    tem_ptr = RightChild(tem_ptr);
                SetRightChild(tem_ptr, MakeTree(SelectOp, $3 ,NullExp()));
                var_use_dim++;
                
            }
        |
        Variable
            {
            	
                  if(GetAttr(varid_in_st, DIMEN_ATTR)!= var_use_dim)
			         	error_msg(INDX_MIS, CONTINUE, GetAttr(varid_in_st, NAME_ATTR), 0);	
			         var_use_dim = 0; 
            }
        
        DOTnum IDnum
            {
            	//  varid_in_st = LookUp($4);  
            	//  if(!varid_in_st)
	        //        {
	        //          error_msg(UNDECLARATION, CONTINUE, GetAttr(varid_in_st,NAME_ATTR), 0);	
	        //          st_id = InsertEntry($1);
	        //          varid_in_st = st_id;		
		//              }
		          
		         //  st_id = InsertEntry($1);  // to avoid redundent error messages;
                $$ = $1;
                tem_ptr = $1;
                while(!IsNull(RightChild(tem_ptr)))
                    tem_ptr = RightChild(tem_ptr);
                SetRightChild(tem_ptr, MakeTree(SelectOp, MakeTree(FieldOp, MakeLeaf(STNode, varid_in_st), NullExp()) ,NullExp()));
                
            }
        ;
Variable_a:
        Expression
            { $$=MakeTree(IndexOp, $1,NullExp()); }
        |
        Expression COMMAnum Variable_a
            {$$=MakeTree(IndexOp, $1, $3);}       
            
                
            
%%

int main()
{
  //int table_item;
  //int characters;
  //int lexvalue;
  
  yyline = 1;  yycolumn = 0;
 
  treelst = stdout;
  
  yyparse();
 
  return(1);
}

#include "lex.yy.c"

 int yywrap(void)
    {
        return 1;
    }
    
 void yyerror(char *s) 
    {
        printf("yyerror: %s at line %d\n",s,yyline);
    }
    
