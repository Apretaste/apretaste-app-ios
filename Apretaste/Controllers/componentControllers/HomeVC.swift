//
//  HomeVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 13/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    //MARK: - vars
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let reuseIdentifier = "HomeCell"
    private let searchReuseIdentifier = "SearchCell"
    
    var fetchData: FetchModel!
    var dataUrl: URL!
    var isFilter = false
    
    var numberOfElementInScreen = 0
    
    var filterServices: [ServicesModel] = []
    
    var searchController = UISearchController(searchResultsController: nil)

    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        self.setupNavigationBar()
        self.setupCell()
        self.setupAdaptableResponsive()
                
        // load data//
        
        fetchData = TEMPManager.shared.fetchData
        dataUrl = TEMPManager.shared.urlFiles
        
        // set delegate //
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNavigationBar()

    }
    
    //MARK: -  setups
    
    private func setupView(){
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = .white
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshButtonTapped))
        refreshButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = refreshButton

    }
    
    private func setupAdaptableResponsive(){
        
        switch UIDevice.current.userInterfaceIdiom {
            
        case .phone:
            
                self.numberOfElementInScreen = 3
            
        case .pad:
            
            self.numberOfElementInScreen = 6
           
        default:
            break
        }
        
    }

    
    private func setupNavigationBar(){
        
        // set image //
        let dataUrl = TEMPManager.shared.urlFiles!
        
        let profileImageName = TEMPManager.shared.fetchData.profile.picture
        
        let urlImage = dataUrl.appendingPathComponent(profileImageName)
        
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        let imageview = UIImageView(frame: CGRect(x: -10, y: -5, width: 40, height: 40))
        imageview.layer.cornerRadius = 20
        imageview.layer.masksToBounds = true
        imageview.contentMode = .scaleAspectFit


        do{
            let dataImage = try Data.init(contentsOf: urlImage)
            let image =  UIImage(data: dataImage)
            imageview.image = image
            containView.addSubview(imageview)
           
        }catch{
            
            let image =  UIImage(named: "user")!
            imageview.image = image
            containView.addSubview(imageview)
        }
        
        let title = UILabel(frame: CGRect(x: 35, y: 0, width: 100, height: 15))
        let credit = UILabel(frame: CGRect(x: 40, y: 15, width: 100, height: 15))
        
        title.text = TEMPManager.shared.fetchData.username
        title.textColor = .white
        title.font = UIFont.systemFont(ofSize: 15)
        credit.text = "§ \(TEMPManager.shared.fetchData.credit)"
        credit.textColor = .white
        credit.font = UIFont.systemFont(ofSize: 12)
        
        containView.addSubview(title)
        containView.addSubview(credit)
        let rightBarButton = UIBarButtonItem(customView: containView)
        self.navigationItem.leftBarButtonItem = rightBarButton
        
        // set title //
        
        self.title = "Apretaste"
        
        // set search bar //
        
        self.view.backgroundColor = .greenApp
        self.navigationController?.navigationBar.barTintColor = .greenApp
        self.navigationController?.navigationBar.backgroundColor = .greenApp
        
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .greenApp
        searchController.searchBar.backgroundColor = .greenApp
        
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            //textfield.textColor = // Set text color
            if let backgroundview = textfield.subviews.first {
                
                // Background color
                backgroundview.backgroundColor = .white
                
                // Rounded corner
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true
                
            }
        }
        
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            
            navigationController?.navigationBar.largeTitleTextAttributes =
                [NSAttributedStringKey.foregroundColor: UIColor.white]
            
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.searchController = searchController
          
        } 
    }
    
    private func setupCell(){
        
        var nib = UINib(nibName: self.reuseIdentifier, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: self.reuseIdentifier)
        
        nib = UINib(nibName: self.searchReuseIdentifier, bundle: nil)
        self.collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.searchReuseIdentifier)
    }
    
    //MARK: - funcs
    
    @objc func refreshButtonTapped(){
        
        self.startAnimating(message:"Refrescando")
        
        ConnectionManager.shared.refreshProfile { (success) in
            
            self.stopAnimating()
            
            if success{
                
                DispatchQueue.main.async {
                    
                    self.setupNavigationBar()
                    self.fetchData = TEMPManager.shared.fetchData
                    self.dataUrl = TEMPManager.shared.urlFiles
                    self.collectionView.reloadData()
                }
            }
        }
        
    }
    
    func openServices(indexPath:IndexPath, search searching:String = ""){
        
        let currentItem = self.isFilter ? self.filterServices[indexPath.item] :  self.fetchData.services[indexPath.item]
        
        let storyboard = UIStoryboard(name: "Services", bundle: nil)
        let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
        
        self.startAnimating(message:"Cargando")
        
        let commandString = "\(currentItem.name) \(searching)"
        
        ConnectionManager.shared.request(command: commandString) { (error,html) in
            
            self.stopAnimating()
            // validate error //
            if error != nil{
                
                if let parserError = error as? ManagerError{
                    
                    // custom error //
                    
                    switch parserError{
                        
                    case .smtpNoReceived(let subject):
                        
                        let alert = UIAlertController(title: "Error", message: "No hemos recibido respuesta del servidor. Esto puede ser un fallo en la conexion, o que nuestro servicio este temporalmente caido. Intente nuevamente y si falla por favor denos unas horas para corregir el problema. Avisaremos a nuestro equipo lo que ocurre.", preferredStyle: .alert)
                        
                        let action =  UIAlertAction(title: "Aceptar", style: .cancel, handler: { (_) in
                            
                            //TODO: falta enviar correo
                            SMTPManager.shared.sendErrorMail(subject: subject)
                            
                        })
                        
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        return
                        
                        
                    case .badSmtpConfig:
                        
                        let alert = UIAlertController(title: "Error", message: "Usted esta intentando comunicarse con el servidor usando su correo Nauta, por favor verifique su configuración y vuelva a intentarlo.", preferredStyle: .alert)
                        
                        let action =  UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                            
                            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                            let configurationVC = storyboard.instantiateInitialViewController()! as! SettingsVC
                            self.navigationController?.pushViewController(configurationVC, animated: true)
                            
                        })
                        
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        return
                        
                    case .badRequest:break

                }
                   
                }
                
                //default errror //
                
                let alert = UIAlertController(title: "Error", message: "Verifique su conexión a internet", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            servicesVC.urlHtml = html
            servicesVC.command = commandString
            servicesVC.title = currentItem.name

            if !TEMPManager.shared.visitedServices.contains(where: { (service) -> Bool in
                return service.name == currentItem.name
            }){
                TEMPManager.shared.visitedServices.append(currentItem)
                
            }
        
            TEMPManager.shared.saveVisitedServices()
            self.collectionView.reloadData()
            self.navigationController?.pushViewController(servicesVC, animated: true)
        }
    }

}

