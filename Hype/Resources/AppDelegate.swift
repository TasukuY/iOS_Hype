//
//  AppDelegate.swift
//  Hype
//
//  Created by Tasuku Yamamoto on 5/2/22.
//

import UIKit
import UserNotifications
import CloudKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { userDidAllow, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
            }
            
            if userDidAllow == true {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        return true
    }//End of function
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //Subscribe to remote notifications on our detabase
        HypeController.shared.subscribeForRemoteNotifications { error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
            }
        }
        
    }//End of function

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error in \(#function) : \(error.localizedDescription) \n--\n \(error)")
    }//End of function
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        HypeController.shared.fetchHypes { success in
            if success {
                //TODO: - Notification
            }
        }
    }//End of function
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }//End of function
    
}//End of class

