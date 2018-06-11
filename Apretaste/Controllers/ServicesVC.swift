//
//  ServicesVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 10/6/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class ServicesVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var urlHtml:URL!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        self.loadWebView()
        
    }

    
    private func setupView(){
        
       

    }
    
    private func loadWebView(){
        
        let request = URLRequest(url: urlHtml)
        self.webView.loadRequest(request)
        
        
    }
 
}
