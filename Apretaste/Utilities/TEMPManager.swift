//
//  TEMPManager.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 20/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import KeychainSwift
import ObjectMapper

class MetadataNotification : NSObject {
    
    @objc dynamic var notificationsCount = 0
    @objc dynamic var notificationTapped = false

}

class TEMPManager{
    
    var metaNotification = MetadataNotification()
    
    var notifications: [NotificationModel] = []
    
    var visitedServices:[ServicesModel] = []
    
    var isSubscribed = false
    
    var fetchData: FetchModel!{
       
        didSet{
            
          TEMPManager.keychainAccess.set(fetchData.toJSONString()!, forKey: KeychainKeys.UserKeys.rawValue)
          SMTPManager.shared.mailBox = fetchData.mailbox
            
            if !self.fetchData.notifications.isEmpty{
                self.receiveNotification()
            }
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
    
    //MARK: - funcs

    
    func saveVisitedServices(){
        
        TEMPManager.keychainAccess.set(visitedServices.toJSONString()!, forKey: KeychainKeys.visitedServices.rawValue)
    }
    
    func saveNotifications(){
        
        TEMPManager.keychainAccess.set(notifications.toJSONString()!, forKey: KeychainKeys.notifications.rawValue)
    }
    
    func saveSuscriptionMail(isSubscribed: Bool){
        
        self.isSubscribed = isSubscribed
        TEMPManager.keychainAccess.set(isSubscribed, forKey: KeychainKeys.subscribedKey.rawValue)
    }
    
    func saveTempData(){
        
        TEMPManager.keychainAccess.set(fetchData.toJSONString()!, forKey: KeychainKeys.UserKeys.rawValue)
    }
    
    
    func receiveNotification(){
        
        // send push notification //
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        for notification in self.fetchData.notifications{
            
            self.notifications.append(notification)
            appDelegate.scheduleNotification(at: Date(), body: notification.text)
            self.metaNotification.notificationsCount = self.notifications.count

        }
        
        if !self.notifications.isEmpty{
            self.saveNotifications()
        }

    }
    
    func automaticConfig(){
        
        // save email //
        
        // se accede al keychain //
        
        if let fetchData = TEMPManager.keychainAccess.get(KeychainKeys.UserKeys.rawValue){
            
            // se guarda la data local //
            
            self.fetchData = FetchModel(JSONString: fetchData)!
            self.loadCacheData()
            
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
    
    func loadCacheData(){
        
        // se cargan servicios visitados
        
        if let visitedServices = TEMPManager.keychainAccess.get(KeychainKeys.visitedServices.rawValue){
            // se guarda la data local //
            self.visitedServices = Mapper<ServicesModel>().mapArray(JSONString: visitedServices)!
        }
        
        
        if let notification = TEMPManager.keychainAccess.get(KeychainKeys.notifications.rawValue){
            // se guarda la data local //
            self.notifications = Mapper<NotificationModel>().mapArray(JSONString: notification)!
        }
        
        if let subscribed = TEMPManager.keychainAccess.getBool(KeychainKeys.subscribedKey.rawValue){
            // se guarda la data local //
           self.isSubscribed = subscribed
        }
        
    }
    
    func clearData(){
        TEMPManager.keychainAccess.clear()
    }
    
    
    private init(){}
}
