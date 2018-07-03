//
//  HomeVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 13/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private let reuseIdentifier = "HomeCell"
    
    var fetchData: FetchModel!
    var dataUrl: URL!
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        self.setupNavigationBar()
        self.setupCell()
                
        // load data//
        
        fetchData = TEMPManager.shared.fetchData
        dataUrl = TEMPManager.shared.urlFiles
        
        // set delegate //
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        

    }
    
    //MARK: -  setups
    
    private func setupView(){
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = .white
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshButtonTapped))
        refreshButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = refreshButton

    }
    

    

    
    private func setupNavigationBar(){
        
        // set image //
        let dataUrl = TEMPManager.shared.urlFiles!
        
        let urlImage = dataUrl.appendingPathComponent("user.jpg")
        
        do{
            let dataImage = try Data.init(contentsOf: urlImage)
            let image = UIImage(data: dataImage)
            let containView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
            
            let title = UILabel(frame: CGRect(x: 35, y: 3, width: 100, height: 15))
            let credit = UILabel(frame: CGRect(x: 35, y: 20, width: 100, height: 15))
            let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            
            imageview.image = image
            imageview.contentMode = .scaleAspectFit
            title.text = TEMPManager.shared.fetchData.username
            title.textColor = .white
            title.font = UIFont.systemFont(ofSize: 15)
            credit.text = "$ \(TEMPManager.shared.fetchData.credit)"
            credit.textColor = .white
            credit.font = UIFont.systemFont(ofSize: 12)
            imageview.layer.cornerRadius = 20
            imageview.layer.masksToBounds = true
            containView.addSubview(imageview)
            containView.addSubview(title)
            containView.addSubview(credit)
            let rightBarButton = UIBarButtonItem(customView: containView)
            self.navigationItem.leftBarButtonItem = rightBarButton
            
        }catch{
            print("error load image")
        }
        
        // set search bar //
        
        self.title = "Apretaste"
        
//        if #available(iOS 11.0, *) {
//            
//            self.view.backgroundColor = .greenApp
//            self.navigationController?.navigationBar.barTintColor = .greenApp
//            self.navigationController?.navigationBar.backgroundColor = UIColor.greenApp
//            navigationController?.navigationBar.prefersLargeTitles = true
//            navigationController?.navigationBar.largeTitleTextAttributes =
//                [NSAttributedStringKey.foregroundColor: UIColor.white]
//            
//            let searchController = UISearchController(searchResultsController: nil)
//            
//             searchController.searchBar.tintColor = UIColor.white
//             searchController.searchBar.barTintColor = UIColor.white
//            searchController.searchBar.backgroundColor = .greenApp
//            
//            if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
//                //textfield.textColor = // Set text color
//                if let backgroundview = textfield.subviews.first {
//                    
//                    // Background color
//                    backgroundview.backgroundColor = UIColor.white
//                    
//                    // Rounded corner
//                    backgroundview.layer.cornerRadius = 10;
//                    backgroundview.clipsToBounds = true;
//                    
//                }
//            }
//            
//            
//            navigationItem.searchController = searchController
//           
//          
//        } else {
//            // Fallback on earlier versions
//        }
    }
    
    private func setupCell(){
        
        let nib = UINib(nibName: self.reuseIdentifier, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: self.reuseIdentifier)
    }
    
    //MARK: - funcs
    
    @objc func refreshButtonTapped(){
        
        self.startAnimating(message:"Refrescando")
        
        ConnectionManager.shared.refreshProfile { (success) in
            
            self.stopAnimating()
            
            if success{
                
                DispatchQueue.main.async {
                    
                    self.fetchData = TEMPManager.shared.fetchData
                    self.dataUrl = TEMPManager.shared.urlFiles
                    self.collectionView.reloadData()
                }
            }
        }
        
    }
    
    func openServices(indexPath:IndexPath, search searching:String = ""){
        
        let currentItem = self.fetchData.services[indexPath.item]
        
        let storyboard = UIStoryboard(name: "Services", bundle: nil)
        let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
        
        self.startAnimating(message:"Cargando")
        
        let commandString = "\(currentItem.name) \(searching)"
        
        
        ConnectionManager.shared.request(command: commandString) { (error,html) in
            
            self.stopAnimating()
            // validate error //
            if error != nil{
                return
            }
            
            servicesVC.urlHtml = html
            servicesVC.command = commandString
            servicesVC.title = self.fetchData.services[indexPath.item].name
            self.fetchData.services[indexPath.item].isVisited = true
            TEMPManager.shared.saveChangesInServices()
            self.collectionView.reloadItems(at: [indexPath])
            self.navigationController?.pushViewController(servicesVC, animated: true)
        }
    }

}

//MARK: - CollectionView methods
extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return fetchData.services.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath)
       
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let cell = cell as! HomeCellVC
       
        let currentServices = self.fetchData.services[indexPath.item]
        let urlImage = self.dataUrl.appendingPathComponent(currentServices.icon)
        cell.serviceNameLabel.text = currentServices.name
        cell.isNew = !currentServices.isVisited
        
        do{
            let dataImage = try Data.init(contentsOf: urlImage)
            let image = UIImage(data: dataImage)
            cell.imageView.image = image
        }catch{
            print("error load image")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let search = UIAlertAction(title: "Buscar", style: .default){ (_) in
            
            let alertText = UIAlertController(title: "Buscar", message: "Escriba un texto para ejecutar dentro del servicio", preferredStyle: .alert)
            
            alertText.addTextField(configurationHandler: nil)
            
            let done = UIAlertAction(title: "Aceptar", style: .default, handler: { (_) in
                
                let searchString = alertText.textFields![0].text!
                self.openServices(indexPath: indexPath, search: searchString)
            })
            
            let cancel = UIAlertAction(title: "Cancelar", style: .cancel)
            
            alertText.addAction(cancel)
            alertText.addAction(done)
            
            self.present(alertText, animated: true)
            
        }
        
        let open = UIAlertAction(title: "Abrir", style: .default) { (_) in
            
            self.openServices(indexPath: indexPath)
        }
        
        let detail = UIAlertAction(title: "Detalles", style: .default) { (_) in
            
            let currentItem = self.fetchData.services[indexPath.item]
            let urlImage = self.dataUrl.appendingPathComponent(currentItem.icon)
            let storyboard = UIStoryboard(name: "Detail", bundle: nil)
            let detailVC = storyboard.instantiateInitialViewController()! as! DetailVC
            detailVC.selectedServices = currentItem
            detailVC.urlImage = urlImage
            self.navigationController?.pushViewController(detailVC, animated: true)

        }
        
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(open)
        alert.addAction(search)
        alert.addAction(detail)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
       
    }
    
    
    
    //MARK: - flow layout collection view cell
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (UIScreen.main.bounds.width / 3) - 5  , height: ( UIScreen.main.bounds.width / 3) + 20)
        
    }
    
}
