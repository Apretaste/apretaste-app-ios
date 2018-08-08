//
//  HTTPManager.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 12/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import Alamofire
import KeychainSwift

enum ManagerError: Error {
    case badRequest
    case badSmtpConfig
}

class HTTPManager{
    
    var email = ""
    var domains: [String] = ["http://cubaworld.info","http://cubazone.info","http://cubanow.xyz"]
    
    var requestDomain: String = "cubazone.info"{
        didSet{
            self.saveNewDomain()
        }
    }
    var token = ""
    
    static var shared: HTTPManager = HTTPManager()
    
    private init(){
        
         let keychain = KeychainSwift()
         if let requestDomain = keychain.get(KeychainKeys.httpConfig.rawValue){
            self.requestDomain = requestDomain
        }
    }
    
    /** Si la conexion es exitosa retorna true
     
        Si la conexion es fallida retorna false
     
     */
    
    //MARK: - funcs
    
    func saveNewDomain(){
        
        let keychain = KeychainSwift()
        keychain.set(self.requestDomain, forKey: KeychainKeys.httpConfig.rawValue)
        
    }
    
    func connect(completion: @escaping(Bool) -> Void){
        
        let n = Int(arc4random_uniform(UInt32(domains.count)))
        let domain = domains[n]
        
        let urlDomain = URL(string: "\(domain)/api/start?email=\(email)")!
        
        Alamofire.request(urlDomain, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            guard let responseJSON = response.result.value as? NSDictionary else {
                completion(false)
                return
                
            }

            let code = responseJSON["code"] as! String
            
            if code == "ok"{
                
                completion(true)
                
            }else{
                
                completion(false)
            }
        }
    }
    
    func validateMail(pin:String, completion: @escaping(String,Bool) -> Void){
        
        let n = Int(arc4random_uniform(UInt32(domains.count)))
        let domain = domains[n]
        
        let urlDomain = URL(string: "\(domain)/api/auth?email=\(email)&pin=\(pin)&appname=apretaste&platform=ios")!

        Alamofire.request(urlDomain, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            guard let responseJSON = response.result.value as? NSDictionary else {return}
            
            let code = responseJSON["code"] as! String
            
            if code == "ok"{
                
                 let token = responseJSON["token"] as! String
                self.token = token
                completion(token,true)
                
            }else{
                
                let error = responseJSON["message"] as! String
                completion(error,false)
            }
        }
    }
    
    private func internalRequest(zip:(URL,String), task: String,completion:@escaping(_ data:Data?,_ url: String?,_ await:Bool) -> Void){
        
        
        guard let domainUrl = URL(string: "http://\(self.requestDomain)/run/app") else{
            completion(nil,nil,false)
            return
        }
        
        let url = try! URLRequest(url: domainUrl, method: .post)
        
        Alamofire.upload(multipartFormData: { (multipart) in
            
            multipart.append(zip.0, withName:"attachments")
            multipart.append(self.token.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "token")
            
            
        }, with: url, encodingCompletion: { (response) in
            
            switch response {
            case .success(let upload,_,_):
                
                upload.uploadProgress(closure: { (progress) in
                    print(progress)
                })
                
                upload.responseJSON(completionHandler: { (data) in
                    
                    guard let responseJSON = data.result.value as? NSDictionary else {
                        
                        // no internet connection //
                        completion(nil,nil,false)
                        return
                        
                    }
                    
                    let urlString = responseJSON["file"] as! String
                    guard let urlFile = URL(string:urlString) else{
                        completion(Data(),"",true)
                        return
                    }
                    let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
                    
                    
                    Alamofire.download(
                        urlFile,
                        method: .get,
                        parameters: nil,
                        encoding: JSONEncoding.default,
                        headers: nil,
                        
                        to: destination).downloadProgress(closure: { (progress) in
                            print("progress download: \(progress)")
                            
                        }).response(completionHandler: { (response) in
                            
                            do{
                               
                                let zipData = try Data.init(contentsOf: response.destinationURL!)
                                let name = String(urlString.split(separator: "/").last!)
                                completion(zipData,name,false)
                          
                            }catch{
                                
                                completion(nil,nil,false)
                                return
                            }

                        })
                    
                })
                
            case .failure(let encodingError):
                completion(nil,nil,false)
                print(encodingError)
            }
            
        })
    }
    
    
    func executeCommand(zip:(URL,String),task: String,completion:@escaping(Error?,URL?) -> Void){
        
        
        self.internalRequest(zip: zip, task: task) { (zipData, name, _)  in
            
            guard let zipData = zipData else{
                
                let error = ManagerError.badRequest
                completion(error,nil)
                return
            }
            
            guard let name = name else{
                let error = ManagerError.badRequest
                completion(error,nil)
                return
            }
           
            let unzipFolder = UtilitesMethods.receiveZip(data: zipData, filename: name)
            
            guard let urlHTML = unzipFolder.0.filter({ (filePath) -> Bool in
                
                return filePath.absoluteString.contains("html")
                
            }).first else{
                
                let error = ManagerError.badRequest
                completion(error,nil)
                return
            }
            
            
            completion(nil, urlHTML)
        }
    }
    
    
    func executeCommandAwait(zip:(URL,String),task: String,completion:@escaping(Bool) -> Void){
        
        self.internalRequest(zip: zip, task: task) { (_, _,await) in
            
           completion(await)
        }
    }
    
    
    func sendRequest(zip:(URL,String),task: String,completion:@escaping(Error?,FetchModel?,String?) -> Void){
        
        self.internalRequest(zip: zip, task: task) { (zipData, name,_) in
            
            guard let zipData = zipData else{
                let error = ManagerError.badRequest
                completion(error,nil,nil)
                return
            }
            
            guard let name = name else{
                
                let error = ManagerError.badRequest
                completion(error,nil,nil)
                return
            }
            
            let unzipFolder = UtilitesMethods.receiveZip(data: zipData, filename: name)
            
            let folder = unzipFolder.0
            let path = unzipFolder.1
            
            guard let jsonUrl = folder.filter({ (filePath) -> Bool in
                return filePath.absoluteString.contains("html")
           }).first else{
                let error = ManagerError.badRequest
                completion(error,nil,nil)
                return
            }
            
            let jsonFile = try! String.init(contentsOf: jsonUrl)
            
            let response = FetchModel(JSONString: jsonFile)!
            
            completion(nil, response,path)
        }
    
    }
}
