//
//  UIViewControllerExtension.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 12/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

extension UIViewController: NVActivityIndicatorViewable {
    
    
    
    static let keyboardWillShow = NotificationDescriptor(name: Notification.Name.UIKeyboardWillShow, convert: KeyboardPayload.init)
    static let keyboardWillHide = NotificationDescriptor(name: Notification.Name.UIKeyboardWillHide, convert: KeyboardPayload.init)
    
    
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    
    func addObserversForHandlerKeyboard(scrollView : UIScrollView){
        
        let center = NotificationCenter.default
        
        center.addObserver(with: UIViewController.keyboardWillShow) { (payload) in
            
            let keyboardFrame = self.view.convert(payload.beginFrame, from: nil)
            var contentInset:UIEdgeInsets = scrollView.contentInset
            contentInset.bottom = keyboardFrame.size.height + 100
            scrollView.contentInset = contentInset
            
        }
        
        center.addObserver(with: UIViewController.keyboardWillHide) { _ in
            
            let contentInset = UIEdgeInsets.zero
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        }
        
    }
}





struct NotificationDescriptor<Payload> {
    let name: Notification.Name
    let convert: (Notification) -> Payload
}

extension NotificationCenter {
    func addObserver<Payload>(with descriptor: NotificationDescriptor<Payload>, block: @escaping (Payload) -> ()) {
        addObserver(forName: descriptor.name, object: nil, queue: nil) { (note) in
            block(descriptor.convert(note))
        }
    }
}


struct KeyboardPayload {
    let beginFrame: CGRect
    let endFrame: CGRect
    let curve: UIViewAnimationCurve
    let duration: TimeInterval
    let isLocal: Bool
}
extension KeyboardPayload {
    
    init(note: Notification) {
        let userInfo = note.userInfo
        beginFrame = userInfo?[UIKeyboardFrameBeginUserInfoKey] as! CGRect
        endFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        curve = UIViewAnimationCurve(rawValue: userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! Int)!
        duration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        isLocal = userInfo?[UIKeyboardIsLocalUserInfoKey] as! Bool
    }
}

