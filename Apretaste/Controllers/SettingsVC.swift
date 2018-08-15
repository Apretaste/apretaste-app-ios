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
    
    @IBOutlet weak var suscriptionSwitch: UISwitch!
    
    var quality: [String] = [
        "ORIGINAL",
        "REDUCIDA",
        "SIN_IMAGENES"
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
        
        self.imageQuality.addTarget(self, action: #selector(self.changedImageQuality(_:)), for: .editingDidEnd)


    }
    
    //MARK: - setups
    
    private func setupView(){
        
        // set data //
        self.title = "Configuraciones"
        self.connectionType.dataSource = [connection]
        self.imageQuality.dataSource = [quality]
        self.suscriptionSwitch.isOn = TEMPManager.shared.isSubscribed
    
        self.imageQuality.text = TEMPManager.shared.fetchData.img_quality
        self.connectionType.text = ConnectionManager.shared.connectionType.rawValue
        
    }
    
    //MARK: - funcs
    
    @objc func changedImageQuality(_ textField:UITextField){

        let command = "PERFIL IMAGEN \(textField.text!)"
        
        self.startAnimating(message:"Ejecutando..")
        
        ConnectionManager.shared.requestAwait(command: command) { (success) in
            
            self.stopAnimating()
            
            if success{
                TEMPManager.shared.fetchData.img_quality = textField.text!
                TEMPManager.shared.saveTempData()
            }
            
            let title = success ? "Operación completada" : "Ocurrio un error intente más tarde."
            
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            let done = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
    }

    @objc func changedConnectionType(_ textField:UITextField){
        
        if textField.text == ConnectionType.http.rawValue{
            
            ConnectionManager.shared.connectionType = ConnectionType.http

        }else{
            // smtp case
            
            ConnectionManager.shared.connectionType = ConnectionType.smtp
        }
        
    }
   
    @IBAction func setNautaButtonTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "ChangePassword", bundle: nil)
        let configurationVC = storyboard.instantiateInitialViewController()! as! ChangePasswordVC
        configurationVC.delegate = self
        self.navigationController?.pushViewController(configurationVC, animated: true)
    }
    
    
    @IBAction func suscriptionSwitchTapped(_ sender: UISwitch) {
        
        var command = "SUSCRIPCION LISTA"
        command = sender.isOn ? "\(command) ENTRAR" : "\(command) SALIR"
        
        self.startAnimating()
        
        ConnectionManager.shared.requestAwait(command: command) { (success) in
            
            self.stopAnimating()
            
            let title = success ? "Operación completada" : "Ocurrio un error intente más tarde."
            
            // save status //
            
            TEMPManager.shared.saveSuscriptionMail(isSubscribed: sender.isOn)
            
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            let done = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
        
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
        
        // verify connection
        
        let command = "PERFIL IMAGEN \(self.imageQuality.text!)"
        
        self.startAnimating(message:"Comprobando..")
        
        let previusType =  ConnectionManager.shared.connectionType
        ConnectionManager.shared.connectionType = .smtp
        
        // testing smtp config //
        
        ConnectionManager.shared.requestAwait(command: command) { (success) in
            
            self.stopAnimating()
            
             ConnectionManager.shared.connectionType = previusType
            
            let title = success ? "Se han guardado sus cambios." : "Hubo un error, compruebe sus datos."
            
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            let done = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(done)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
}
