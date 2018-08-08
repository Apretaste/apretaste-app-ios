//
//  ChangeMailVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 14/7/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class ChangeMailVC: UIViewController {
    
    //MARK: - vars

    @IBOutlet weak var mailBox: simpleTextField!
    @IBOutlet weak var domainTextField: simpleTextField!
    
    //MARK: - life cylce
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }
    
    //MARK: - stups
    
    private func setupView(){
        
        self.title = "Cambiar buzón"
        
        self.domainTextField.text = HTTPManager.shared.requestDomain
        
        self.mailBox.text = TEMPManager.shared.fetchData.mailbox
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save
            , target: self, action: #selector(self.saveButtonTapped))
        
        self.navigationItem.rightBarButtonItem = saveButton
        
    }
    
    //MARK: - funcs
    
    @objc func saveButtonTapped(){
        
        self.view.endEditing(true)
    
        HTTPManager.shared.requestDomain = domainTextField.text!
        SMTPManager.shared.mailBox = self.mailBox.text!
        TEMPManager.shared.fetchData.mailbox = self.mailBox.text!
        
        TEMPManager.shared.saveTempData()
        
        let alert = UIAlertController(title: "Operación exitosa", message: "Se han guardado los cambios", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
}
