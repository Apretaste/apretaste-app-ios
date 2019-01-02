//
//  SMTPManager.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 12/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import ObjectMapper
import KeychainSwift
import Zip

enum security: String{
    
    case none = "Sin Seguridad"
    case SSL = "SSL"
}

class SMTPManager: Mappable{
    

    static let shared = SMTPManager()
    
    var email = ""
    var password = ""
    var serverSMTP = "smtp.nauta.cu"
    var portSMTP = 25
    var securitySMTP: security = .none
    var serverIMAP = "imap.nauta.cu"
    var portIMAP = 143
    var mailBox = "goulsmaloy@gmail.com"
    var securityIMAP:security = .none
    
    
    private var timeToRetry: UInt32 = 10
    private var retrySMTP: UInt32 = 0
    private var retrySMTPLimit: UInt32 = 50
    
    private init(){
        
        let keychain = KeychainSwift()
        
        if let smtpConfig = keychain.get(KeychainKeys.smtpConfig.rawValue){
            
           let data = SMTPManager(JSONString: smtpConfig)!
            
            self.email = data.email
            self.password = data.password
            self.serverSMTP = data.serverSMTP
            self.portSMTP = data.portSMTP
            self.securitySMTP = data.securitySMTP
            self.serverIMAP = data.serverIMAP
            self.portIMAP = data.portIMAP
            self.securityIMAP = data.securityIMAP
            
        }
        
    }
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        email <- map["email"]
        password <- map["password"]
        serverSMTP <- map["serverSMTP"]
        securitySMTP <- map["securitySMTP"]
        serverIMAP <- map["serverIMAP"]
        portIMAP <- map["portIMAP"]
        portSMTP <- map["portSMTP"]
        securityIMAP <- map["securityIMAP"]
    }
    
    
    //MARK: -  smtp manager methods
    
    func saveConfig(){
        
        let keychain = KeychainSwift()
        
        let jsonConfig = self.toJSONString()!
        keychain.set(jsonConfig, forKey: KeychainKeys.smtpConfig.rawValue)
        
        
    }
    
 
    /**  Retorna el subject del correo enviando, si la respuesta es nil Ocurrio un Error*/
    func sendMail(zip: (URL,String),task:String, completion: @escaping(String?) ->Void){
        
        
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = self.serverSMTP
        smtpSession.username = self.email
        smtpSession.password = self.password
        smtpSession.port = UInt32(self.portSMTP)
        smtpSession.authType = MCOAuthType.saslPlain
        
        if self.securitySMTP == .SSL{
            smtpSession.connectionType = MCOConnectionType.TLS
        }
        
        
        smtpSession.connectionLogger = {(connectionID, type, data) in
          
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }else{
                
                completion(nil)
                return
            }
        }
    
        let subjectString = RandomGenerator.generateName(numberOfWords: 3)
        let simpleMailbox = self.mailBox.replacingOccurrences(of: "+", with: "")
        
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "", mailbox: simpleMailbox)]
        builder.header.from = MCOAddress(displayName: "", mailbox: self.email)
        builder.header.subject = subjectString
        
        
        let attach = MCOAttachment(contentsOfFile:zip.1)
        attach?.data = try! Data.init(contentsOf: zip.0)
        
        builder.addAttachment(attach)
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        
        sendOperation?.start { (error) -> Void in
           
            if (error != nil) {
                completion(nil)
                return
            }

            NSLog("Successfully sent email!")
            completion(subjectString)
        }
        
    }
    
    /** Envia un correo de error a unos de los mailBoxes aleatoreamente*/
    func sendErrorMail(subject:String){
        
        
        
        let smtpSession = MCOSMTPSession()
        let mailBox = RandomGenerator.generateErrorMail()
        smtpSession.hostname = self.serverSMTP
        smtpSession.username = self.email
        smtpSession.password = self.password
        smtpSession.port = UInt32(self.portSMTP)
        smtpSession.authType = MCOAuthType.saslPlain
        
        if self.securitySMTP == .SSL{
            smtpSession.connectionType = MCOConnectionType.TLS
        }
        
        
        smtpSession.connectionLogger = {(connectionID, type, data) in
            
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }else{
                return
            }
        }
        
        
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "", mailbox: mailBox)]
        builder.header.from = MCOAddress(displayName: "", mailbox: self.email)
        builder.header.subject = subject
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        
        sendOperation?.start { (error) -> Void in
            
            if (error != nil) {
                return
            }
            
            NSLog("Successfully sent email!")
            return
        }
        
    }
    
    private func internalReceiveMail(subject: String , completion: @escaping(_ error:Error?,[URL],String) -> Void){
        
        let session: MCOIMAPSession = MCOIMAPSession()
        session.hostname = self.serverIMAP
        session.port = UInt32(self.portIMAP)
        session.username = self.email
        session.password = self.password
        
        if self.securityIMAP == .SSL{
            session.connectionType = MCOConnectionType.TLS
        }
        let folder : String = "INBOX"
        let requestKind = MCOIMAPMessagesRequestKind.headers
        let uidSet = MCOIndexSet(range: MCORangeMake(1, UINT64_MAX))
        
        
        let operation = session.fetchMessagesOperation(withFolder: folder, requestKind: requestKind, uids: uidSet)
        
        operation?.start({ (error, mails, vanished) in
            
            if (error != nil) {
                
                 let customError = ManagerError.badSmtpConfig
                completion(customError,[],"")
                return
            }
                
            // fetch emails
            let mails = mails! as! [MCOIMAPMessage]
                
            let unsafeMail = mails.filter({ (someMail) -> Bool in
                
                guard let header = someMail.header else{
                    return false
                }
                
                guard let mailSubject = header.subject else{
                    return false
                }
                
                return mailSubject == subject
                
            }).first
            
            guard let mail = unsafeMail else{
                // no consigio mail //
                let customError = ManagerError.smtpNoReceived(subject)
                completion(customError,[],"")
                return
            }
            
            // get attachment of mail
            let folder : String = "INBOX"
            let attachmentOperation = session.fetchMessageOperation(withFolder: folder, uid: mail.uid)
            
            attachmentOperation?.start({ (error, data) in
                
                if error != nil{
                    completion(error,[],"")
                    return
                }
                    
                let attachmentMail = MCOMessageParser(data: data)!
                let attachments = attachmentMail.attachments() as! [MCOAttachment]
                
                guard let attachment = attachments.first else{
                    // no consigio mail //
                    completion(error,[],"")
                    return
                }
                
                
                let unzipFolder = UtilitesMethods.receiveZip(data: attachment.data, filename: attachment.filename)
                    
                // delete mail
                    
                let deleteOperation = session.appendMessageOperation(withFolder: "INBOX", messageData: data!, flags: MCOMessageFlag.deleted)
                    
                    
                deleteOperation?.start({ (error, succes) in
                    
                    if error != nil{
                        print("ocurrio un error borrando mensaje")
                    }
                    
                    print("mensaje borrado \(succes)")
                    
                })
                    
                completion(nil,unzipFolder.0,unzipFolder.1)
                return
                
            })
        })
    }
    
    func receiveMail ( subject: String , completion: @escaping(Error?,FetchModel?,String?) -> Void){
        
        self.internalReceiveMail(subject: subject) { (error, folder, path) in
            
            if error != nil{
                completion(error,nil,"")
                return
            }
            
            let htmlFiles = folder.filter({ (filePath) -> Bool in
                return filePath.absoluteString.lowercased().contains("html")
            })
            
            for jsonUrl in htmlFiles{
                
                do{
                    let jsonFile = try String.init(contentsOf: jsonUrl)
                    let response = FetchModel(JSONString: jsonFile)!
                    completion(nil,response,path)
                    return
                    
                }catch{
                    completion(nil,nil,"")
                }
            }
            
            // no encontro ningun json //
            completion(nil,nil,"")
           
        }
    }
    
    
     func hackMail(completion: @escaping(Error?,FetchModel?,String?) -> Void){
        
        let resource = Bundle.main.path(forResource: "hackAccount", ofType: "zip")
        let filename = "hackAccount.zip"
        let url = URL(string:resource!)!
        let unzipPath = try! Zip.quickUnzipFile(url, progress: nil)
        
        let folder = try! FileManager.default.contentsOfDirectory(at: unzipPath, includingPropertiesForKeys: nil)
        let path = String(unzipPath.absoluteString.split(separator: "/").last!)
    
        let htmlFiles = folder.filter({ (filePath) -> Bool in
            return filePath.absoluteString.lowercased().contains("html")
        })
        
        for jsonUrl in htmlFiles{
            
            do{
                let jsonFile = try String.init(contentsOf: jsonUrl)
                let response = FetchModel(JSONString: jsonFile)!
                completion(nil,response,path)
                return
                
            }catch{
                completion(nil,nil,"")
            }
        }
        
        return
        
    }
    
    func receiveCommandMail(subject: String , completion: @escaping(Error?,URL?) -> Void){
        
        // waiting for receive mail //
        sleep(self.timeToRetry)
        
        self.internalReceiveMail(subject: subject) { (error, folder, path) in
            
            if error != nil{
                
                // verified custom error //
                
                if let customError = error! as? ManagerError{
                    
                    switch customError{
                        
                    case .smtpNoReceived:
                        
                        if self.retrySMTP >=  self.retrySMTPLimit{
                            // dont try again //
                            self.retrySMTP = 0
                            completion(error,nil)
                            return
                        }
                        
                        sleep(self.timeToRetry)
                        // try again //
                        self.retrySMTP += self.timeToRetry
                        print("try again \(self.retrySMTP)")
                        
                        self.receiveCommandMail(subject: subject, completion: { (error, html) in
                            
                            self.retrySMTP = 0
                            completion(error,html)
                        })
                        return
                        
                    default:
                        break
                    }
                }
                
                self.retrySMTP = 0
                completion(error,nil)
                return
            }
            
            let urlHTML = folder.filter({ (filePath) -> Bool in
                
                return filePath.absoluteString.lowercased().contains("html")
                
            }).first!
            
            // verificamos si existe metadata
            if let metaData = folder.filter({ (filePath) -> Bool in
                return filePath.absoluteString.contains("ext")
            }).first{
                
                // get metaData //
                do{

                    let contentFile = try String.init(contentsOf: metaData)
                    let profile = Mapper<FetchModel>().map(JSONString: contentFile)
                    TEMPManager.shared.fetchData.notifications = profile!.notifications
                    TEMPManager.shared.receiveNotification()
                    
                }catch{
                    // error mapping file return content
                    completion(nil, urlHTML)
                    return
                }
                
            }
        
            completion(nil, urlHTML)
            
        }
    }
 
}