//MARK: - CollectionView methods
extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0{
            return 0
        }

        return self.isFilter ? self.filterServices.count : fetchData.services.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        


        if kind == UICollectionElementKindSectionHeader {
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.searchReuseIdentifier, for: indexPath) as! SearchCell
            
            if let textfield = headerView.searchBar.value(forKey: "searchField") as? UITextField {
                //textfield.textColor = // Set text color
                if let backgroundview = textfield.subviews.first {
                    
                    // Background color
                    backgroundview.backgroundColor = .white
                    
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 10;
                    backgroundview.clipsToBounds = true
                    
                    textfield.clearButtonMode = .never
                    
                }
            }
            
            headerView.searchBar.delegate = self
            
            return headerView
            
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        // section 1 = section of elements
        if section == 1 {
            return .zero
        }
        
        // not show Header searchBar  in ios 11
        if #available(iOS 11.0, *) {
            return .zero
        }
        
        // show header search bar in IOS 10
        return CGSize(width: UIScreen.main.bounds.width, height: 45)
    }
    
  
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! HomeCellVC
        
        let currentServices = self.isFilter ? self.filterServices[indexPath.item] :  self.fetchData.services[indexPath.item]
        
        let urlImage = self.dataUrl.appendingPathComponent(currentServices.icon)
        cell.serviceNameLabel.text = currentServices.name
        cell.isNew = !TEMPManager.shared.visitedServices.contains(where: { (service) -> Bool in
                return service.name == currentServices.name
            })
        
        DispatchQueue.global().async {
            
            do{
                let dataImage = try Data.init(contentsOf: urlImage)
                let image = UIImage(data: dataImage)
                DispatchQueue.main.async {
                    cell.imageView.image = image
                }
                
            }catch{
                print("error load image")
            }
            
        }
        
        return cell
       
    }
    
    
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let popoverController = alert.popoverPresentationController {
            
            let cell = collectionView.cellForItem(at: indexPath)!
            popoverController.sourceView = cell
            popoverController.sourceRect = CGRect(x: cell.bounds.midX, y: cell.bounds.midY, width: 0, height: 0)
        }
        
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
    
    //MARK: - helpers
    
    fileprivate func calculateElementSize(minOfRect:Int) -> CGSize{
        
        let width = Int(UIScreen.main.bounds.width)
        
        let numberOfParts = width / minOfRect
        
        let restantWidth = width - (numberOfParts * minOfRect)
        
        let restantByElement = restantWidth / numberOfParts
        
        let result = minOfRect + restantByElement
        
        return CGSize(width: result, height: result + 20)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfElement = self.numberOfElementInScreen
        let minOfRect = Int(Int(UIScreen.main.bounds.width) / numberOfElement)
    
        return self.calculateElementSize(minOfRect: minOfRect)
        
       // return CGSize(width: (UIScreen.main.bounds.width / 6) - 5  , height: ( UIScreen.main.bounds.width / 6) + 20)
        
    }
    
}

//MARK: - IMPLEMENT SEARCH CONTROLLER
extension HomeVC: UISearchControllerDelegate,UISearchBarDelegate,UISearchResultsUpdating, UITextFieldDelegate{
   
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text!
        self.searchAction(searchText: searchText)
    }
    
    //MARK: ios 10 compatibility
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        if(!searchBar.text!.isEmpty){
            self.searchAction(searchText: searchBar.text!)
        }
        
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if(!searchText.isEmpty){
            print(searchText)
            self.searchAction(searchText: searchText)
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        self.searchAction(searchText: textField.text!)
        return true
    }
 
    
    //MARK: helper
    
    private func searchAction(searchText:String){
        
        self.isFilter = !searchText.isEmpty
        
        self.filterServices = self.fetchData.services.filter { (service) -> Bool in
            
            return service.name.lowercased().contains(searchText.lowercased())
        }
        
        self.collectionView.performBatchUpdates({
            let indexSet = IndexSet(integersIn: 1...1)
            self.collectionView.reloadSections(indexSet)
        })
        
    }

}


