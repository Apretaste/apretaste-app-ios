//
//  MenuLoginVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 17/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class MenuLoginVC: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(true, animated: true)


    }


    @IBAction func connectHttpAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name:"LoginHttp",bundle:nil)
        let loginVC = storyboard.instantiateInitialViewController()!
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func connectNautaAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name:"Login",bundle:nil)
        let loginVC = storyboard.instantiateInitialViewController()!
        self.navigationController?.pushViewController(loginVC, animated: true)

    }
}
