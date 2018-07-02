//
//  TEMPManager.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 20/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import KeychainSwift

class TEMPManager{
    
    var fetchData: FetchModel!{
       
        didSet{
            
          TEMPManager.keychainAccess.set(fetchData.toJSONString()!, forKey: KeychainKeys.UserKeys.rawValue)
        }
    }
    
    var relativePath: String = ""{
        
        didSet{
            
             let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            
            let url = NSURL(fileURLWithPath: path).appendingPathComponent(relativePath)!
            
            // save relativePath //
            
            TEMPManager.keychainAccess.set(relativePath, forKey: KeychainKeys.UserFile.rawValue)
            self.urlFiles = url
        }
    }
    
    var urlFiles: URL!
    
    var isAlive = false
    
    static var shared = TEMPManager()
    static var keychainAccess = KeychainSwift()
    
    
    func saveOpenServices(){
        
        TEMPManager.keychainAccess.set(fetchData.toJSONString()!, forKey: KeychainKeys.UserKeys.rawValue)
    }
    
    
    func automaticConfig(){
        
        // se accede al keychain //
        
        if let fetchData = TEMPManager.keychainAccess.get(KeychainKeys.UserKeys.rawValue){
            
            // se guarda la data local //
            
            self.fetchData = FetchModel(JSONString: fetchData)!
            
            // se guarda la url de los media files //
            
            if let relativePath = TEMPManager.keychainAccess.get(KeychainKeys.UserFile.rawValue){
                
                self.relativePath = relativePath
                
                // se asigna session activa //
                // set token //
                HTTPManager.shared.token = self.fetchData.token
                self.isAlive = true
            }
        }
    }
    
    func clearData(){
        TEMPManager.keychainAccess.clear()
    }
    
    
    private init(){}
}
