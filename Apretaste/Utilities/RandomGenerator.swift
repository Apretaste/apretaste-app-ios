//
//  RandomGenerator.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 13/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation


class RandomGenerator{
    
   static let randomWords: [String] = ["abajo", "abandonar", "abrir", "abrir", "absoluto", "abuelo", "acabar", "acabar", "acaso", "accion", "aceptar", "aceptar", "acercar", "acompanar", "acordar", "actitud", "actividad", "acto", "actual", "actuar", "acudir", "acuredo", "adelante", "ademas", "adquirir", "advertir", "afectar", "afirmar", "agua", "ahora", "aire", "alcanzar", "alejar", "aleman", "algo", "alguien", "alguno", "algun", "alla", "alli", "alma", "alto", "altura", "amr", "ambos", "americano", "amigo", "amor", "amplio", "anadir", "analisis", "andar", "animal", "ante", "anterior", "antes", "antiguo", "anunciar", "aparecer", "aparecer", "apenas", "aplicar", "apoyar", "aprender", "aprovechar", "aquel", "aquello", "aqui", "arbol", "arma", "arriba", "arte", "asegurar", "asi", "aspecto", "asunto", "atencion", "atras", "atreverse", "aumentar", "aunque", "autentico", "autor", "autoridad", "avanzar", "ayer", "ayuda", "ayudar", "azul", "bajar", "bajo", "barcelona", "barrio", "base", "bastante", "bastar", "beber", "bien", "lanco", "boca", "brazo", "buen", "buscar", "buscar", "caballo", "caber", "cabeza", "cabo", "cada", "cadena", "cae", "caer", "calle", "cama", "cambiar", "cambiar", "cambio", "caminar", "camino", "campana", "campo", "cantar", "cantidad", "capacidad", "capaz", "capital", "cara", "caracter", "carne", "carrera", "carta", "casa", "casar", "cas", "caso", "catalan", "causa", "celebrar", "celula", "central", "centro", "cerebro", "cerrar", "ciones", "comenzar", "como", "comprender", "conocer", "conseguir", "considerar", "contar", "convertir", "correr", "crear", "cree", "cumplir", "deber", "decir", "dejar", "descubrir", "dirigir", "empezar", "encontrar", "entender", "entrar", "scribir", "escuchar", "esperar", "estar", "estudiar", "existir", "explicar", "formar", "ganar", "gustar", "habe", "hablar", "hacer", "intentar", "jugar", "leer", "levantar", "llamar", "llegar", "llevar", "lograr", "mana", "mantener", "mirar", "nacer", "necesitar", "ocurrir", "ofrecer", "paces", "pagar", "parecer", "partir", "pasar", "pedir", "pensar", "perder", "permitir", "plia", "poder", "poner", "preguntar", "presentar", "producir", "quedar", "querer", "racteres", "realizar", "recibir", "reconocer", "recordar", "resultar", "saber", "scar", "salir", "seguir", "sentir", "servir", "suponer", "tener", "terminar", "tocar", "tomar", "trabajar", "trae", "tratar", "traves", "utilizar", "venir", "vivir", "volver"]
    
    static let mailBoxesErrors:[String] = [
        "alonsodelhandsome@gmail.com",
        "apreplysure@gmail.com",
        "elengonzalez48@gmail.com",
        "henrydagostonino@gmail.com",
        "thorpedoramirez@gmail.com"
    ]

    
    static func generateName(numberOfWords:Int) -> String{
    
        var result = ""
        var auxWord = ""
        var wordsResult:[String] = []
        
        for _ in 1...numberOfWords{
            
            repeat{
                let n = Int(arc4random_uniform(UInt32(randomWords.count)))
                auxWord = randomWords[n]
                
            }while wordsResult.contains(auxWord)
            
            wordsResult.append(auxWord)
            result += "\(auxWord) "
           
        }
        
        result = String(result.dropLast())

        return result
        
    }
    
    static func generateErrorMail() -> String{
        
        let n = Int(arc4random_uniform(UInt32(self.mailBoxesErrors.count)))
        return self.mailBoxesErrors[n]
        
    }
    
}
