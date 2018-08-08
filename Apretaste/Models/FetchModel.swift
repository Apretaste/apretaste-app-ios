//
//  FetchModel.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 13/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import ObjectMapper




class FetchModel: Mappable{
    
    var timestamp = 0
    var username = ""
    var mailbox = ""
    var latest = ""
    var img_quality = ""
    var token = ""
    var domain = ""
    var credit = ""
    var active: [String] = []
    var profile = profileModel()
    var notifications:[NotificationModel] = []
    var services: [ServicesModel] = []
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        timestamp <- map["timestamp"]
        username <- map["username"]
        mailbox <- map["mailbox"]
        latest <- map["latest"]
        img_quality <- map["img_quality"]
        token <- map["token"]
        domain <- map["domain"]
        active <- map["active"]
        services <- map["services"]
        credit <- map["credit"]
        notifications <- map["notifications"]
        profile <- map["profile"]
        
    }
}

//MARK: - sub models

class profileModel: Mappable{
    
    
    var full_name = ""
    var date_of_birth = ""
    var gender = ""
    var phone = ""
    var eyes = ""
    var skin = ""
    var body_type = ""
    var hair = ""
    var province = ""
    var city = ""
    var highest_school_level = ""
    var occupation = ""
    var marital_status = ""
    var picture = ""
    
    init(){}
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        full_name <- map["full_name"]
        picture <- map["picture"]
        
        // mapping all attrs if needed MARK: - TODO
    }
    
}


class NotificationModel: Mappable{
    
    var text = ""
    var service = ""
    var link = ""
    var received = ""

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        text <- map["text"]
        service <-  map["service"]
        link <- map["link"]
        received <- map["received"]
        
    }
}


class ServicesModel:Mappable{
    
    var name = ""
    var description = ""
    var category = ""
    var creator = ""
    var update = ""
    var icon = ""

    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        name <- map["name"]
        description <- map["description"]
        category <- map["category"]
        creator <- map["creator"]
        update <- map["update"]
        icon <- map["icon"]
    }
}
