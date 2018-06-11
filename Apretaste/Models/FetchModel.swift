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
    var active: [String] = []
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
        
    }
}

//MARK: sub models


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
