//
//  ProfileVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 17/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var userNameTextField: simpleTextField!
    @IBOutlet weak var nameTextField: simpleTextField!
    @IBOutlet weak var birthdateTextField: CustomDatePickerTextField!
    @IBOutlet weak var sexTextField: PickerTextField!
    @IBOutlet weak var orientationSexTextField: PickerTextField!
    @IBOutlet weak var cellphoneTextField: simpleTextField!
    @IBOutlet weak var bodyTextField: PickerTextField!
    @IBOutlet weak var eyesTextField: PickerTextField!
    @IBOutlet weak var skinTextField: PickerTextField!
    @IBOutlet weak var hairTextField: PickerTextField!
    @IBOutlet weak var civilStatusTextField: PickerTextField!
    @IBOutlet weak var schoolLevelTextField: PickerTextField!
    @IBOutlet weak var profesionTextField: simpleTextField!
    @IBOutlet weak var cityTextField: simpleTextField!
    @IBOutlet weak var provinceTextField: PickerTextField!
    @IBOutlet weak var interestTextField: simpleTextField!
    @IBOutlet weak var religionTextField: PickerTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var sexValue: [String] = ["Masculino","Femenino"]
    var orientationSexValue: [String] = ["Hetero","Gay","Bisexual"]
    var bodyValue: [String] = ["Delgado","Medio","Extra","Atlético"]
    var eyesValue: [String] = ["Negros","Carmelitas","Verdes","Azules","Avellana","Otro"]
    var skinValue: [String] = ["Blanca","Negra","Mestiza","Otro"]
    var hairValue: [String] = ["Trigueño","Castaño","Rubio","Negro","Rojo","Blanco","Otro"]
    var civilStatusValue: [String] = ["Soltero","Casado","Divorciado","Viudo"]
    var schoolLevelValue: [String] = ["Primaria","Secundaria","Técnico","Universitario","Postgraduado","Doctorado","Otro"]
    var provinceValue: [String] = ["Pinar del Río","La Habana","Artemisa","Mayabeque","Matanzas","Las Villas","Cienfuegos","Sancti Spríritus","Ciego","Casado","Camagüey","Las Tunas","Holguín","Granma","Santiago","Guantánamo","Isla de la Juventud"]
    var religionValue: [String] = ["Ateísmo","Secularismo","Agnosticismo","Catolicismo","Cristianismo","Islam","Raftafarismo","Judaísmo","Espiritismo","Sijismos","Budismo","Otra"]



    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
    self.addObserversForHandlerKeyboard(scrollView: self.scrollView)
    }

    
    //MARK: setups
    
    private func setupView(){
        
        // configure pickers //
        self.civilStatusTextField.dataSource = [civilStatusValue]
        self.sexTextField.dataSource = [sexValue]
        self.orientationSexTextField.dataSource = [orientationSexValue]
        self.bodyTextField.dataSource = [bodyValue]
        self.eyesTextField.dataSource = [eyesValue]
        self.hairTextField.dataSource = [hairValue]
        self.skinTextField.dataSource = [skinValue]
        self.schoolLevelTextField.dataSource = [schoolLevelValue]
        self.provinceTextField.dataSource = [provinceValue]
        self.religionTextField.dataSource = [religionValue]

        
        // set data //
        
        self.userNameTextField.text = TEMPManager.shared.fetchData.username


        // set rightBarButtons //
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveButtonTapped))

        self.navigationItem.rightBarButtonItems = [saveButton]
        
        // style profile image ///
        
        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.width / 2
        self.imageProfile.layer.borderColor = UIColor.greenApp.cgColor
        self.imageProfile.layer.borderWidth = 5
        self.imageProfile.layer.masksToBounds = true
        
        // add tap event for imageView //
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.imageProfileTapped))
        self.imageProfile.addGestureRecognizer(gesture)
        self.imageProfile.isUserInteractionEnabled = true
        

    }
    
    @objc func saveButtonTapped(){
        
    }
    
    @objc func imageProfileTapped(){
        
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        controller.allowsEditing = false
        self.present(controller, animated: true, completion: nil)
        
    }
}

extension ProfileVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let backgroundImage = UIImage.imageWithColor(color: UIColor.greenApp)
        navigationController.navigationBar.setBackgroundImage(backgroundImage, for: .default)
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController.navigationBar.titleTextAttributes = textAttributes
        navigationController.navigationBar.isTranslucent = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as?  UIImage{

            self.imageProfile.image = image
            self.dismiss(animated: true, completion: nil)

            
        } else{
            print("Something went wrong")
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}
