//
//  ServicesVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 10/6/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit
import JavaScriptCore

class ServicesVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var command:String!
    var urlHtml:URL!
    var jsContext: JSContext!
    var selectComponents:[String] = []
    var textField: UITextField!

    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config webView //
        
        self.webView.delegate = self
        
        // call setups //
        self.setupView()
        self.loadWebView()
        self.handlerJavaScript()
        
    }
    
    //MARK: - setups
    
    private func setupView(){
        
       self.webView.backgroundColor = .white
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshButtonTapped))
        refreshButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = refreshButton
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        

    }
    
    private func loadWebView(){
        
        let formatHTML = self.procesingHtmlContent()
        self.webView.loadHTMLString(formatHTML, baseURL:self.urlHtml)


    }
    
    //MARK: - funcs
    
    
    @objc func refreshButtonTapped(){
        
        self.startAnimating(message:"Refrescando")
        
        ConnectionManager.shared.request(withCaching:false,command: self.command) { (error, url) in
            
            self.stopAnimating()
            
            if error != nil{
                
                let alert = UIAlertController(title: "Error", message: "Verifique su conexión a internet", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let storyboard = UIStoryboard(name: "Services", bundle: nil)
            let serviceVC = storyboard.instantiateInitialViewController()! as! ServicesVC
            serviceVC.command = self.command
            serviceVC.urlHtml = url
            self.navigationController?.pushViewController(serviceVC, animated: true)

        }
        
        
    }
    
    private func procesingHtmlContent() -> String{
        
        var contentFile = ""
        let stringError = "<h4>Existe un problema con este servicio. Intente más tarde.</h4>"
        
        do{
            
            if self.command.lowercased().contains("escuela"){
                contentFile = try String.init(contentsOf: self.urlHtml, encoding: .ascii)
            }else{
                contentFile = try String.init(contentsOf: self.urlHtml)
            }

        }catch{
            return stringError
        }
        
        let cleanContentFile = contentFile.replacingOccurrences(of: "return false;", with: "")
        
        if let cssSourcePath = Bundle.main.path(forResource: "styles", ofType: "css") {
            
            let importCss = "<link rel=\"stylesheet\" type=\"text/css\" href=\"\(cssSourcePath)\" />"
            
              return "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\"/> \(importCss)</head><body> \(cleanContentFile) </body></html>"           
        }
        
      
        return stringError
        
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
    
    
    func createCustomTextField(_ textField: UITextField,message:String) {
        
        textField.placeholder = self.extractMessage(message: message)
        
        if message.hasPrefix("n:"){
            textField.keyboardType = .numberPad
        }
        
        if message.hasPrefix("m:"){
            
            // delete prefix //
            var newMessage = message
            
            newMessage.removeFirst()
            newMessage.removeFirst()
            
            var tempItems = newMessage.components(separatedBy: "[").last!
            tempItems.removeLast()
            
            let items = tempItems.components(separatedBy: ",")

            self.selectComponents = items
            self.textField = textField
            
            let picker = UIPickerView()
            
            picker.dataSource = self
            picker.delegate = self
            
            textField.text = items.first!
            textField.inputView = picker

            
        }
        
        if message.hasPrefix("d:"){
            
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            textField.inputView = datePicker
            
            self.textField = textField
            
            datePicker.addTarget(self, action: #selector(self.changeDataPicker(_:)), for: .valueChanged)
            
        }
        
        if message.hasPrefix("u:"){
            
            
        }

    }
    
    @objc func changeDataPicker(_ datePicker: UIDatePicker){
        
        let dateString = UtilitesMethods.formatDateToPrettyDateString(date: datePicker.date, format: "dd/MM/YYYY")
        
        self.textField.text = dateString
    }
    
    func extractMessage(message:String) -> String{
        
        if message.hasPrefix("m:"){
            
            // delete prefix //
            var newMessage = message
            newMessage.removeFirst()
            newMessage.removeFirst()
            
            let message = newMessage.components(separatedBy: "[").first!
            
            return message
            
        }
        
        if message.hasPrefix("d:") || message.hasPrefix("n:"){
            
            // delete prefix //
            var newMessage = message
            newMessage.removeFirst()
            newMessage.removeFirst()
            return newMessage
            
        }
        
        
        return message
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
            
            if popup{
                
                let userMessage = "Ingrese los datos solicitados"
                
                let alertText = UIAlertController(title: self.title, message: userMessage, preferredStyle: .alert)
                
                let messagesTextFields = message.split(separator: "|")
                
                for messageTextField in messagesTextFields{
                    
                    let message = String(messageTextField)
                    
                    alertText.addTextField { (textfield) in
                        
                        self.createCustomTextField(textfield, message: message)
                    }
                }
                
                
                let done = UIAlertAction(title: "Aceptar", style: .default, handler: { (_) in
                    
                    var searchString = ""
                    
                    for textField in alertText.textFields ?? []{
                        
                        searchString = searchString + " " + textField.text!
                        
                    }
                    
                    self.startAnimating(message:"cargando")
                    
                    let newCommand = "\(command) \(searchString)"
                    
                    ConnectionManager.shared.requestAwait(command: newCommand) { (success) in
                        
                        self.stopAnimating()
                      
                        let message = "Operación realizada exitosamente"
                        let title = "Éxito" 
                        let alert = UIAlertController(title: title , message: message, preferredStyle: .alert)
                        let actionButton = UIAlertAction(title: "OK", style: .cancel)
                        alert.addAction(actionButton)
                        self.present(alert, animated: true)
                        
                    }
                    
                })
                
                let cancel = UIAlertAction(title: "Cancelar", style: .cancel)
                
                alertText.addAction(cancel)
                alertText.addAction(done)
                self.present(alertText, animated: true)
                
                return
                
            }
            
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
            
            let userMessage = "Ingrese los datos solicitados"
            
            let alertText = UIAlertController(title: self.title, message: userMessage, preferredStyle: .alert)
            
            let messagesTextFields = message.split(separator: "|")
            
            for messageTextField in messagesTextFields{
                
                let message = String(messageTextField)
                
                alertText.addTextField { (textfield) in
                    
                    self.createCustomTextField(textfield, message: message)
                }
            }
            
            let done = UIAlertAction(title: "Aceptar", style: .default, handler: { (_) in
                
                var searchString = ""
                
                for textField in alertText.textFields ?? []{
                    
                    searchString = searchString + " " + textField.text!

                }
                
                self.startAnimating(message:"cargando")
                
                let newCommand = "\(command) \(searchString)"
                
                ConnectionManager.shared.request(command: newCommand) { (error,html) in
                    
                    self.stopAnimating()
                    // validate error //
                    if error != nil{
                        
                        let alert = UIAlertController(title: "Error", message: "Verifique su conexión a internet", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .cancel)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    let storyboard = UIStoryboard(name: "Services", bundle: nil)
                    let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
                    servicesVC.urlHtml = html
                    servicesVC.command = newCommand
                    servicesVC.title = String(command.split(separator: " ").first!)
                    TEMPManager.shared.saveVisitedServices()
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
                
                let alert = UIAlertController(title: "Error", message: "Verifique su conexión a internet", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let storyboard = UIStoryboard(name: "Services", bundle: nil)
            let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
            servicesVC.urlHtml = html
            servicesVC.command = command
            servicesVC.title = String(command.split(separator: " ").first!)
            TEMPManager.shared.saveVisitedServices()
            self.navigationController?.pushViewController(servicesVC, animated: true)
            
        }
        
    }
}

//MARK: - WebView Delegate //

extension ServicesVC: UIWebViewDelegate{

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        if navigationType == .linkClicked{
            
            self.captureOnClicked()
            return false
        }
        return true
    }
}

extension ServicesVC: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return self.selectComponents.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.selectComponents[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textField.text = self.selectComponents[row]
        
    }
    
    
    
}
