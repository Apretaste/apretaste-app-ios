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
    
    let imgs = ["user","recents","configuration","flag","referir","about","exit"]

    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    private func setupView(){

        
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
                self.navigationController?.popToRootViewController(animated: true)
            }

            let cancel = UIAlertAction(title: "Cancelar", style: .cancel)

            alert.addAction(exit)
            alert.addAction(cancel)

            self.present(alert, animated: true, completion: nil)

        }

        if cellType == .profile{

            let storyboard = UIStoryboard(name: "ProfileVC", bundle: nil)
            let profileVC = storyboard.instantiateInitialViewController()!
            self.navigationController?.pushViewController(profileVC, animated: true)

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

    }

}
