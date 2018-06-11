//
//  ProfileVC.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 17/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    
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
        // Do any additional setup after loading the view.
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







    }
   

}
