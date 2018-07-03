//
//  RecentCell.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 2/7/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class RecentCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
        
    }
    

}
