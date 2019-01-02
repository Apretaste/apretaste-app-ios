//
//  RecentsVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 2/7/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit
import KeychainSwift

class RecentsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - vars

    @IBOutlet weak var tableView: UITableView!
    private let reuseIdentifier = "RecentCell"
    
    var recentsData: [requestModel] = []
    
    //MARK: - life cycle //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.getData()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    //MARK: - setups

 
    private func setupView(){
        
        self.navigationItem.title = "Recientes"
        self.tableView.tableFooterView = UIView()
    }
    
    //MARK: - funcs
    private func getData(){
        
        let keychain = KeychainSwift()
        
        if let cacheData = keychain.get(KeychainKeys.CacheData.rawValue){
            
            guard let data = cacheRequestModel(JSONString: cacheData) else{
                return
            }
            
            self.recentsData = data.arrayRequest.reversed()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    //MARK: - tableView implementations
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier) as! RecentCell
        let currentItem = self.recentsData[indexPath.row]
        cell.titleLabel.text = currentItem.command
        cell.subTitleLabel.text = UtilitesMethods.formatDateToPrettyDateString(fecha: currentItem.date)
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentItem = self.recentsData[indexPath.row]
        let storyboard = UIStoryboard(name: "Services", bundle: nil)
        let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
        servicesVC.urlHtml = currentItem.url
        servicesVC.command = currentItem.command
        self.navigationController?.pushViewController(servicesVC, animated: true)

    }
    

}
