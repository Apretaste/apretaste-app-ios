//
//  CustomPickerTextField.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 17/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//


import Foundation
import UIKit
class PickerTextField: simpleTextField, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    public var selectedRow = 0
    public var dataSource: [[String]] = [[]]{
        
        didSet{
            
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
            }
        }
    }
    
    private var pickerView = UIPickerView()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    //MARK: setups
    
    override func setupView(){
        super.setupView()
        
        // set picker view //
        
        self.pickerView.backgroundColor = .white
        
        self.inputView = self.pickerView
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
    }
    
    //MARK: done action
    
    override func doneClicked() -> Bool {
        
        let selectedRow = self.pickerView.selectedRow(inComponent: 0)
        self.pickerView(pickerView, didSelectRow: selectedRow, inComponent: 0)
        return super.doneClicked()
    }
    
    
    //MARK: impelement picker delegate //
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return self.dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return  self.dataSource[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return self.dataSource[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.selectedRow = row
        self.text = self.dataSource[component][row]
    }
    
    
}


//MARK: implement date Picker custom //

import Foundation
import UIKit
class CustomDatePickerTextField: simpleTextField{
    
    
    public var  date:Date = Date()
    public var datePickerMode: UIDatePickerMode = .date
    
    
    private var datePicker = UIDatePicker()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    //MARK: setups
    
    override func setupView(){
        super.setupView()
        
        // set picker date //
        
        self.datePicker.backgroundColor = .white
        
        self.inputView = datePicker
        
        self.datePicker.addTarget(self, action: #selector(self.datePickerChange(_:)), for: .valueChanged)
        
        self.datePicker.datePickerMode = datePickerMode
        
    }
    
    
    @objc func datePickerChange(_ datePicker: UIDatePicker){
        
        self.text =  UtilitesMethods.formatDateToPrettyDateString(date: datePicker.date, format: "dd/MM/yyyy")
        
        self.date = datePicker.date
        
    }
    
    
    //MARK: done action
    
    override func doneClicked() -> Bool {
        
        self.text =  UtilitesMethods.formatDateToPrettyDateString(date: datePicker.date, format: "dd/MM/yyyy")
        self.date = datePicker.date
        return super.doneClicked()
    }
    
    
    
}
