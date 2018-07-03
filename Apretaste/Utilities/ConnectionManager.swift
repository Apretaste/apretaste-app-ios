//
//  ConnectionManager.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 10/6/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift

enum ConnectionType: String{
    
    case smtp = "SMTP"
    case http = "HTTP"
    
}


class ConnectionManager{
    
    static var shared = ConnectionManager()
    
    var connectionType: ConnectionType = .http

    private init(){}
    
    //Methods //
    
    func requestAwait(command: String,completion:@escaping(_ success:Bool) -> Void){
        
        if connectionType == .http{
            
            HTTPManager.shared.executeCommandAwait(task: command) { (success) in
                completion(success)
                return
            }
        }
        if connectionType == .smtp{
            
            SMTPManager.shared.sendMail(task: command) { (_) in
                
                completion(true)
                return
            }
            
        }
        
    }
    
    func request(command: String,completion:@escaping(Error?,URL) -> Void){
        
        let detectingCached = self.isCahed(command: command)
        
        if detectingCached != nil{
            completion(nil,detectingCached!)
            return
        }
        
        let newCommand = Command.generateCommand(command: command)
        
        if connectionType == .http{
            
            HTTPManager.shared.executeCommand(task: newCommand) { (error,html) in
                completion(error,html)
                // save request//
                if error == nil{
                    self.saveRequest(url: html.absoluteString, command: command)
                }
                return
            }
        }
        if connectionType == .smtp{

            SMTPManager.shared.sendMail(task: command) { (subject) in

                //MARK: To do // validate subject //

                // wait for receive mail //
                sleep(10)

                SMTPManager.shared.receiveCommandMail(subject: subject!, completion: { (error,html) in
                    completion(error,html!)
                    // save request //
                    if error == nil{
                        self.saveRequest(url: html!.absoluteString, command: command)
                    }
                    return
                })
            }

        }
        
    }
    
    
    private func saveRequest(url:String,command:String){
        
        let keychain = KeychainSwift()
        
        // save existing cache ///
        if let cacheData = keychain.get(KeychainKeys.CacheData.rawValue){
            
            guard let data = cacheRequestModel(JSONString: cacheData) else{
                return
            }
            
            let newRequest = requestModel(command: command, url: url,date:Date())
            data.arrayRequest.append(newRequest)
            keychain.set(data.toJSONString()!, forKey: KeychainKeys.CacheData.rawValue)
            return
        }
        
        // create new cache data //
        let cacheData = cacheRequestModel()
        let newRequest = requestModel(command: command, url: url,date:Date())
        cacheData.arrayRequest.append(newRequest)
        keychain.set(cacheData.toJSONString()!, forKey: KeychainKeys.CacheData.rawValue)
        
    }
    
    private func isCahed(command:String) -> URL?{
        
        let keychain = KeychainSwift()
        if let cacheData = keychain.get(KeychainKeys.CacheData.rawValue){
            
            guard let data = cacheRequestModel(JSONString: cacheData) else{
                return nil
            }
            
            let cacheRequest = data.arrayRequest.filter { (request) -> Bool in
                return request.command == command
            }.last
            
            if cacheRequest == nil{
                return nil
            }
            
            return cacheRequest!.url
        
        }
        
        return nil
    }
    
}


