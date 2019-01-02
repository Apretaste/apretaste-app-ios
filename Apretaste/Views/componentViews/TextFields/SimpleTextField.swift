//
//  SimpleTextField.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 17/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import UIKit

class simpleTextField: UITextField, UITextFieldDelegate{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        
        self.setupView()
        
        
        //toolbar
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.done,target:self,action:#selector(self.doneClicked))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.cancel,target:self,action:#selector(self.cancelButton))
        
        toolBar.setItems([cancelButton,flexibleSpace,doneButton], animated: false)
        
        self.inputAccessoryView = toolBar
        
        // set delegate
        self.delegate = self
        
    }
    
    @objc func doneClicked() ->Bool{
        return self.textFieldShouldReturn(self)
    }
    
    @objc func cancelButton(){
        
        self.resignFirstResponder()
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.becomeFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        // try to find next responder //
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // not found, so remove keyboard //
            textField.resignFirstResponder()
        }
        // do not add a line break //
        return false
    }
    
    
    func setupView(){
        
        self.borderStyle = .roundedRect
        self.font = UIFont(name: "Roboto-Regular", size: 12.0)
        
    }
    
    
    
    func addLeftIcon(image: UIImage, widthIcon width: CGFloat = 15 , heightIcon height: CGFloat = 15  ) {
        
        let imageView = UIImageView()
        
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        imageView.contentMode = .scaleAspectFit
        self.leftViewMode = UITextFieldViewMode.always
        self.leftView = imageView
        self.addSubview(imageView)
        
        
    }
    
    // padding left in textFields
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 5, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 5, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
}
