
//
//  TabBarMenuVC.swift
//  declareItSupport
//
//  Created by IOS Developer on 4/3/18.
//  Copyright © 2018 Technifiser. All rights reserved.
//

import UIKit

class TabBarMenuVC: UITabBarController {
    
    //MARK: - vars
    
    var observers = [NSKeyValueObservation]()

    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTabs()
        self.setupView()
        self.observeModel()
        
    }
    
    
    //MARK: - setups
    
    private func setupTabs(){
        
        
        
        // set style //
        
        if #available(iOS 10.0, *) {
            self.tabBar.unselectedItemTintColor = UIColor.lightGray
        } else {
            // Fallback on earlier versions
        }
        self.tabBar.tintColor = UIColor.white
        
        //MARK: configure root view controllers //
        let homeVC = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController()!
        
        let homeBarItem = UITabBarItem(title: "Inicio", image: UIImage.init(named: "home")!, tag: 0)
        homeVC.tabBarItem = homeBarItem
        
        let notificationVC = UIStoryboard(name: "Notification", bundle: nil).instantiateInitialViewController()!
        
        let notificationBarItem =  UITabBarItem(title: "notificación", image: UIImage.init(named: "email")!, tag: 0)
        
        notificationVC.tabBarItem = notificationBarItem
        
        let optionsVC = UIStoryboard(name: "options", bundle: nil).instantiateInitialViewController()!
        let optionsBarItem =   UITabBarItem(title: "Opciones", image: UIImage.init(named: "gear")!, tag: 0)
        optionsVC.tabBarItem = optionsBarItem
        
        self.viewControllers = [notificationVC,homeVC,optionsVC]
        
        //MARK: set root tab
        
        self.selectedIndex = 1
        
        
    }
    
    private func setupView(){
        
        //MARK: set styles //
        
        self.tabBar.tintColor = UIColor.white
        self.tabBar.barTintColor = UIColor.greenApp
        self.tabBar.isTranslucent = false

        
        if #available(iOS 10.0, *) {
            self.tabBar.unselectedItemTintColor = UIColor.darkGray
        }
        // set navigation bar style //
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    func observeModel() {
        
        self.observers = [
            
            TEMPManager.shared.metaNotification.observe(\.notificationsCount, options: [.initial]) { (model, change) in
                
                let badge: String? = TEMPManager.shared.metaNotification.notificationsCount == 0 ? nil :  String(TEMPManager.shared.metaNotification.notificationsCount)
               
                self.tabBar.items![0].badgeValue = badge
                
            },
            
        
            TEMPManager.shared.metaNotification.observe(\.notificationTapped, options: [.initial]) { (model, change) in
                
                if model.notificationTapped{
                    
                    self.selectedIndex = 0

                }
                
            }]
        
        
    }
    
    //MARK: - override tabBar methods
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        
        tabBar.tintColor = UIColor.white
        
    }
    
    
}
