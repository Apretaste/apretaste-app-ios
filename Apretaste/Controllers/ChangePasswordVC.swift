//
//  ChangePasswordVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 14/8/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import UIKit

class ChangePasswordVC: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var PassTextfield: UITextField!
    @IBOutlet weak var serverSmtpTextField: UITextField!
    @IBOutlet weak var portSmtpTextField: UITextField!
    @IBOutlet weak var securitySmtpTextField: UITextField!
    @IBOutlet weak var serverImapTextField: UITextField!
    @IBOutlet weak var portImapTextField: UITextField!
    @IBOutlet weak var securityImapTextField: UITextField!
    
    @IBOutlet weak var heightContraintImage: NSLayoutConstraint!
    
    
    var securityPicker = UIPickerView()
    var securityImapPicker = UIPickerView()
    
    weak var delegate:ConfigurationLoginDelegate?
    
    
    var securityOptions: [security] = [.none,.SSL]
    
    
    //MARK: - life cyrcle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupData()
        
        self.hideKeyboard()
        self.addObserversForHandlerKeyboard(scrollView: self.scrollView)
        
        securityPicker.dataSource = self
        securityPicker.delegate = self
        
        securityImapPicker.delegate = self
        securityImapPicker.dataSource = self
        
        // set textfields delegates //
        
        self.emailTextfield.delegate = self
        self.PassTextfield.delegate = self
        self.portSmtpTextField.delegate = self
        self.portImapTextField.delegate = self
        self.serverSmtpTextField.delegate = self
        self.serverImapTextField.delegate = self
        self.securityImapTextField.delegate = self
        self.securitySmtpTextField.delegate = self
        
        
    }
    
    
    //MARK: - setups
    
    private func setupView(){
        
        self.securityPicker.backgroundColor = UIColor.white
        self.securitySmtpTextField.inputView = self.securityPicker
        
        self.securityImapPicker.backgroundColor = UIColor.white
        self.securityImapTextField.inputView = self.securityImapPicker
        
    }
    
    
    private func setupData(){
        
        
        self.emailTextfield.text = SMTPManager.shared.email
        self.PassTextfield.text = SMTPManager.shared.password
        self.serverSmtpTextField.text = SMTPManager.shared.serverSMTP
        self.serverImapTextField.text = SMTPManager.shared.serverIMAP
        self.portSmtpTextField.text = "\(SMTPManager.shared.portSMTP)"
        self.portImapTextField.text = "\(SMTPManager.shared.portIMAP)"
        self.securityImapTextField.text = SMTPManager.shared.securityIMAP.rawValue
        self.securitySmtpTextField.text = SMTPManager.shared.securitySMTP.rawValue
        
        
    }
    
    
    
    
    
    
    //MARK: - actions buttons
    @IBAction func extendButton(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if TEMPManager.shared.isAlive{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func nextButton(_ sender: Any) {
        
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        self.delegate?.loginAction()
        
    }
    
    
    //MARK: - picker protocol
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.securityOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return securityOptions[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == self.securityPicker{
            
            self.securitySmtpTextField.text = self.securityOptions[row].rawValue
        }
        
        if pickerView == self.securityImapPicker{
            
            self.securityImapTextField.text = self.securityOptions[row].rawValue
            
        }
        
    }
    
    
}


//MARK: IMPLEMENT PROTOCOL FOR textfields

extension ConfigurationLoginVC: UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.PassTextfield{
            SMTPManager.shared.password = textField.text!
            
        }
        
        if textField == self.emailTextfield{
            
            SMTPManager.shared.email = textField.text!
        }
        
        if textField == self.portImapTextField{
            
            SMTPManager.shared.portIMAP = Int(textField.text!)!
            
        }
        
        
        if textField == self.portSmtpTextField{
            
            if !(textField.text?.isEmpty)!{
                
                SMTPManager.shared.portSMTP = Int(textField.text!)!
            }
        }
        
        if textField == self.serverImapTextField{
            
            if !(textField.text?.isEmpty)!{
                
                SMTPManager.shared.serverIMAP = textField.text!
            }
            
        }
        
        if textField == self.serverSmtpTextField{
            
            SMTPManager.shared.serverSMTP = textField.text!
            
        }
        
        if textField == self.securitySmtpTextField{
            
            SMTPManager.shared.securitySMTP = security(rawValue: textField.text!)!
        }
        
        if textField == self.securityImapTextField{
            
            SMTPManager.shared.securityIMAP = security(rawValue: textField.text!)!
        }
        
    }
    
}
