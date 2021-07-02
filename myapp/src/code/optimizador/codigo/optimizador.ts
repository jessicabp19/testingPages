import { Instruccion } from '../codigo/instruccion'
import { parse } from '../test'

export class Optimizador {
   
   listaInstrucciones: Array<Instruccion>;
   reporteOptimizacion: Array<Optimizacion>;
   cadenaOptimizada: string;
   cadenaInicial: string;
   
   constructor(){
      this.cadenaOptimizada = '';
      this.cadenaInicial = '';
      this.listaInstrucciones = [];
      this.reporteOptimizacion = [];
   }

   public addInstruccion(instruccion: Instruccion): void{
      this.listaInstrucciones.push(instruccion);
   }

   public optimizar(codigo:string){
      
      // trayendo c3d del main
      this.cadenaOptimizada = 'simulando un optimizado';
      console.log('codigo -Z', codigo);
      //metiendo el c3d al parser
      this.listaInstrucciones = parse(codigo);
      console.log(this.listaInstrucciones);


      return this.cadenaOptimizada;
   }
   
}

export class Optimizacion {

   linea: number;
   regla: string;
   codigo: string;

   constructor(linea:number, regla:string, codigo:string){
      this.linea = linea;
      this.regla = regla;
      this.codigo = codigo;
   }


}