//
//  LoginHttpVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 17/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class LoginHttpVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextfield: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        self.addObserversForHandlerKeyboard(scrollView: self.scrollView)
    }
    
    
    private func setupView(){
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }

    @IBAction func backButtonAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
        if self.emailTextfield.text!.isEmpty{
            
            let alert = UIAlertController(title: "Error", message: "Ingrese un email", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .destructive)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        
        HTTPManager.shared.email = self.emailTextfield.text!
        
        self.startAnimating(message:"Conectando...")
        
        HTTPManager.shared.connect { (success) in
            
            self.stopAnimating()
            
            if success{
                
                let storyboard = UIStoryboard(name:"HttpCode",bundle:nil)
                let loginVC = storyboard.instantiateInitialViewController()!
                self.navigationController?.pushViewController(loginVC, animated: true)
            
            }else{
                
                let alert = UIAlertController(title: "Error", message: "Ingrese un email valido", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .destructive)
                alert.addAction(action)
                self.present(alert, animated: true)
                return
                
            }
        }
    }
}
