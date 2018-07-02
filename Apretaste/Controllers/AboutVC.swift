//
//  AboutVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 28/6/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.setupView()
    }

    
    private func setupView(){
        
        self.versionLabel.text = "versión 3.1"
    }
    

    
}
