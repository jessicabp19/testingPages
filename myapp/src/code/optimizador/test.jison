/* description: Parsea c3d y lo mete en una lista de instrucciones donde 
    clasifica el tipo de instrucción.
    
    TIPOS DE INSTRUCCION = asignación,  */

%{
     /*Acá importo mis cosas errores, tokens para la tabla de símbolos y eso*/
     const { Instruccion } = require('./codigo/instruccion')
     //const { Optimizador } = require('src/code/optimizador/codigo/optimizador')

     var instrucciones = [];
     var pilaexp =  [];
%}

%lex

%options case-insensitive
number  [0-9]+("."[0-9]+)?\b 


%%

\s+                 /* skip whitespace */
"//".*										/* skip */
[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/]			/* skip */
[ \r\t]+  			                            /* skip */

// agrupadores 
"["                   return '[';
"]"                   return ']';
"("                   return '(';
")"                   return ')';
"{"                   return '{';
"}"                   return '}';

// printf
"print"               return 'print';
"printf"               return 'printf';
"%c"				          return '%c';
"%d"				          return '%d';
"%f"				          return '%f';

// header
"#include <stdio.h>"    return 'hc1';
"#include <math.h>"    return 'hc2';


// operaciones condicionales

"<="                   return '<=';
"<"                    return '<';
">="                   return '>=';
">"                    return '>';
"=="                   return '==';
"!="                   return '!=';

// operaciones artiméticas
"+"                   return '+';
"-"                   return '-';
"*"                   return '*';
"/"                   return '/';
"%"                   return '%';
"="                   return '=';


// Palabras reservadas
"goto"                return 'goto';
"if"				          return 'if';
"return"				      return 'return';

// tiempo de ejecución
"Heap"		          return 'Heap';
"Stack"	          return 'Stack';
"SP"                    return 'SP';
"HP"                    return 'HP';
"P"                    return 'SP';
"H"                    return 'HP';

// funciones
"void"				          return 'void';
"main"				          return 'main';

// types

"int"                   return 'int';
"char"                  return 'char';
"double"                return 'double';

// variables y sus nombres
("T"|"t")[0-9]+                   return 'temporal';
("L"|"l")[0-9]+                   return 'etiqueta';
([a-zA-Z_])[a-zA-Z0-9_ñÑ]*\b      return 'id';
{number}                          return 'number';

// Otros cosos
";"                   return ';';
":"                   return ':';
"\""                  return '"';
"'"                   return '\'';
","                   return ',';

<<EOF>>               return 'EOF'
.                     return 'INVALID'

// 

/lex

/* Asociación de operadores y precedencia */
%start ini

%%

ini
	: instrucciones EOF {
		// retorno la lista de tokens
    console.log('-->');
    console.log(instrucciones)
    return instrucciones;
	}
;

instrucciones
	: instrucciones instruccion 	{ }
	| instruccion					        { }
;


instruccion
  : etiqueta ':'                { /*etiqueta pal salto*/ 
                                  $$ = $1 +$2;
                                  instrucciones.push(new Instruccion('etiqueta', $$, '', '', '', ''));
                                }
  | goto etiqueta ';'           { /*salto*/
                                  $$ = $1 +$2 + $3;
                                  instrucciones.push(new Instruccion('salto', $$, '', '', '', ''));
                                }
  | if '(' condition ')' goto etiqueta ';'    { /*if*/ /*  TODO TODO TODO TODO TODO TODO TODO  */
                                                $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7
                                                instrucciones.push(new Instruccion('salto_condicional', $$, '', '', '', ''));
                                              }
  | idsf '=' exp ';'      { /*asignación*/}
  | asignacionStruct        { /*asignación a estructuras*/}
  | prints                  {/* Prints */}
  | id '(' ')' ';'          {/* llamada a métodos */
                              $$ = $1 + $2 + $3 + $4;
                              instrucciones.push(new Instruccion('llamada_metodo', $$, '', '', '', ''));                                
                            }
  | voids                   {/*  finalización de un método */}
  | return ';'              {/* return  */
                              instrucciones.push(new Instruccion('return', 'return;', '', '', '', ''));                                
                            }
  | return '(' ')' ';'      {/* return  */
                              instrucciones.push(new Instruccion('return', 'return();', '', '', '', ''));                                
                            }

  /* Header */
  | headers
;

headers
  : hc1
  | hc2
  | types Heap '[' number ']' ';'
  | types Stack '[' number ']' ';'
  | types SP ';'
  | types HP ';'
  | types tempos ';'
  | headers
;

tempos
  : temporal ',' tempos
  | temporal
;

voids
  : void main '(' ')' '{' instrucciones'}'
  | void id '(' ')' '{' instrucciones'}'
;

prints
  : printf '(' '"'  params '"' ',' '(' types ')' ids ')' ';'
;

types
  : int
  | char
  | double
;

params 
  : '%c'
  | '%d'
  | '%f'
;

asignacionStruct
  : Heap '[' ids ']' '=' exp ';'
  | Stack '[' ids ']' '=' exp ';'
  | Heap '[' '(' types ')' ids ']' '=' exp ';'
  | Stack '[' '(' types ')' ids ']' '=' exp ';'
;

exp
  : ids '+' ids       { $$ = $1 + $2 + $3 }
  | ids '-' ids       { $$ = $1 + $2 + $3 }
  | ids '*' ids       { $$ = $1 + $2 + $3 }
  | ids '/' ids       { $$ = $1 + $2 + $3 }
  | ids '%' ids       { $$ = $1 + $2 + $3 }
  | Heap '[' ids ']'      { $$ = $1 + $2 + $3 + $4 }
  | Stack '[' ids ']'     { $$ = $1 + $2 + $3 + $4 }
  | Stack '[' '(' types ')' ids']'  { $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7 }
  | Heap '[' '(' types ')' ids']'   { $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7 }
  | ids       { $$ = $1 }
;

condition
  : ids '<' ids     { $$ = $1 + $2 + $3 }
  | ids '>' ids     { $$ = $1 + $2 + $3 }
  | ids '<=' ids    { $$ = $1 + $2 + $3 }
  | ids '>=' ids    { $$ = $1 + $2 + $3 }
  | ids '==' ids    { $$ = $1 + $2 + $3 }
  | ids '!=' ids    { $$ = $1 + $2 + $3 }
;

ids
  : temporal  { $$ = $1 }
  | SP        { $$ = $1 }
  | HP        { $$ = $1 }
  | number    { $$ = $1 }
  | id        { $$ = $1 }
  | '-' ids   { $$ = $1 + $2 }
;

idsf 
  : temporal    { $$ = $1 }
  | SP    { $$ = $1 }
  | HP    { $$ = $1 }
  | id    { $$ = $1 }
;