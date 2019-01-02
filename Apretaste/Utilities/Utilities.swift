//
//  Utilities.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 12/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import UIKit
import Zip



class UtilitesMethods{
    
    /** Crea un archivo en temporales */
    
   static func write(text: String, to fileNamed: String, folder: String = "SavedFiles") -> URL?{
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return nil}
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folder) else { return nil }
        try? FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
        let file = writePath.appendingPathComponent(fileNamed + ".txt")
        try! text.write(to: file, atomically: true, encoding: String.Encoding.utf8)
    
        return file
    }
    
    //** lee  zip  */
    
    static func readZip(data: Data, to fileNamed: String, folder: String = "SavedFiles") -> URL?{
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return nil}
        
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folder) else { return nil }
        
        
        do{
        
        try FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
        let file = writePath.appendingPathComponent(fileNamed)
        try data.write(to: file)
        return file

        }catch{
            return nil
        }
        
    }
    
    //** genera zip */
    
    static func writeZip(task: String) -> (URL,String){
        
        let zipName = RandomGenerator.generateName(numberOfWords: 1) + ".zip"
        let txtName = RandomGenerator.generateName(numberOfWords: 1)
        
        let path = UtilitesMethods.write(text: task, to: txtName)
        let compressZip = try! Zip.quickZipFiles([path!], fileName: zipName)
        
        return (compressZip,zipName)
        
    }
    
    static func writeZipWithImage(task:String, imageURL: URL) -> (URL,String){
        
        let zipName = RandomGenerator.generateName(numberOfWords: 1) + ".zip"
        let txtName = RandomGenerator.generateName(numberOfWords: 1)
        
        let path = UtilitesMethods.write(text: task, to: txtName)!
        let compressZip = try! Zip.quickZipFiles([path,imageURL], fileName: zipName)
        
        return (compressZip,zipName)
        
    }
    
    //* retorna una tupla con el json parser + el URL de la carpeta descomprimida
    
    
    static func receiveZip(data:Data, filename:String) -> ([URL],String){
        
        // save zip
        
        // unzip response
        
        do {
            
            guard let zipPath = UtilitesMethods.readZip(data: data, to: filename) else{
                return ([],"")
            }
           
            let unzipPath = try Zip.quickUnzipFile(zipPath, progress: { (progress) in
                print(progress)
            })
            
            let unzipFolder = try FileManager.default.contentsOfDirectory(at: unzipPath, includingPropertiesForKeys: nil)
            let relativePath = String(unzipPath.absoluteString.split(separator: "/").last!)
            return (unzipFolder,relativePath)
        
        }catch{
            
            return ([],"")
            
        }
        
    }
    
    static  func failLogin() -> UIAlertController{
        
        let alert = UIAlertController(title: "Error", message: "No hemos podido establecer comunicación, asegurese que los datos moviles esten encendidos, de lo contrario es problema de conexión con los servidores nauta, intentelo más tarde nuevamente", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .destructive)
        alert.addAction(action)

        return alert
        
    }
    
    
    static func formatDateToPrettyDateString (date : Date, format formatString :String = "M/dd/yyyy") ->String{
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = formatString
        
        return dateFormatter.string(from: date)
        
        
    }
    
    static func formatDateToPrettyDateString (fecha : String) ->String{
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let dt = dateFormatter.date(from: fecha) else{
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            guard let dt = dateFormatter.date(from: fecha) else{
                
                return ""
                
            }
            
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "M/dd/yyyy"
            
            return dateFormatter.string(from: dt)
            
            
        }
        
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat =  "M/dd/yyyy"
        
        return dateFormatter.string(from: dt)
        
        
    }
    
    
    static func formatDateToISOString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return dateFormatter.string(from: date).appending("Z")
    }
    
    static func formatISOStringToDate(date: String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let result = dateFormatter.date(from: date) else{
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return  dateFormatter.date(from: date)!
            
            
        }
        
        return result
    }
 
    
}
