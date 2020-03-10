%{
   #include <stdio.h>
   #include <string.h>
   #include <stdbool.h>

   #define TOKEN_LIST_MAX 100
   #define TOKEN_VALUE_MAX 10
   #define SYMBOL_TABLE_MAX 100
   #define SYMBOL_MAX 10

   typedef enum { ID = 1, INT, REAL, PLUS, MINUS, MUL, DIV, ASSIGN, LP, RP } TOKEN;

   typedef struct {
      TOKEN token;
      char value[TOKEN_VALUE_MAX+1];
   }TOKEN_LIST;

   typedef struct {
      char symbol[SYMBOL_MAX+1];
      TOKEN type;
      double value;
        int visit;
   } SYMBOL_TABLE;

    typedef struct node_{
        double value;
        TOKEN type;
        char symbol_id[SYMBOL_MAX + 1];
        int index;
        struct node_* left;
        struct node_* right;
    }node;

   /* Variables */
   TOKEN_LIST token_list[TOKEN_LIST_MAX];         // 사이즈가 100인 토큰 리스트 배열
   SYMBOL_TABLE symbol_table[SYMBOL_TABLE_MAX];   // 사이즈가 100인 심볼 테이블 배열

    int token_number = 0;                     // 토큰 리스트에 저장된 토큰의 수
   int symbol_number = 0;                     // 심볼 테이블에 저장된 심볼의 수

   /* Functions */
   void do_lexical_analysis();
   void yyerror(char* );
   void initialize_symbol_table();
   bool is_symbol_duplicated(char* target);
   int find_symbol(char* target);
   void initialize_token_list();
   void print_token_list();
   void save_token(TOKEN token, char* value);
   void save_symbol(char* symbol);

    node * A(node *);
    node * Aprime(node*);
    node * E(node*);
    node * Eprime(node*);
    node * T(node*);
    node * Tprime(node*);
    node * F(node*);
    node * Fprime(node*);

    double calculator(node *root);
    void yysyn1(char* );
    void yysyn2(char* );

    int syntax_error=0;
    int parser_token = 0;
    int lex=0;
    node* syntax;
%}

id [a-zA-Z_][a-zA-Z0-9_]*


integer [1-9][0-9]*

real (0|[1-9][0-9]*)\.(0|[0-9]*[1-9])

delim [ \t\r]
ws {delim}+

under_score [_]+

digit_first [0-9]+[a-zA-Z|0-9|_]+


%%

{ws}         ;

"+"            {save_token(PLUS, "");}
"-"            {save_token(MINUS, "");}
"*"            {save_token(MUL, "");}
"/"            {save_token(DIV, "");}
"="            {save_token(ASSIGN, "");}

"("            {save_token(LP, "");}
")"            {save_token(RP, "");}


"\n"         { /* 어휘 분석기를 종료 시킨다 */ return 0;}


{integer}      {save_token(INT, yytext);}
{real}         {save_token(REAL, yytext);}

{digit_first}   {yyerror(yytext); lex=1;}
{under_score}   {yyerror(yytext);lex =1;}
{id}         { save_symbol(yytext); save_token(ID, yytext);}

.            {yyerror(yytext); lex=1;}

%%
int main()
{
    
    double result;
   initialize_symbol_table();         // 심볼 테이블을 초기화 한다.

   while(!feof(stdin)) {
        syntax_error=0;
        lex = 0;
        initialize_token_list();      // 토큰 리스트를 초기화 한다.
        printf(">");               // 프롬프트를 출력한다.
        do_lexical_analysis();         // 어휘 분석기를 호출한다.
        //print_token_list();
        
        parser_token = 0;
        syntax = A(NULL);   // 토큰리스트 출력
        if(token_number >parser_token){
            syntax_error = 1;
        }
        if(syntax == NULL){
            //printf("null\n");
            continue;
        }else if(lex==1){
            lex=0;
            continue;
        }
        else if(syntax_error!=0){
            yysyn1("");
            continue;
        }else{
            result = calculator(syntax);
            if(syntax_error!=2) printf("%f\n",result);
            syntax_error=0;
        }
        parser_token = 0;
   }
   fclose(yyin);

   return 0;
}

void initialize_symbol_table()
{
   for(int i = 0; i < SYMBOL_TABLE_MAX; i++) {
      symbol_table[i].symbol[0] = '\0';
      symbol_table[i].value = 0;
        symbol_table[i].visit = 0;
   }
}

