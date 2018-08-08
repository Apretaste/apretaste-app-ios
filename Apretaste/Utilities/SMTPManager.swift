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
    var mailBox = "horaciogermanico@gmail.com"
    var securityIMAP:security = .none
    
    
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
    func sendMail(task:String, completion: @escaping(String?) ->Void){
        
        
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
        
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "", mailbox: self.mailBox)]
        builder.header.from = MCOAddress(displayName: "", mailbox: self.email)
        builder.header.subject = subjectString
        
        let zip = UtilitesMethods.writeZip(task: task)
        
        let attach = MCOAttachment(contentsOfFile:zip.1)
        attach?.data = try! Data.init(contentsOf: zip.0)
        
        builder.addAttachment(attach)
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                
                completion(nil)
                return
                
                
            } else {
                NSLog("Successfully sent email!")
                completion(subjectString)
                
            }
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
                
                completion(error,[],"")
                return
                
            } else {
                
                // fetch emails
                
                for  mail  in mails! as! [MCOIMAPMessage]{
                    
                    if mail.header.subject == subject{
                        
                        // get attachment of mail
                        let folder : String = "INBOX"
                        let attachmentOperation = session.fetchMessageOperation(withFolder: folder, uid: mail.uid)
                        
                        
                        
                        attachmentOperation?.start({ (error, data) in
                            
                            if error != nil{
                                
                                completion(error,[],"")
                                return
                                
                            }else{
                                
                                let attachmentMail = MCOMessageParser(data: data)!
                                
                                for attachment in attachmentMail.attachments() as! [MCOAttachment]{
                                    
                                    
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
                                    
                                }
                            }
                        })
                        
                    }
                }
                
            }
        })
    }

    
    //MARK: -  VALIDAR TODOS LOS PUNTOS DONDE PUEDA CRASHEAR LA APP
    
    
    func receiveMail ( subject: String , completion: @escaping(Error?,FetchModel?,String?) -> Void){
        
        
        self.internalReceiveMail(subject: subject) { (error, folder, path) in
            
            if error != nil{
                completion(error,nil,"")
            }
            
            let jsonUrl = folder.filter({ (filePath) -> Bool in
                
                return filePath.absoluteString.contains("html")
                
            }).first!
            
            let jsonFile = try! String.init(contentsOf: jsonUrl)
            
            let response = FetchModel(JSONString: jsonFile)!
            
            completion(nil,response,path)
        }
    }
    
    func receiveCommandMail(subject: String , completion: @escaping(Error?,URL?) -> Void){
        
        self.internalReceiveMail(subject: subject) { (error, folder, path) in
            
            if error != nil{
                completion(error,nil)
            }
            
            let urlHTML = folder.filter({ (filePath) -> Bool in
                
                return filePath.absoluteString.contains("html")
                
            }).first!
            
            completion(nil, urlHTML)
            
        }
    }
 
}



