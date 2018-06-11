//
//  HomeCellVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 13/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class HomeCellVC: UICollectionViewCell {
    
    var isNew = false{
        
        didSet{
            
            newImage.alpha = isNew ? 1 : 0
        }
    }
    
    @IBOutlet weak var newImage: UIImageView!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
}