void initialize_token_list()
{
    token_number = 0;
   for(int i = 0; i < TOKEN_LIST_MAX; i++) {
      token_list[i].token = 0;
      token_list[i].value[0] = '\0';
   }
}

void do_lexical_analysis()
{
      yyin = stdin;
      yylex();
      yyrestart(yyin);
}

void yyerror(char* e)
{
    printf("lexical error: %s\n", e);
}

void yysyn1(char* e) // syntax error
{   printf("syntax error: %s\n", e);
}

void yysyn2(char* e) // 정의되지 않은 경우
{   printf("%s는 정의되지 않음\n", e);
}

void save_token(TOKEN token, char* value)
{
   token_list[token_number].token = token;
   strcpy(token_list[token_number].value, value);
   token_number++;
}

void save_symbol(char* symbol)
{
   // 심볼이 중복되지 않는 경우
   if(!is_symbol_duplicated(symbol)) {
      // 심볼 테이블에 저장
      strcpy(symbol_table[symbol_number].symbol, symbol);
      symbol_number++;
   }
}

bool is_symbol_duplicated(char* target)
{
   for(int i = 0; i < symbol_number; i++) {
      // 중복되는 경우
      if(strcmp(symbol_table[i].symbol, target) == 0)
         return true;
   }
   // 중복 안되는 경우
   return false;
}

int find_symbol(char* target)
{
   for(int i = 0; i < symbol_number; i++) {
      // 일치하는 심볼을 찾은 경우
      if(strcmp(symbol_table[i].symbol, target) == 0)
         return i;
   }
   return -1;
}

void print_token_list()
{
   int symbol_index = 0;
   printf("%s%20s\n", "TOKEN", "LEXEME");
   for(int i = 0; i < token_number; i++) {
      switch(token_list[i].token)
      {
         case INT: printf("%s%16s\n", "INTEGER", token_list[i].value); break;
         case REAL: printf("%s%16s\n", "REAL", token_list[i].value); break;
         case ID:
            if((symbol_index = find_symbol(token_list[i].value)) != -1)
            {
               printf("%s,%d%20s\n", "ID", symbol_index+1,
                           symbol_table[symbol_index].symbol);
            }
            break;
         case PLUS: printf("%s\n", "PLUS"); break;
         case MINUS: printf("%s\n", "MINUS"); break;
         case MUL: printf("%s\n", "MUL"); break;
         case DIV: printf("%s\n", "DIV"); break;
         case ASSIGN: printf("%s\n", "ASSIGN"); break;
         case LP: printf("%s\n", "LP"); break;
         case RP: printf("%s\n", "RP"); break;
         default: break;
      }
   }
}

node * make_node(TOKEN type, char* value){ // node를 만듬 type에 따라 다르게 저장.
    node * new = (node*)malloc(sizeof(node));
    new->type = type;
    switch(type){
        case INT:
        case REAL:
            new->value = strtod(value, NULL);
            break;
        case ID:
            strcpy(new->symbol_id, value);
            break;
        default:
        break; 
    }
    return new;
}
void save_tree(node* n, node* left, node* right) // tree에 node를 추가
{
   n->left = left;
   n->right = right;
   return;
}

node* A(node* n){
      //printf("A->");
     if(token_list[parser_token].token == ID){
         ////printf("불린다 AID\n");
         //printf("idA'\n");
        int i = parser_token;
        parser_token++;
        node *t = make_node(ID, token_list[i].value);
        return Aprime(t);
    }
    else {
        //printf("F'T'E'\n");
        node *t1 = Fprime(n);
        node *t2 = Tprime(t1);
        return Eprime(t2);
    }

 }
node * Aprime(node* n){
    //printf("A\'->");
    if(token_list[parser_token].token == ASSIGN) // A' -> = id | t'e'
    {
        int i = parser_token;
        //printf("=");
        node* t1 = make_node(ASSIGN, NULL); // 새로 추가
        parser_token++;
        //printf("A\'\n");
        node* t2 = A(n);
        save_tree(t1, n, t2);
        return t1;
    }
    else{
        //printf("T\'E\'\n");
        node* t = Tprime(n);
        return Eprime(t);
    }
}

