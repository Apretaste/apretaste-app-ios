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
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        self.setupCell()
        
        // load data//
        
        fetchData = TEMPManager.shared.fetchData
        dataUrl = TEMPManager.shared.urlFiles
        
        // set delegate //
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        

    }
    
    //MARK: setups
    
    private func setupView(){
        
       
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = .white

    }
    
    private func setupCell(){
        
        let nib = UINib(nibName: self.reuseIdentifier, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: self.reuseIdentifier)
    }

}

//MARK: CollectionView methods
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

        do{
            let dataImage = try Data.init(contentsOf: urlImage)
            let image = UIImage(data: dataImage)
            cell.imageView.image = image
        }catch{
            print("error load image")
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentItem = self.fetchData.services[indexPath.item]
        
        let storyboard = UIStoryboard(name: "Services", bundle: nil)
        let servicesVC = storyboard.instantiateInitialViewController()! as! ServicesVC
       
        self.startAnimating(message:"Cargando")
        
        let command = Command.generateCommand(command: currentItem.name)
        
        ConnectionManager.shared.request(command: command) { (error,html) in
            
            self.stopAnimating()
            // validate error //
            if error != nil{
                return
            }
            
            servicesVC.urlHtml = html
            
            self.navigationController?.pushViewController(servicesVC, animated: true)
        }
    }
    
    //MARK: flow layout collection view cell
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (UIScreen.main.bounds.width / 3) - 5  , height: ( UIScreen.main.bounds.width / 3) + 20)
        
    }
    
}
