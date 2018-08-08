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

    static func generateCommand(command:String) ->String {
        
       let token = TEMPManager.shared.fetchData.token
       let json = "{\"appversion\":\"3.0\",\"command\":\"\(command)\",\"osversion\":\"8.0.0\",\"timestamp\":\"\",\"token\":\"\(token)\"}"
        
        return json
        
    }
}
