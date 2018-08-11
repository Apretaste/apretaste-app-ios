//
//  Task.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 13/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation


enum Command: String{
    
    case getProfile = "perfil status"
    

    private static func getJSON(command:String,token:String) -> String{
        
        let token = token
        let json = "{\"appversion\":\"3.0\",\"command\":\"\(command)\",\"osversion\":\"8.0.0\",\"timestamp\":\"\",\"token\":\"\(token)\"}"
        
        return json

    }
    
    static func generateCommand(command:String) ->String {
        
        return self.getJSON(command: command, token: TEMPManager.shared.fetchData!.token)
    }
    
    static func generateCommandWithToken(command:String,token:String) ->String{
        
        return self.getJSON(command: command, token: token)

    }
}
