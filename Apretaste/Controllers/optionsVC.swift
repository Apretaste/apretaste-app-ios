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
        
        case profile = 0 , recents , options , quiz , refferAndWin , about, exit
    }
    
    @IBOutlet weak var tableView: UITableView!

    let options = ["Perfil", "Recientes", "Opciones", "Retos", "Referir y ganar", "Acerca de", "Salir"]

    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    private func setupView(){
    
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        

    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! optionsTableVC
        
        
        cell.tableLabel.text = options[indexPath.row]
        cell.tableImage.image = UIImage(named: options[indexPath.row])
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellType:CellType = CellType(rawValue: indexPath.row)!
        
        if cellType == .exit{
            
            TEMPManager.shared.clearData()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }


}
