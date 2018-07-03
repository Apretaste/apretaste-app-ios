//
//  notificationVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 18/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class notificationVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let reuseIdentifier = "NotificationCell"
    
    var notifications:[NotificationModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Notificaciones"
        
        self.notifications = TEMPManager.shared.fetchData.notifications
        self.tableView.tableFooterView = UIView()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width , height: 200))
        label.text = "No tienes notificaciones disponibles, intente refrescar la aplicación."
        label.textAlignment = .center
        label.numberOfLines = 0
        self.tableView.backgroundView = label
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
        cell.messageLabel.text = currentNotification.text
        cell.dateLabel.text = currentNotification.received
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentNotification = self.notifications[indexPath.row]

        self.startAnimating(message:"cargando")
        
        ConnectionManager.shared.request(command: currentNotification.link) { (error, url) in
            
            self.stopAnimating()
            
            if error != nil{
                return
            }
            
            let storyboard = UIStoryboard(name: "Services", bundle: nil)
            let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
            servicesVC.urlHtml = url
            self.navigationController?.pushViewController(servicesVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
