/******************************EXPORTACIONES*******************************/
%{
    const { parse } = require ('../analizadorXPath/Xpath')
    const grammar = require('../analizadorXML/grammar')
    const { Simbolo } = require ('./AST/Simbolo')
    const { Entorno } = require ('./AST/Entorno')
    const { AST } = require ('./AST/AST')
    const { For } = require ('./Instrucciones/For')
    const { Let } = require ('./Instrucciones/Let')
    const { Where } = require ('./Instrucciones/Where')
    const { Return } = require ('./Instrucciones/Return')

    const { Tipo } = require('./AST/Tipo')
    const { Primitivo } = require ('./Expresiones/Primitivo')
    const { Operacion, Operador } = require ('./Expresiones/Operacion')

    //se crea el entorno global
    var Entorno_Global = new Entorno('global',null)
    //se crea el ast y se le pasa el entorno global
    var Arbol_AST = new AST([],Entorno_Global)

    var errores = [];

%}
 
/******************************LEXICO***************************************/ 

%lex 

%options case-sensitive

escapechar                          [\'\"\\bfnrtv]
escape                              \\{escapechar}
acceptedcharsdouble                 [^\"\\]+
stringdouble                        {escape}|{acceptedcharsdouble}
stringliteral                       \"{stringdouble}*\"
entero                              [0-9]+("."[0-9]+)?


%%
\s+                             /* skip white space */

// XPATH 
"child"                     return 'child'  

"descendant-or-self"        return 'descendantorself'
"following-sibling"         return 'followingsibling'
"preceding-sibling"     return 'precedingsibling'
"ancestor-or-self"      return 'ancestororself'

"descendant"                return 'descendant'
"following"             return 'following'
"preceding"             return 'preceding'
"ancestor"              return 'ancestor'

"attribute"                 return 'attribute'
"self"                      return 'self'
"namespace"             return 'namespace'
"parent"                return 'parent'
"text"                 return 'text'
"node"                 return 'node'
"position"             return 'position'
"last"                 return 'last'

//XQUERY
"for"   return 'for'
"let"   return 'let'
"where" return 'where'
"order by" return 'order'
"return"    return 'return'
"to"    return 'to'
"in"    return 'in'
"doc" return 'doc'
"eq"    return 'eq' // =
"ne"    return 'ne' // !=
"it"    return 'it' // <
"le"    return 'le' // <=
"gt"    return 'gt' // >
"ge"    return 'ge' // >=
","     return 'coma'
"as"    return 'as'
"if"    return 'rif'
"then"  return 'rthen'
"else"  return 'relse'

//TYPES
"string" return 'string'
"date" return 'date'
"decimal" return 'dec'
"integer" return 'integer'
"int" return 'int'
"long" return 'long'
"short" return 'short'
"boolean" return 'boolean'
"double" return 'double'
"float" return 'float'



//FUNCTIONS
"declare" return 'dec'
"function" return 'fun'
"number" return 'number'
"substring" return 'substring'
"upper-case" return 'up_case'
"lower-case" return 'low_case'

//PREFIX
"fn" return 'fn'
"xs" return 'xs'
"?" return  'quest'
"local" return 'local'

/* LOGIC OPERATOR */

"and"                   return 'land'
"or"                    return 'lor'

/* RELATIONAL OPERATOR */
"="                    return 'igual'
"eq"                   return 'eq'
"!="                   return 'diferente'
"ne"                    return 'ne'
"<="                   return 'menorigual'
"le"                    return 'le'
"<"                    return 'menorque'
"lt"                    return 'lt'
">="                   return 'mayorigual'
"ge"                    return 'ge'
">"                    return 'mayorque'
"gt"                    return 'gt'

/* ARITHMETIC OPERATOR */
"+"                     return 'mas'
"-"                     return 'menos'
"*"                     return 'por'
"div"                   return 'div' 
"mod"                   return 'mod'

/* SYMBOL */
"["                     return 'c_abre'
"]"                     return 'c_cierra'
"{"                     return 'l_abre'
"}"                     return 'l_cierra'
"("                     return 'p_abre'
")"                     return 'p_cierra'
"::"                    return 'cpuntos'
":"                     return 'dpuntos'
".."                    return 'ppunto'
"."                     return 'punto'
";"                     return 'pyc'
"$"                     return 'dollasign'
"@"                     return 'at'
"|"                     return 'or'
"//"                    return 'd_axis'
"/"                     return 'axis'

// OTHER
{stringliteral}                     return 'StringLiteral'
{charliteral}                       return 'CharLiteral'
(([0-9]+"."[0-9]*)|("."[0-9]+))|[0-9]+    return 'numero';
[a-zA-ZÀ-ÿ][a-zA-ZÀ-ÿ0-9_ñÑ]*             return 'identificador';  

//any
(.)                                       return 'any'


//errores
. {  
    console.error('Error léxico: ' + yytext + ', linea: ' + yylloc.first_line + ', columna: ' + yylloc.first_column);
    errores.push({'Error Type': 'Lexico', 'Row': yylloc.first_line, 'Column': yylloc.first_column, 'Description': 'El caracter: '+yytext+' no pertenece al lenguaje' });
}


<<EOF>>                         return 'EOF'

/lex

// DEFINIMOS PRESEDENCIA DE OPERADORES
%left 'lor'
%left 'land' 
%left 'menorque' 'menorigual' 'mayorque' 'mayorigual' 'igual' 'diferente'
%left 'lt' 'le' 'gt' 'ge' 'eq' 'ne'
%left 'mas' 'menos' 
%left 'por' 'div'
%left 'mod'

 

/* operator associations and precedence */

%start BEGIN

%%

/******************************SINTACTICO***************************************/ 

BEGIN: INSTRUCCIONES EOF { console.log(Arbol_AST); return $$;}                    
;

INSTRUCCIONES: INSTRUCCIONES XQUERY
            | XQUERY { $$ = $1 }
;

XQUERY: FLWOR { $$ = $1 }
    | CALL
    | FUNCTION
;

FLWOR: FOR LET WHERE ORDER RETURN           {  //actualizacion: aqui hay que ejecutar las instrucciones del for

                                                //ejecutando for
                                                for(let inst_for of $1){
                                                    inst_for.ejecutar(Arbol_AST.getEntorno('flwor'));
                                                }
                                                
                                                //ejecutando let
                                                for(let inst_let of $2){
                                                    inst_let.ejecutar(Arbol_AST.getEntorno('flwor'));
                                                }

                                                //ejecutando where
                                                for(let inst_where of $3){
                                                    inst_where.ejecutar(Arbol_AST.getEntorno('flwor'));
                                                }

                                                //ejecutando return
                                                $$ = $5.ejecutar(Arbol_AST.getEntorno('flwor'));
                                                

                                            }

                                            
;
 
FOR: for DEFINITION             {   
                                  $$ = $2;
                                }
    |                           { $$ = [] }
;
 
DEFINITION: dollasign identificador in SOURCE DEFINITION    { 

                                                                let inst1 = [];
                                                                let inst_for1 = new For(@1.first_line, @1.first_column, $4, $2);
                                                                inst1.push(inst_for1);                                                                
                                                                $$ = inst1.concat($5);


                                                            }
    | coma dollasign identificador in SOURCE DEFINITION     {
                                                                let inst2 = [];
                                                                let inst_for2 = new For(@1.first_line, @1.first_column, $5, $3);
                                                                inst2.push(inst_for2);
                                                                $$ = inst2.concat($6);

                                                            }
    |                                                       { $$ = [] }
;

SOURCE: doc p_abre StringLiteral p_cierra PATH  {   
                                                    $$ = $4;
                                                    Arbol_AST.CrearEntorno('flwor', Entorno_Global);

                                                }
    | PATH                                      { 
                                                    $$ = $1;
                                                    Arbol_AST.CrearEntorno('flwor', Entorno_Global);
                                                }
    | RANK                                      {  
                                                    $$ = $1;
                                                    Arbol_AST.CrearEntorno('flwor', Entorno_Global);
                                                }
;

PATH: PATH axis                      { $$ = $1+$2; }  
    | PATH d_axis                    { $$ = $1+$2; }
    | PATH AXISNAME                  { $$ = $1+$2; }
    | PATH identificador             { $$ = $1+$2; }
    | PATH punto                     { $$ = $1+$2; }
    | PATH ppunto                    { $$ = $1+$2; }
    | PATH por                       { $$ = $1+$2; }
    | PATH at                        { $$ = $1+$2; }
    | PATH text                      { $$ = $1+$2; }
    | PATH node                      { $$ = $1+$2; }
    | PATH p_abre                    { $$ = $1+$2; }
    | PATH p_cierra                  { $$ = $1+$2; }
    | PATH c_abre                    { $$ = $1+$2; }
    | PATH c_cierra                  { $$ = $1+$2; }
    | PATH numero                    { $$ = $1+$2; }
    | PATH StringLiteral             { $$ = $1+$2; }
    | PATH last                      { $$ = $1+$2; }
    | PATH position                  { $$ = $1+$2; }
    | PATH mayorque                  { $$ = $1+$2; }
    | PATH menorque                  { $$ = $1+$2; }
    | PATH mayorigual                { $$ = $1+$2; }
    | PATH menorigual                { $$ = $1+$2; }
    | PATH mas                      { $$ = $1+$2; }
    | PATH menos                    { $$ = $1+$2; }
    | PATH div                      { $$ = $1+$2; }
    | PATH mod                      { $$ = $1+$2; }
    | PATH igual                    { $$ = $1+$2; }
    | PATH diferente                { $$ = $1+$2; }
    | axis                      { $$ = $1; }  
    | d_axis                    { $$ = $1; }
    | AXISNAME                  { $$ = $1; }
    | identificador             { $$ = $1; }
    | punto                     { $$ = $1; }
    | ppunto                    { $$ = $1; }
    | por                       { $$ = $1; }
    | at                        { $$ = $1; }
    | text                      { $$ = $1; }
    | node                      { $$ = $1; }
    | p_cierra                  { $$ = $1; }
    | c_abre                    { $$ = $1; }
    | c_cierra                  { $$ = $1; }
    | numero                    { $$ = $1; }
    | StringLiteral             { $$ = $1; }
    | last                      { $$ = $1; }
    | position                  { $$ = $1; }
    | mayorque                  { $$ = $1; }
    | menorque                  { $$ = $1; }
    | mayorigual                { $$ = $1; }
    | menorigual                { $$ = $1; }
    | mas                  { $$ = $1; }
    | menos                { $$ = $1; }
    | div                  { $$ = $1; }
    | mod                  { $$ = $1; }
    | igual                 { $$ = $1; }
    | diferente             { $$ = $1; }
;

AXISNAME: ancestor cpuntos              { $$ = $1+$2; }
        | ancestororself cpuntos        { $$ = $1+$2; }
        | attribute cpuntos             { $$ = $1+$2; }
        | child cpuntos                 { $$ = $1+$2; }
        | descendant cpuntos            { $$ = $1+$2; }
        | descendantorself cpuntos      { $$ = $1+$2; }
        | following cpuntos             { $$ = $1+$2; }
        | followingsibling cpuntos      { $$ = $1+$2; }
        | namespace cpuntos             { $$ = $1+$2; }
        | parent cpuntos                { $$ = $1+$2; }
        | preceding cpuntos             { $$ = $1+$2; }
        | precedingsibling cpuntos      { $$ = $1+$2; }
        | self cpuntos                  { $$ = $1+$2; }
;

LET: let DEF_LET                      { $$ = $2 }
    |                                 { $$ = [] }
;

DEF_LET: dollasign identificador dpuntos igual EXPRESION DEF_LET //creamos variables en la tabla de simbolosdel entorno FLWOR y le mandamos los valores
                                                            {
                                                                Arbol_AST.CrearEntorno('flwor', Entorno_Global); 
                                                                let let1 = [];
                                                                let inst_let1 = new Let(@1.first_line, @1.first_column, $5, $2);
                                                                let1.push(inst_let1);                                                                
                                                                $$ = let1.concat($6);
                                                            }
    | coma dollasign identificador dpuntos igual EXPRESION DEF_LET
                                                            {
                                                                Arbol_AST.CrearEntorno('flwor', Entorno_Global); 
                                                                let let2 = [];
                                                                let inst_let2 = new Let(@1.first_line, @1.first_column, $6, $3);
                                                                let2.push(inst_let2);                                                                
                                                                $$ = let2.concat($7);
                                                            }
    |                                                       { $$ = [] }
;

WHERE: where DEF_WHERE      {
                                $$ = $2;
                            }
    |
;

DEF_WHERE: dollasign identificador WHERE_PATH DEF_WHERE     //arreglo de instrucciones where
                                                            {
                                                                let where1 = [];
                                                                let inst_where1 = new Where(@1.first_line, @1.first_column, $3, $2);
                                                                where1.push(inst_where1);                                                                
                                                                $$ = where1.concat($4);
                                                            }

        | land dollasign identificador WHERE_PATH DEF_WHERE 
                                                            {
                                                                let where2 = [];
                                                                let inst_where2 = new Where(@1.first_line, @1.first_column, $4, $3);
                                                                where2.push(inst_where2);                                                                
                                                                $$ = where2.concat($5);
                                                            }
        |                                                   { $$ = [] }
;
 
WHERE_PATH:  axis EXP_WHERE WHERE_PATH { 
                                            $$ = [];
                                            $$.push($2);
                                            $$ = $$.concat($3);
                                        }
        |                               { $$ = []; }
;

EXP_WHERE: EXP_WHERE menorque EXP_WHERE             { $$ = $1.getValorImplicito({})+$2+$3.getValorImplicito({});}
        | EXP_WHERE lt EXP_WHERE                    { $$ = $1.getValorImplicito({})+$2+$3.getValorImplicito({});}
        | EXP_WHERE menorigual EXP_WHERE            { $$ = $1.getValorImplicito({})+$2+$3.getValorImplicito({});}
        | EXP_WHERE le EXP_WHERE                    { $$ = $1.getValorImplicito({})+$2+$3.getValorImplicito({});}
        | EXP_WHERE mayorque EXP_WHERE              { $$ = $1.getValorImplicito({})+$2+$3.getValorImplicito({});}
        | EXP_WHERE gt EXP_WHERE                    { $$ = $1.getValorImplicito({})+$2+$3.getValorImplicito({});}
        | EXP_WHERE mayorigual EXP_WHERE            { $$ = $1.getValorImplicito({})+$2+$3.getValorImplicito({});}
        | EXP_WHERE ge EXP_WHERE                    { $$ = $1.getValorImplicito({})+$2+$3.getValorImplicito({});}
        | EXP_WHERE igual EXP_WHERE                 { $$ = $1.getValorImplicito({})+$2+$3.getValorImplicito({});}
        | EXP_WHERE eq EXP_WHERE                    { $$ = $1.getValorImplicito({})+$2+$3.getValorImplicito({});}
        | EXP_WHERE ne EXP_WHERE                    { $$ = $1.getValorImplicito({})+$2+$3.getValorImplicito({});}
        | F                                         { $$ = $1; }
;


ORDER: order CONT_ORDER    
                        {

                        }
    |
;

CONT_ORDER: dollasign identificador ORDER_PATH CONT_ORDER
        | coma dollasign identificador ORDER_PATH CONT_ORDER
        |
;

ORDER_PATH: axis identificador ORDER_PATH
            | axis at identificador ORDER_PATH
            | 
;

RETURN: return dollasign PATH       {
                                        $$ = new Return(@1.first_line, @1.first_column, '', '/'+$3);
                                    }
    | return EXPRESION              {
                                        $$ = new Return(@1.first_line, @1.first_column, $2.getValorImplicito({}),'');
                                    }
    | return CONDITION              { $$ = $2 }
;

CONDITION: rif p_abre EXPRESION p_cierra rthen IF_RES relse IF_RES 
                                                                        {
                                                                            if($3.getValorImplicito({})){
                                                                                $$ = $6;
                                                                            }
                                                                            else{
                                                                                $$ = $8;
                                                                            }
                                                                        }
;

IF_RES: dollasign PATH          {
                                    $$ = new Return(@1.first_line, @1.first_column, '', '/'+$2);
                                }

    | EXPRESION                 {
                                    $$ = new Return(@1.first_line, @1.first_column, $1.getValorImplicito({}),'');
                                }
;

CALL: local dpuntos identificador p_abre VARIABLES p_cierra
;

CALL_PRIM: substring p_abre VARIABLES p_cierra
        | up_case p_abre VARIABLES p_cierra
        | low_case p_abre VARIABLES p_cierra
        | string p_abre VARIABLES p_cierra
        | number p_abre VARIABLES p_cierra
;

RANK: p_abre numero to numero p_cierra          { $$ = [Number($2),Number($4)] }
    | p_abre numero coma numero p_cierra        { $$ = [Number($2),Number($4)] }
;

VARIABLES: EXPRESION VARIABLES
        | coma EXPRESION VARIABLES
        |
;

FUNCTION: dec fun identificador dpuntos identificador p_abre VAR_FUNC p_cierra as PREFIX dpuntos TYPE quest l_abre XQUERY l_cierra pyc
;

VAR_FUNC: dollasign identificador as PREFIX dpuntos TYPE quest VAR_FUNC
        | coma dollasign identificador as PREFIX dpuntos TYPE quest VAR_FUNC
        |
;

PREFIX: xs                  { $$ = $1; }
        | fn                { $$ = $1; }
        | quest             { $$ = $1; }
;

TYPE: string                { $$ = $1; }
    | date                  { $$ = $1; }
    | dec                   { $$ = $1; }
    | integer               { $$ = $1; }
    | int                   { $$ = $1; }
    | long                  { $$ = $1; }
    | short                 { $$ = $1; }
    | boolean               { $$ = $1; }
    | double                { $$ = $1; }
    | float                 { $$ = $1; }
;

EXPRESION: EXPRESION mas EXPRESION          { $$ = new Operacion($1,$3,Operador.SUMA, @1.first_line, @1.first_column); }
        | EXPRESION menos EXPRESION         { $$ = new Operacion($1,$3,Operador.RESTA, @1.first_line, @1.first_column); }
        | EXPRESION por EXPRESION           { $$ = new Operacion($1,$3,Operador.MULTIPLICACION, @1.first_line, @1.first_column);}
        | EXPRESION div EXPRESION           { $$ = new Operacion($1,$3,Operador.DIVISION, @1.first_line, @1.first_column); }
        | EXPRESION mod EXPRESION           { $$ = new Operacion($1,$3,Operador.MODULO, @1.first_line, @1.first_column); }
        | T                         { $$ = $1; }
; 

T: T menorque T                 { $$ = new Operacion($1,$3,Operador.MENOR_QUE, @1.first_line, @1.first_column); }
    | T lt T                    { $$ = new Operacion($1,$3,Operador.MENOR_QUE, @1.first_line, @1.first_column); }
    | T menorigual T            { $$ = new Operacion($1,$3,Operador.MENOR_IGUA_QUE, @1.first_line, @1.first_column); }
    | T le T                    { $$ = new Operacion($1,$3,Operador.MENOR_IGUA_QUE, @1.first_line, @1.first_column); }
    | T mayorque T              { $$ = new Operacion($1,$3,Operador.MAYOR_QUE, @1.first_line, @1.first_column); }
    | T gt T                    { $$ = new Operacion($1,$3,Operador.MAYOR_QUE, @1.first_line, @1.first_column); }
    | T mayorigual T            { $$ = new Operacion($1,$3,Operador.MAYOR_IGUA_QUE, @1.first_line, @1.first_column); }
    | T ge T                    { $$ = new Operacion($1,$3,Operador.MAYOR_IGUA_QUE, @1.first_line, @1.first_column); }
    | T igual T                 { $$ = new Operacion($1,$3,Operador.IGUAL_QUE, @1.first_line, @1.first_column); }
    | T eq T                    { $$ = new Operacion($1,$3,Operador.IGUAL_QUE, @1.first_line, @1.first_column); }
    | T diferente T             { $$ = new Operacion($1,$3,Operador.DIFERENTE_QUE, @1.first_line, @1.first_column); }
    | T ne T                    { $$ = new Operacion($1,$3,Operador.DIFERENTE_QUE, @1.first_line, @1.first_column); }
    | T land T                  { $$ = new Operacion($1,$3,Operador.AND, @1.first_line, @1.first_column); }
    | T lor T                   { $$ = new Operacion($1,$3,Operador.OR, @1.first_line, @1.first_column); }    
    | F                         { $$ = $1; }
;
  
F: p_abre EXPRESION p_cierra           { $$ = $2; }
    | numero                           { $$ = new Primitivo(Number($1), @1.first_line, @1.first_column); }
    | identificador                    { $$ = new Primitivo($1, @1.first_line, @1.first_column); }
    | StringLiteral                    { $$ = new Primitivo($1, @1.first_line, @1.first_column); }
    //| dollasign PATH          { $$ = new Primitivo($2, @1.first_line, @1.first_column); }
;
