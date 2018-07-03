//
//  HTTPCodeVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 19/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class HTTPCodeVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var codeTextField: UITextField!
    
    // MARK: life cycle //

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        self.addObserversForHandlerKeyboard(scrollView: self.scrollView)

    }
    
    //MARK: setups //

    
    private func setupView(){
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    //MARK: action buttons //
  
    @IBAction func nextButtonAction(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if self.codeTextField.text!.isEmpty{
            
            let alert = UIAlertController(title: "Error", message: "Ingrese un codigo", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .destructive)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        
        self.startAnimating(message:"Validando código")

        
        HTTPManager.shared.validateMail(pin: self.codeTextField.text!) { (response, success) in
            
            self.stopAnimating()
            
            if success{
                
                self.startAnimating(message:"Iniciando...")
                
                HTTPManager.shared.sendRequest(task: Command.getProfile.rawValue, completion: { (error, fetchData, urlFiles) in
                    
                    self.stopAnimating()
                    
                    if error != nil{
                        return
                    }
                    
                    // save data //
                    
                    TEMPManager.shared.fetchData = fetchData!
                    TEMPManager.shared.relativePath = urlFiles!
                    
                    // Set connection type //
                    ConnectionManager.shared.connectionType = .http

                    let storyboard = UIStoryboard(name: "tabBarMenu", bundle: nil)
                    let homeVC = storyboard.instantiateInitialViewController()! 
                    self.navigationController?.pushViewController(homeVC, animated: true)
                })
                
            }else{
                
                let alert = UIAlertController(title: "Error", message: response, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .destructive)
                alert.addAction(action)
                self.present(alert, animated: true)
                
            }
            
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
