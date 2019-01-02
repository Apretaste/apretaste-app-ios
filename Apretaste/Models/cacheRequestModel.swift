//
//  cacheRequestModel.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 2/7/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import ObjectMapper

class requestModel: Mappable{
    
    var url: URL!
    var command = ""
    var htmlName = ""
    var date = ""
    var relativePath = ""{
        didSet{
            
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            
            let url = NSURL(fileURLWithPath: path).appendingPathComponent(relativePath)!.appendingPathComponent(htmlName)
            
            self.url = url
            
        }
    }
    
    init(command:String, url:String, date: Date){
        
        self.command = command
        let split = url.split(separator: "/")
        self.htmlName = String(split.last!)
        self.relativePath = String(split[split.count - 2])
        self.date = UtilitesMethods.formatDateToISOString(date: date)
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        command <- map["command"]
        htmlName <- map["htmlName"]
        date <- map["date"]
        relativePath <- map["relativePath"]
        
    }
}


class cacheRequestModel: Mappable{
    
    
    var arrayRequest:[requestModel]  = []
    
    
    init(){}
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        arrayRequest <- map["arrayRequest"]
    }
}
