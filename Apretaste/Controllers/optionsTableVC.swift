//
//  optionsTableVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 18/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class optionsTableVC: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var tableImage: UIImageView!
    
    @IBOutlet weak var tableLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
        
    }


}
