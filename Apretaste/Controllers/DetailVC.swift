//
//  DetailVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 20/6/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {
    
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var serviceDescription: UILabel!
    @IBOutlet weak var serviceCreator: UILabel!
    @IBOutlet weak var serviceVersion: UILabel!
    @IBOutlet weak var serivceCategory: UILabel!
    
    
    var selectedServices: ServicesModel!
    var urlImage: URL!
    
    //MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()

    }

    
    //MARK: Setups
    
    private func setupView(){
        
        // set data //
        
        self.serviceName.text = selectedServices.name
        self.serviceDescription.text = selectedServices.description
        self.serviceCreator.text = selectedServices.creator
        self.serivceCategory.text = selectedServices.category
        self.serviceVersion.text = selectedServices.update
        
        do{
            let dataImage = try Data.init(contentsOf: urlImage)
            let image = UIImage(data: dataImage)
            self.serviceImage.image = image
        }catch{
            print("error load image")
        }
        
    }

}
