import { Simbolo } from "./Simbolo";

export class Entorno {
    private identificador: string;
    private anterior: Entorno;
    private tabla: Array<Simbolo>

    //recibe un entorno unicamente, el entorno anterior
    constructor(identificador: string, anterior: Entorno) {
        this.tabla = [];
        this.identificador = identificador;
        this.anterior = anterior;
    }
    //se agrega un simbolo a la tabla
    agregar(simbolo: Simbolo) {
        simbolo.identificador = simbolo.identificador.toLowerCase();
        this.tabla.push(simbolo);
    }

    getIdentificador() {
        return this.identificador;
    }

    //existe simbolo utilizable
    existe(id: string): boolean {
        id = id.toLowerCase();
        for (let ent: Entorno = this; ent != null; ent = ent.anterior) {
            ent.tabla.forEach(simbolo => {
                if (simbolo.identificador == id) return true;
            });
        }
        return false;
    }
    //existe simbolo en entorno actual
    existeEnActual(id: string): boolean {
        id = id.toLowerCase();
        let existe_id = false;

        this.tabla.forEach(simbolo => {
            if (simbolo.identificador == id) {
                existe_id = true;
            }
        });
        return existe_id;
    }

    getSimbolo(id: string): any {
        id = id.toLowerCase();
        let simbol_temp = null;

        for (let ent: Entorno = this; ent != null; ent = ent.anterior) {
            ent.tabla.forEach(simbolo => {
                if (simbolo.identificador == id) {
                    simbol_temp = simbolo;
                }
            });
        }
        return simbol_temp;
    }

    reemplazar(id: string, nuevoValor: Simbolo) {
        for (let i = 0; i < this.tabla.length; i++) {
            if (this.tabla[i].identificador == id) {
                this.tabla.splice(i, 1);
                this.agregar(nuevoValor);
                //this.tabla[i] = nuevoValor;
            }
        }
        
    }

}