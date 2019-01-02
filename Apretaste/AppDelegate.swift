//
//  AppDelegate.swift
//  Apretaste
//
//  Created by Juan  Vasquez on 12/5/18.
//  Copyright © 2018 JavffCompany. All rights reserved.
//

import UIKit
import KeychainSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        // set notification delegate //
        
        self.requestNotificationAuthorization(application: application)


        // se configura el singleton tempManager

        TEMPManager.shared.automaticConfig()
        
        var storyboard = UIStoryboard(name: "MenuLogin", bundle: nil)
        let menuVC = storyboard.instantiateInitialViewController()! as! UINavigationController
       
        if TEMPManager.shared.isAlive{
            
            storyboard = UIStoryboard(name:"tabBarMenu",bundle:nil)
            let tabBarVC = storyboard.instantiateInitialViewController()!
            menuVC.pushViewController(tabBarVC, animated: false)
        }
        
        
        // set navigationSyles //
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        self.window?.rootViewController = menuVC
        self.window?.makeKeyAndVisible()
 
        return true
    }
    
    
    
    func scheduleNotification(at date: Date, body: String) {
        
        
        
        UNUserNotificationCenter.current().delegate = self

        let calendar = Calendar(identifier: .gregorian)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:2.0, repeats: false)


        let content = UNMutableNotificationContent()
        content.title = "Tienes una notificación"
        content.body = body
        content.sound = UNNotificationSound.default()

        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)

        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }

            print("send success")
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    //MARK: - notifications 
    
    
    func requestNotificationAuthorization(application: UIApplication) {
        
        UNUserNotificationCenter.current().delegate = self

        
        if #available(iOS 10.0, *) {
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (accepted, error) in
                
                if accepted{

                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
                
                
            })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.sound,.alert,.badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        TEMPManager.shared.metaNotification.notificationTapped = true
        completionHandler()
    }

}
