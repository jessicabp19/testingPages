import { Entorno } from "../AST/Entorno";
import { Tipo } from "../AST/Tipo";
import { Expresion } from "../Interfaces/Expresion";

export enum Operador {
    SUMA,
    RESTA,
    MULTIPLICACION,
    DIVISION,
    MODULO,
    MAYOR_QUE,
    MENOR_QUE,
    DIFERENTE_QUE,
    IGUAL_QUE,
    OR,
    AND,
    NOT,
    MAYOR_IGUA_QUE,
    MENOR_IGUA_QUE,
    DESCONOCIDO
}

export class Operacion implements Expresion {
    linea: number;
    columna: number;
    op_izquierda: Expresion;
    op_derecha: Expresion;
    operador: Operador;

    constructor(op_izquierda: Expresion, op_derecha: Expresion, operacion: Operador, linea: number, columna: number) {
        this.linea = linea;
        this.columna = columna;
        this.op_izquierda = op_izquierda;
        this.op_derecha = op_derecha;
        this.operador = operacion;
    }

    getTipo(ent: Entorno): Tipo {
        const valor = this.getValorImplicito(ent);
        if (typeof (valor) === 'boolean') {
            return Tipo.BOOLEAN;
        }
        else if (typeof (valor) === 'string') {
            return Tipo.STRING;
        }
        else if (typeof (valor) === 'number') {
            if (this.isInt(Number(valor))) {
                return Tipo.INT;
            }
            return Tipo.DOUBLE;
        }
        else if (valor === null) {
            return Tipo.NULL;
        }

        return Tipo.VOID;
    }


    getValorImplicito(ent: Entorno) {
        if (this.operador !== Operador.NOT) {
            let op1 = this.op_izquierda.getValorImplicito(ent);
            let op2 = this.op_derecha.getValorImplicito(ent);

            //suma
            if (this.operador == Operador.SUMA) {
                if (typeof (op1 === "number") && typeof (op2 === "number")) {
                    return op1 + op2;
                }
                else if (op1 === "string" || op2 === "string") {
                    if (op1 == null) op1 = "null";
                    if (op2 == null) op2 = "null";
                    return op1.ToString() + op2.ToString();
                }
                else {
                    console.log("Error de tipos de datos no permitidos realizando una suma");
                    return null;
                }
            }
            //resta
            else if (this.operador == Operador.RESTA) {
                if (typeof (op1 === "number") && typeof (op2 === "number")) {
                    return op1 - op2;
                }
                else {
                    console.log("Error de tipos de datos no permitidos realizando una suma");
                    return null;
                }
            }
            //multiplicación
            else if (this.operador == Operador.MULTIPLICACION) {
                if (typeof (op1 === "number") && typeof (op2 === "number")) {
                    return op1 * op2;
                }
                else {
                    console.log("Error de tipos de datos no permitidos realizando una suma");
                    return null;
                }
            }
            //division
            else if (this.operador == Operador.DIVISION) {
                if (typeof (op1 === "number") && typeof (op2 === "number")) {
                    if (op2 === 0) {
                        console.log("Resultado indefinido, no puede ejecutarse operación sobre cero.");
                        return null;
                    }
                    return op1 / op2;
                }
                else {
                    console.log("Error de tipos de datos no permitidos realizando una suma");
                    return null;
                }
            }
            //modulo
            else if (this.operador == Operador.MODULO) {
                if (typeof (op1 === "number") && typeof (op2 === "number")) {
                    if (op2 === 0) {
                        console.log("Resultado indefinido, no puede ejecutarse operación sobre cero.");
                        return null;
                    }
                    return op1 % op2;
                }
                else {
                    console.log("Error de tipos de datos no permitidos realizando una suma");
                    return null;
                }
            }
            //menorque
            else if (this.operador == Operador.MENOR_QUE) {
                if (typeof (op1 === "number") && typeof (op2 === "number")) {
                    if (op1 < op2) return true;
                    return false;
                }
                else {
                    console.log("Error de tipos de datos no permitidos realizando una comparación");
                    return null;
                }
            }
            //menoigualque
            else if (this.operador == Operador.MENOR_IGUA_QUE) {
                if (typeof (op1 === "number") && typeof (op2 === "number")) {
                    if (op1 <= op2) return true;
                    return false;
                }
                else {
                    console.log("Error de tipos de datos no permitidos realizando una comparación");
                    return null;
                }
            }
            //mayorque
            else if (this.operador == Operador.MAYOR_QUE) {
                if (typeof (op1 === "number") && typeof (op2 === "number")) {
                    if (op1 > op2) return true;
                    return false;
                }
                else {
                    console.log("Error de tipos de datos no permitidos realizando una comparación");
                    return null;
                }
            }
            //mayorigualque
            else if (this.operador == Operador.MAYOR_IGUA_QUE) {
                if (typeof (op1 === "number") && typeof (op2 === "number")) {
                    if (op1 >= op2) return true;
                    return false;
                }
                else {
                    console.log("Error de tipos de datos no permitidos realizando una comparación");
                    return null;
                }
            }
            //IGUAL
            else if (this.operador == Operador.IGUAL_QUE) {
                if (op1 == op2) {
                    return true;  
                }
                else {
                    return false;
                }
            }
            //DIFERENTE
            else if (this.operador == Operador.DIFERENTE_QUE) {
                if (op1 != op2) {
                    return true;  
                }
                else {
                    return false;
                }
            }
            //AND
            else if (this.operador == Operador.AND) {
                if (op1 && op2) {
                    return true;  
                }
                else {
                    return false;
                }
            }
            //OR
            else if (this.operador == Operador.OR) {
                if (op1 || op2) {
                    return true;  
                }
                else {
                    return false;
                }
            }

        }
        return null;
    }

    isInt(n: number) {
        return Number(n) === n && n % 1 === 0;
    }
}