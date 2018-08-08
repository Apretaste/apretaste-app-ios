//
//  LoginVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 12/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit



class LoginVC: UIViewController, UITextFieldDelegate, ConfigurationLoginDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var subject = ""
    
    //MARK: - life cycle //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        self.hideKeyboard()
        self.addObserversForHandlerKeyboard(scrollView: self.scrollView)
        
        // configure textField //
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    @objc func receiveTimer(_ timer: Timer){
        
        let subject = timer.userInfo as! String
        
        self.startAnimating(message:"Esperando respuesta...")
        
        SMTPManager.shared.receiveMail(subject: subject, completion: { (error, data, urlFiles) in
            
            self.stopAnimating()
            
            if error != nil{
                
                let alert = UtilitesMethods.failLogin()
                self.present(alert, animated: true)
                return
            }
            
            timer.invalidate()
           
            
            // salvamos la data//
            
            // abrimos nueva vista //
            
            // save data //
            
            TEMPManager.shared.fetchData = data!
            TEMPManager.shared.relativePath = urlFiles!
            
            // set connection type //
            ConnectionManager.shared.connectionType = .smtp
                        
            SMTPManager.shared.saveConfig()
            
            let storyboard = UIStoryboard(name: "tabBarMenu", bundle: nil)
            let homeVC = storyboard.instantiateInitialViewController()!
            self.navigationController?.pushViewController(homeVC, animated: true)
            
        })
    }
    
    
    //MARK: - setups
    
    private func setupView(){
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    private func setupData(){
        
        
        self.emailTextField.text = SMTPManager.shared.email
        self.passwordTextField.text = SMTPManager.shared.password
        
    }
    
    //MARK: - selectors
    
    @objc func emailObserver(){
        
        SMTPManager.shared.email = self.emailTextField.text!
        
    }
    
    @objc func passwordObserver(){
        
        SMTPManager.shared.password = self.passwordTextField.text!
        
    }
    
    
    func validate() ->Bool{
        
        if SMTPManager.shared.email.isEmpty || SMTPManager.shared.password.isEmpty{
            
            return false
        }
        
        return true
            
    }
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - actions buttons
    
    @IBAction func loginActionButton(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if !validate(){
            
            let alert = UIAlertController(title: "Error", message: "Ingrese sus datos.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .destructive)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        
        self.startAnimating(message: "Conectando...")
        
        let newCommand = Command.generateCommand(command: Command.getProfile.rawValue)
        let zip = UtilitesMethods.writeZip(task: newCommand)
        
        SMTPManager.shared.sendMail(zip: zip, task: Command.getProfile.rawValue) { (subject) in
            
            self.stopAnimating()
            
            guard let subject = subject else{
                
                let alert = UtilitesMethods.failLogin()
                self.present(alert, animated: true)
                return
            }
            
            let timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(self.receiveTimer(_:)), userInfo: subject, repeats: true)
            
            timer.fire()
            
        }

    }
    
    @IBAction func settingLoginAction(_ sender: Any) {
        
        self.view.endEditing(true)

        
        let storyboard = UIStoryboard(name: "ConfigurationLogin", bundle: nil)
        let configurationLoginVC = storyboard.instantiateInitialViewController()! as! ConfigurationLoginVC
        configurationLoginVC.delegate = self
        configurationLoginVC.modalTransitionStyle = .crossDissolve
        self.present(configurationLoginVC, animated: true)
         
    }
    
    //MARK: - textfield delegate

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.passwordTextField{
            SMTPManager.shared.password = textField.text!
            
        }
        
        if textField == self.emailTextField{
            
            SMTPManager.shared.email = textField.text!
            
        }
    }
    
    //MARK: - configuration delegate
    
    func loginAction() {
        
        let button = UIButton()
        self.loginActionButton(button)
    }


    
}
