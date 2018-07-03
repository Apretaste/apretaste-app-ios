//
//  PrincipalNavigation.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 1/7/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class PrincipalNavigation: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }

    private func setupView(){
        
        let backgroundImage = UIImage.imageWithColor(color: UIColor.greenApp)
        self.navigationBar.setBackgroundImage(backgroundImage, for: .default)
        
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        self.navigationBar.titleTextAttributes = textAttributes
        
        self.navigationBar.isTranslucent = false
        self.view.backgroundColor = .greenApp

    }
}
