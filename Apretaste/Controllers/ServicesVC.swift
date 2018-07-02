//
//  ServicesVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 10/6/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit
import JavaScriptCore
import WebKit

class ServicesVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var urlHtml:URL!
    
    var jsContext: JSContext!

    var t = WKWebView()
    
    //MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config webView //
        
        self.webView.delegate = self
        
        // call setups //
        self.setupView()
        self.loadWebView()
        self.handlerJavaScript()
        
    }
    
    //MARK: setups
    
    private func setupView(){
        
       self.webView.backgroundColor = .white
        

    }
    
    private func loadWebView(){
        
        let formatHTML = self.procesingHtmlContent()
        self.webView.loadHTMLString(formatHTML, baseURL: nil)


    }
    
    //MARK: - funcs
    
    private func procesingHtmlContent() -> String{
        
        let contentFile = try! String.init(contentsOf: self.urlHtml)
        
        let cleanContentFile = contentFile.replacingOccurrences(of: "return false;", with: "")
        
        return "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\"/> </head><body> \(cleanContentFile) </body></html>"
        
    }
    
    private func handlerJavaScript(){
        
        self.jsContext =  self.webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext

        if let jsSourcePath = Bundle.main.path(forResource: "resource", ofType: "js") {
            do {
                let jsSourceContents = try String(contentsOfFile: jsSourcePath)
                
                self.jsContext.evaluateScript(jsSourceContents)
            }
            catch {
                print(error.localizedDescription)
            }
        }

    }
    
    func captureOnClicked() {
        
        if let capture = self.jsContext.objectForKeyedSubscript("apretaste") {
            guard let data = capture.toDictionary() else{
                return
            }
            
            let urlKey = AnyHashable.init("url")
            let popupKey = AnyHashable.init("popup")
            let waitKey = AnyHashable.init("wait")
            let messageKey = AnyHashable.init("message")
            let url = data[urlKey] as! String
            let popup =  data[popupKey] as! Bool
            let wait =  data[waitKey] as! Bool
            let message =  data[messageKey] as! String
            

            self.handlerOnClicked(command: url, popup: popup, message: message,wait: wait)
        }
    }
    
    func handlerOnClicked(command:String, popup:Bool,message:String, wait: Bool){
        
        if !wait{
            
            self.startAnimating(message:"cargando")
            
            ConnectionManager.shared.requestAwait(command: command) { (success) in
                
                self.stopAnimating()
                
                let message = success ? "Operación realizada exitosamente" : "Ocurrió un error"
                let title = success ? "Éxito" : "Error"
                let alert = UIAlertController(title: title , message: message, preferredStyle: .alert)
                let actionButton = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(actionButton)
                self.present(alert, animated: true)
            }
            
            return
        }
        
        if popup{
            
            let alertText = UIAlertController(title: self.title, message: message, preferredStyle: .alert)
            
            alertText.addTextField(configurationHandler: nil)
            
            let done = UIAlertAction(title: "Aceptar", style: .default, handler: { (_) in
                
                let searchString = alertText.textFields![0].text!
                
                self.startAnimating(message:"cargando")
                
                let newCommand = "\(command) \(searchString)"
                
                ConnectionManager.shared.request(command: newCommand) { (error,html) in
                    
                    self.stopAnimating()
                    // validate error //
                    if error != nil{
                        return
                    }
                    
                    let storyboard = UIStoryboard(name: "Services", bundle: nil)
                    let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
                    servicesVC.urlHtml = html
                    servicesVC.title = String(command.split(separator: " ").first!)
                    TEMPManager.shared.saveOpenServices()
                    self.navigationController?.pushViewController(servicesVC, animated: true)
                    
                }

            })
            
            let cancel = UIAlertAction(title: "Cancelar", style: .cancel)
            
            alertText.addAction(cancel)
            alertText.addAction(done)
            self.present(alertText, animated: true)
            
            return
        }
        
        // open new Link //
        self.startAnimating(message:"cargando")
        
        ConnectionManager.shared.request(command: command) { (error,html) in
            
            self.stopAnimating()
            // validate error //
            if error != nil{
                return
            }
            
            let storyboard = UIStoryboard(name: "Services", bundle: nil)
            let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
            servicesVC.urlHtml = html
            servicesVC.title = String(command.split(separator: " ").first!)
            TEMPManager.shared.saveOpenServices()
            self.navigationController?.pushViewController(servicesVC, animated: true)
            
        }
        
    }
}

//MARK: WebView Delegate //

extension ServicesVC: UIWebViewDelegate{

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        if navigationType == .linkClicked{
            
            self.captureOnClicked()
            return false
        }
        return true
    }

}
