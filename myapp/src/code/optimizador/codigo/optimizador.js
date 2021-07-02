"use strict";
exports.__esModule = true;
exports.Optimizacion = exports.Optimizador = void 0;
var test_1 = require("../test");
var Optimizador = /** @class */ (function () {
    function Optimizador() {
        this.cadenaOptimizada = '';
        this.cadenaInicial = '';
        this.listaInstrucciones = [];
        this.reporteOptimizacion = [];
    }
    Optimizador.prototype.addInstruccion = function (instruccion) {
        this.listaInstrucciones.push(instruccion);
    };
    Optimizador.prototype.optimizar = function (codigo) {
        // trayendo c3d del main
        this.cadenaOptimizada = 'simulando un optimizado';
        console.log('codigo -Z', codigo);
        //metiendo el c3d al parser
        this.listaInstrucciones = test_1.parse(codigo);
        console.log(this.listaInstrucciones);
        return this.cadenaOptimizada;
    };
    return Optimizador;
}());
exports.Optimizador = Optimizador;
var Optimizacion = /** @class */ (function () {
    function Optimizacion(linea, regla, codigo) {
        this.linea = linea;
        this.regla = regla;
        this.codigo = codigo;
    }
    return Optimizacion;
}());
exports.Optimizacion = Optimizacion;
