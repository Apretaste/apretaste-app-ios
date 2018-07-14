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
    
    func request(withCaching cache: Bool = true , command: String,completion:@escaping(Error?,URL?  ) -> Void){
        
        if cache{
        
            let detectingCached = self.isCahed(command: command)
            
            if detectingCached != nil{
                completion(nil,detectingCached!)
                return
            }
                
        }
        
        let newCommand = Command.generateCommand(command: command)
        
        if connectionType == .http{
            
            self.refreshProfile { (_) in
                
                HTTPManager.shared.executeCommand(task: newCommand) { (error,html) in
                    completion(error,html)
                    
                    // save request//
                    if error == nil{
                        self.saveRequest(url: html!.absoluteString, command: command)
                    }
                    return
                }
                
            }
            
        }
        if connectionType == .smtp{
            
            self.refreshProfile { (_) in
                
                SMTPManager.shared.sendMail(task: command) { (subject) in
                    
                    //MARK: To do // validate subject //
                    
                    guard let subject = subject else{
                        
                        let error = ManagerError.badRequest
                        completion(error,nil)
                        return
                    }
                    
                    sleep(10)
                    // wait for receive mail //
                    
                    SMTPManager.shared.receiveCommandMail(subject: subject, completion: { (error,html) in
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
        
    }
    
    
    func refreshProfile(completion: @escaping(_ success:Bool) -> Void){
        
        if connectionType == .http{
        
            HTTPManager.shared.sendRequest(task: Command.getProfile.rawValue, completion: { (error, fetchData, urlFiles) in
                
                if error != nil{
                    completion(false)
                    return
                }
                // save data //
                TEMPManager.shared.fetchData = fetchData!
                TEMPManager.shared.relativePath = urlFiles!
                
                completion(true)
               
            })
        }
        
        if connectionType == .smtp{
            
            
            SMTPManager.shared.sendMail(task: Command.getProfile.rawValue) { (subject) in
                
                //MARK: To do // validate subject //
                
                guard let subject = subject else{
                    completion(false)
                    return
                }
                
                // wait for receive mail //
                sleep(10)
                
                SMTPManager.shared.receiveMail(subject: subject, completion: { (error, data, urlFiles) in
                    
                    if error != nil{
                        completion(false)
                        return
                    }
                    
                    // save data //
                    TEMPManager.shared.fetchData = data!
                    TEMPManager.shared.relativePath = urlFiles!
                    completion(true)
                    
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


