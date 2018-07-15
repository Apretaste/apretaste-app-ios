//
//  SettingsVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 13/7/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    //MARK: - vars
    
    @IBOutlet weak var imageQuality: PickerTextField!
    
    @IBOutlet weak var connectionType: PickerTextField!
    
    var quality: [String] = [
        "original",
        "reducida",
        "sin imagenes"
    ]
    
    var connection:[String] = [
        ConnectionType.http.rawValue,
        ConnectionType.smtp.rawValue
    ]
    
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        // add target
        
        self.connectionType.addTarget(self, action: #selector(self.changedConnectionType(_:)), for: .editingDidEnd)

    }
    
    //MARK: - setups
    
    private func setupView(){
        
        
        // set data //
        self.title = "Configuraciones"
       self.connectionType.dataSource = [connection]
       self.imageQuality.dataSource = [quality]
        
        self.connectionType.text = ConnectionManager.shared.connectionType.rawValue
        
        
    }
    
    //MARK: - funcs

    @objc func changedConnectionType(_ textField:UITextField){
        
        if textField.text == ConnectionType.http.rawValue{
            
            ConnectionManager.shared.connectionType = ConnectionType.http

        }else{
            // smtp case
            
            ConnectionManager.shared.connectionType = ConnectionType.smtp
        }
        
    }
   
    @IBAction func setNautaButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "ConfigurationLogin", bundle: nil)
        
        let configurationVC = storyboard.instantiateInitialViewController()! as! ConfigurationLoginVC
        configurationVC.delegate = self
        configurationVC.modalTransitionStyle = .crossDissolve
        configurationVC.modalPresentationStyle = .overFullScreen
        self.present(configurationVC, animated: true, completion: nil)
    }
    
    
    @IBAction func suscriptionSwitchTapped(_ sender: UISwitch) {
        
        
    }
    
    @IBAction func changeBuzonButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "ChangeMail", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()!
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - implement configuration delegate

extension SettingsVC: ConfigurationLoginDelegate{
    
    func loginAction() {
        
        SMTPManager.shared.saveConfig()

        let alert = UIAlertController(title: "Actualizado", message: "sus cambios han sido guardados", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
}
