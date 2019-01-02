//
//  UIIMageExtension.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 1/7/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    class func imageWithColor(color: UIColor , traslucentEffect isEffect:Bool = false , blendMode blend: CGBlendMode = .luminosity) -> UIImage {
        
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 1, height: 1))
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()!
        if isEffect{
            
            context.setBlendMode(blend)
            context.setAlpha(0.15)
        }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        
        return image!
    }
}
