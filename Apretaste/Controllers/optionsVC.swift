//
//  optionsVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 18/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class optionsVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    enum CellType: Int{
        
        case profile = 0 , recents  ,settings, quiz , refferAndWin ,cupons, about, exit, options
    }
    
    @IBOutlet weak var tableView: UITableView!

    let options = ["Perfil", "Recientes","Configuraciones", "Retos", "Referir y ganar","cupones", "Acerca de", "Salir"]
    
    let imgs = ["user","recents","configuration","flag","referir","ticket","about","exit"]

    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
 
    }
    
    private func setupView(){

        self.title = "Opciones"
        self.tableView.tableFooterView = UIView()

    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! optionsTableVC
        cell.tableLabel.text = options[indexPath.row]
        cell.tableImage.image = UIImage(named: imgs[indexPath.row])
        return cell
    }
    
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellType:CellType = CellType(rawValue: indexPath.row)!

        
        if cellType == .exit{
            
            let alert = UIAlertController(title: "Salir", message: "Seguro que desea salir de la aplicación?", preferredStyle: .alert)

            let exit = UIAlertAction(title: "Salir", style: .default) { (_) in

                TEMPManager.shared.clearData()
                let appDelegate = UIApplication.shared.delegate
                let storyboard = UIStoryboard(name: "MenuLogin", bundle: nil)
                let rootVC = storyboard.instantiateInitialViewController()!
                appDelegate?.window??.rootViewController = rootVC
                appDelegate?.window??.makeKeyAndVisible()
            }

            let cancel = UIAlertAction(title: "Cancelar", style: .cancel)

            alert.addAction(exit)
            alert.addAction(cancel)
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)

            }
            return

        }
        
        if cellType == .settings{
            
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let settingsVC = storyboard.instantiateInitialViewController()!
            self.navigationController?.pushViewController(settingsVC, animated: true)
        }

        if cellType == .profile{

           
            self.startAnimating(message:"cargando")
            let command = "PERFIL EDITAR"
            
            ConnectionManager.shared.request(command: command) { (error, url) in
                
                self.stopAnimating()
                
                if error != nil{
                   
                    let alert = UIAlertController(title: "Error", message: "Verifique su conexión a internet", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let storyboard = UIStoryboard(name: "Services", bundle: nil)
                let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
                servicesVC.urlHtml = url
                servicesVC.command = command
                self.navigationController?.pushViewController(servicesVC, animated: true)

            }
            

        }
        
        if cellType == .about{
            
            let storyboard = UIStoryboard(name: "About", bundle: nil)
            let aboutVC = storyboard.instantiateInitialViewController()!
            self.navigationController?.pushViewController(aboutVC, animated: true)
        }
        
        if cellType == .options{
            
            let storyboard = UIStoryboard(name: "setup", bundle: nil)
            let options = storyboard.instantiateInitialViewController()!
            self.navigationController?.pushViewController(options, animated: true)
        }
        
        if cellType == .recents{
            
            let storyboard = UIStoryboard(name: "Recents", bundle: nil)
            let recentVC = storyboard.instantiateInitialViewController()!
            self.navigationController?.pushViewController(recentVC, animated: true)
            
        }
        
        if cellType == .quiz{
            
            self.startAnimating(message:"cargando")
            let command = "retos"
            
            ConnectionManager.shared.request(command: command) { (error, url) in
                
                self.stopAnimating()
                
                if error != nil{
                   
                    let alert = UIAlertController(title: "Error", message: "Verifique su conexión a internet", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let storyboard = UIStoryboard(name: "Services", bundle: nil)
                let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
                servicesVC.urlHtml = url
                servicesVC.command = command
                self.navigationController?.pushViewController(servicesVC, animated: true)
                
            }
        }
        
        if cellType == .refferAndWin{
            
            self.startAnimating(message:"cargando")
            let command = "referir"
            
            ConnectionManager.shared.request(command: command) { (error, url) in
                
                self.stopAnimating()
                
                if error != nil{
                    let alert = UIAlertController(title: "Error", message: "Verifique su conexión a internet", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let storyboard = UIStoryboard(name: "Services", bundle: nil)
                let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
                servicesVC.urlHtml = url
                servicesVC.command = command
                self.navigationController?.pushViewController(servicesVC, animated: true)
                
            }
        }
        
        if cellType == .cupons{
            
            self.startAnimating(message:"cargando")
            let command = "cupones"
            
            ConnectionManager.shared.request(command: command) { (error, url) in
                
                self.stopAnimating()
                
                if error != nil{
                    
                    let alert = UIAlertController(title: "Error", message: "Verifique su conexión a internet", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let storyboard = UIStoryboard(name: "Services", bundle: nil)
                let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
                servicesVC.urlHtml = url
                servicesVC.command = command
                self.navigationController?.pushViewController(servicesVC, animated: true)
                
            }
        }

    }

}
