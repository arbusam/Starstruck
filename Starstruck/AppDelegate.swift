//
//  AppDelegate.swift
//  Starstruck
//
//  Created by Arhan Busam on 9/3/2023.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let defaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        if defaults.integer(forKey: "balance") == 0 {
            defaults.set(501, forKey: "balance")
            
            let currentDate = Date()
            let oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: oneMonthFromNow!)
            defaults.set(dateString, forKey: "renewalDate")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if dateFormatter.date(from: defaults.string(forKey: "renewalDate")!)! < Date() {
            defaults.set(defaults.integer(forKey: "balance")+51, forKey: "balance")
            
            let currentDate = Date()
            let oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: oneMonthFromNow!)
            defaults.set(dateString, forKey: "renewalDate")
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

