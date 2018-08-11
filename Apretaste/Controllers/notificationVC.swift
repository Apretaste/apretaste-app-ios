//
//  notificationVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 18/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class notificationVC: UIViewController {
    
    //MARK: - vars

    @IBOutlet weak var tableView: UITableView!
    private let reuseIdentifier = "NotificationCell"
    
    var notifications:[NotificationModel] = []
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Notificaciones"                                 
        
        self.tableView.tableFooterView = UIView()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width , height: 200))
        label.text = "No tienes notificaciones disponibles, intente refrescar la aplicación."
        label.textAlignment = .center
        label.numberOfLines = 0
        self.tableView.backgroundView = label
        
        // add delete button //
        
        let button = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteButtonTapped))
        
        self.navigationItem.rightBarButtonItem = button
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
    }
    
    //MARK: - funcs

    
    @objc func deleteButtonTapped(){
        
        let alert = UIAlertController(title: "Atención", message: "¿Desea eliminar todas las notificaciones?", preferredStyle: .alert)
        
        let deleteButton = UIAlertAction(title: "Borrar", style: .default) { (_) in
            
            TEMPManager.shared.notifications = []
            self.notifications = []
            TEMPManager.shared.saveNotifications()

            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let cancelButton = UIAlertAction(title: "Cancelar", style: .cancel)
        
        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: nil)
        
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         self.notifications = TEMPManager.shared.notifications
        // delete badge
        
         TEMPManager.shared.metaNotification.notificationsCount = 0
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    //MARK: - helpers
    
    func formatingDate(stringDate:String) ->String{
        
        let splitData = stringDate.split(separator: " ")
        
       let temporalDate = String(splitData.first!)
       var temporalHour = String(splitData.last!)
        
        let splitTemporalDate = temporalDate.split(separator: "-")
        
        let year = String(splitTemporalDate[0])
        let month = String(splitTemporalDate[1])
        let day = String(splitTemporalDate[2])

        
        temporalHour.removeLast()
        temporalHour.removeLast()
        temporalHour.removeLast()
        
        
        return "\(day)/\(month)/\(year) \(temporalHour)"
    
    }
  
}

extension notificationVC:UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        tableView.backgroundView?.alpha = self.notifications.isEmpty ? 1 : 0
        return self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier) as! NotificationCell
        
        let currentNotification = self.notifications[indexPath.row]
        cell.serviceName.text = currentNotification.service
        cell.messageLabel.text = " asdhasiduahsdkuasdhasiudhasdiuashdaisudhaiudhasiduhasdiashdiasudhsiudhcurrentNotification.text"
        cell.dateLabel.text = self.formatingDate(stringDate: currentNotification.received)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentNotification = self.notifications[indexPath.row]

        self.startAnimating(message:"cargando")
        
        ConnectionManager.shared.request(command: currentNotification.link) { (error, url) in
            
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
            servicesVC.command = currentNotification.link
            self.navigationController?.pushViewController(servicesVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            self.notifications.remove(at: indexPath.row)
            TEMPManager.shared.notifications.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            TEMPManager.shared.saveNotifications()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
