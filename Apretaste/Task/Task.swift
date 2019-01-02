//
//  Task.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 13/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import ObjectMapper
import KeychainSwift

class requestFormatModel: Mappable{
    
    var appVersion = ""
    var command = ""
    var osVersion = ""
    var osType = "ios"
    var appType = "original"
    var method = ""
    var timestamp = 0
    var token = ""
    
    init(command:String, token: String){
        //TODO: parametrizar version
        // set attrs //
        self.appVersion = "3.1.2"
        self.command = command
        self.osVersion = UIDevice.current.systemVersion
        self.token = token
        self.method = ConnectionManager.shared.connectionType == .http ? "http" : "email"

        // get last command //
        
        let keychain = KeychainSwift()
        
        if let cacheData = keychain.get(KeychainKeys.CacheData.rawValue){
            
            guard let data = cacheRequestModel(JSONString: cacheData) else{
                return
            }
            
            // set timestamp //
            let date = UtilitesMethods.formatISOStringToDate(date: data.arrayRequest.last!.date)
            self.timestamp = Int(date.timeIntervalSince1970)
        }
            
    
        
    }
    
    required init?(map: Map) {
        
        // optional values //
          if map.JSON["timestamp"] == nil {
              return nil
          }
    }
    
    func mapping(map: Map) {
        
        appVersion <- map["appversion"]
        command <- map["command"]
        method <- map["method"]
        osVersion <- map["osversion"]
        timestamp <- map["timestamp"]
        token <- map["token"]
        osType <- map["ostype"]
      
    }
}



enum Command: String{
    
    case getProfile = "perfil status"
    

    private static func getJSON(command:String,token:String) -> String{
        
        let request = requestFormatModel(command: command, token: token)
        return request.toJSONString()!
        
    }
    
    static func generateCommand(command:String) ->String {
        
        var token = ""
        
        if ConnectionManager.shared.connectionType == .http{
            
            token = TEMPManager.shared.fetchData!.token
            // update http manager token
            HTTPManager.shared.token = token

        }
        
        if  ConnectionManager.shared.connectionType == .smtp{
            
            token = SMTPManager.shared.password
            let utf8str = token.data(using: String.Encoding.utf8)
            
            if let base64Encoded = utf8str?.base64EncodedString(options: .init(rawValue: 0)){
                token = base64Encoded
            }
        }
        
        return self.getJSON(command: command, token: token)
    }
    
    static func generateCommandWithToken(command:String,token:String) ->String{
        
        return self.getJSON(command: command, token: token)

    }
}
