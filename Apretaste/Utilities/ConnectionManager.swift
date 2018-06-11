//
//  ConnectionManager.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 10/6/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import UIKit

enum ConnectionType: String{
    
    case smtp = "SMTP"
    case http = "HTTP"
    
}


class ConnectionManager{
    
    static var shared = ConnectionManager()
    
    var connectionType: ConnectionType = .http

    private init(){}
    
    //Methods //
    
    func request(command: String,completion:@escaping(Error?,URL) -> Void){
        
        if connectionType == .http{
            
            
            HTTPManager.shared.executeCommand(task: command) { (error,html) in
                
                completion(error,html)
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
                    return
                })
            }

        }
        
    }
    
}


