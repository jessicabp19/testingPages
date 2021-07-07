"use strict";
exports.__esModule = true;
exports.Interprete = void 0;
var XQuery_1 = require("./XQuery");
var AST_1 = require("./AST/AST");
var Entorno_1 = require("./AST/Entorno");
var Interprete = /** @class */ (function () {
    function Interprete() {
        this.analizador = new AST_1.AST([], new Entorno_1.Entorno('', null));
    }
    Interprete.prototype.interpretar = function (entrada) {
        this.analizador = XQuery_1.parse(entrada);
        return this.analizador;
    };
    return Interprete;
}());
exports.Interprete = Interprete;