node * E(node* n){
    //printf("E->TE\'\n");
    node * t= T(n);
    return Eprime(t);
}


node * Eprime(node* n){
    if(token_list[parser_token].token == PLUS){
        //printf("E\'->+TE\'\n");
        int i = parser_token;
        parser_token++;
        node * root= make_node(PLUS, NULL); // + root
        node * t = T(n);
        save_tree(root,n,t);
        return Eprime(root);
    }

    else if(token_list[parser_token].token == MINUS){
        //printf("E\'->-TE\'\n");
        int i = parser_token;
        parser_token++;
        node * root= make_node(MINUS, NULL); // - root
        node * t = T(n);
        save_tree(root,n,t);
        return Eprime(root);
    }
    else{
        //printf("E\'-> \n");
        return n;  
    } 
}

node * T(node* n){
    //printf("T->FT\'\n");
    node * f = F(n);
    return Tprime(f);
}

node * Tprime(node* n){
    if(token_list[parser_token].token == MUL){
        //printf("T\'->*FT\'\n");
        
        int i = parser_token;
        parser_token++;

        node * root= make_node(MUL, NULL);
        node * f = F(n);
        save_tree(root, n,f);
        return Tprime(root);
    }
    else if(token_list[parser_token].token == DIV){
        //printf("T\'->/FT\'\n");
        int i = parser_token;
        parser_token++;

        node * root= make_node(DIV, NULL);
        node * f = F(n);
        save_tree(root, n,f);
        return Tprime(root);
    }
    else{
        //printf("T\'-> \n");
        return n;  
    } 
}

node * F(node* n){
    if(token_list[parser_token].token == ID){
        //printf("F->id\n");
        int i = parser_token;
        parser_token++;
        node * root= make_node(ID, token_list[i].value);
        return root;
    }
    else {
        //printf("F->F\'\n");
        return Fprime(n);
    }
}
node * Fprime(node* n){
    
    if(token_list[parser_token].token == LP){
        //printf("F\'->(E)\n");
        int i = parser_token;
        parser_token++;
        node * e = E(n);
        if(e == NULL){
            syntax_error = 1;
            return e;
        }
        if(token_list[parser_token].token == RP) {
            parser_token++;
            return e;
        }
        syntax_error = 1; // syntax error
        return NULL;
    }
    else if(token_list[parser_token].token == INT){
        //printf("F\'->int\n");
        int i = parser_token;
        parser_token++;
        node * fp_int = make_node(INT, token_list[i].value);
        return fp_int;
    }
    else if(token_list[parser_token].token == REAL){
        //printf("F\'->real\n");
        int i = parser_token;
        parser_token++;
        node * fp_real = make_node(REAL, token_list[i].value);
        return fp_real;
    }
    else if(token_list[parser_token].token == MINUS){
        //printf("F\'->-F\n");
        int i= parser_token;
        parser_token++;

        node * fp_minus = make_node(MINUS, NULL);
        node * fp_ll=make_node(REAL, "0.0");
        node * fp_rr= F(n);
        save_tree(fp_minus, fp_ll, fp_rr);
        return fp_minus;
    }
    else{
        syntax_error=1;
        return NULL;
    }
}

double calculator(node *root){
    int index=0;
    if(root != NULL){

        switch(root->type)
        {
            case INT:  return root->value; 
            case REAL: return root->value; 
            case ID:{
                index = find_symbol(root->symbol_id);
                if(index != -1 && symbol_table[index].visit == 1){
                    return symbol_table[index].value;
                }
                else{
                    yysyn2(root->symbol_id);
                    syntax_error=2;
                }
                break;
            }
        }
        if(root->left != NULL && root->right != NULL){
            switch(root->type)
            {
                case PLUS: return root->value = calculator(root->left) + calculator(root->right);
                case MINUS: return root->value = calculator(root->left) - calculator(root->right);
                case MUL: return root->value = calculator(root->left) * calculator(root->right);
                case DIV: return root->value = calculator(root->left) / calculator(root->right);
                case ASSIGN:{
                    index = find_symbol(root->left->symbol_id);
                    if(index != -1){
                        symbol_table[index].value = calculator(root->right);
                        symbol_table[index].visit = 1;
                        return symbol_table[index].value;
                    }
                    break;
                }
                default: return -1;
            } 
        }
    }
}

