import { parse } from './XQuery'
import { AST } from './AST/AST'
import { Entorno } from './AST/Entorno'

export class Interprete {

    analizador: AST;
   constructor() {

    this.analizador = new AST([], new Entorno('', null));
   }

interpretar(entrada:string):any{
    
    this.analizador = parse(entrada);
    return this.analizador;

}

}

