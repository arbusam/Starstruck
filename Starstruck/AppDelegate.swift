//
//  AppDelegate.swift
//  Starstruck
//
//  Created by Arhan Busam on 9/3/2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseDatabase
import Security

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let defaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // Check if the UUID exists in the keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.arhanbusam.Starstruck.uuid",
            kSecAttrAccount as String: "user",
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        // If the UUID exists, use it to authenticate with Firebase
        if status == errSecSuccess, let existingItem = item as? [String: Any],
            let uuidData = existingItem[kSecValueData as String] as? Data,
            let uuidString = String(data: uuidData, encoding: .utf8) {
            print(uuidString)
            
            // Retrieve the user's chat count from Firebase
            let ref = Database.database().reference().child("users").child(uuidString)
            ref.child("renewalDate").getData() { error, snapshot in
                guard error == nil else {
                    // Store the new UUID in Firebase
//                    let ref = Database.database().reference().child("users").child(uuidString)
//                    
//                    let currentDate = Date()
//                    let oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyy-MM-dd"
//                    let dateString = dateFormatter.string(from: oneMonthFromNow!)
//                    ref.child("renewalDate").setValue(dateString)
//                    
//                    var chatCount: Int?
//                    
//                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
//                        if let value = snapshot.value as? [String: Any], let tempChatCount = value["chatCount"] as? Int {
//                            chatCount = tempChatCount
//                        }
//                    })
//                    
//                    if chatCount == nil {
//                        ref.child("chatCount").setValue(500)
//                    }
                    
                    print(error!.localizedDescription)
                    return
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let renewalDateString = snapshot?.value as? String {
                    if let renewalDate = dateFormatter.date(from: renewalDateString) {
                        if renewalDate < Date() {
                            ref.observeSingleEvent(of: .value, with: { (chatCountSnapshot) in
                                if let value = chatCountSnapshot.value as? [String: Any], let chatCount = value["chatCount"] as? Int {
                                    
                                    var newChatCount = chatCount+50
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    
                                    var oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: renewalDate)
                                    while oneMonthFromNow! < Date() {
                                        newChatCount += 50
                                        oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: oneMonthFromNow!)
                                    }
                                    let dateString = dateFormatter.string(from: oneMonthFromNow!)
                                    ref.child("chatCount").setValue(newChatCount)
                                    ref.child("renewalDate").setValue(dateString)
                                }
                            })
                            
                        }
                    }
                }
            }
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String: Any], let chatCount = value["chatCount"] as? Int {
                    print("Retrieved chat count from Firebase: \(chatCount)")
                }
            })
        } else {
            // If the UUID doesn't exist, generate a new UUID and store it in the keychain and in Firebase
            let uuid = UUID()
            let uuidString = uuid.uuidString
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: "com.arhanbusam.Starstruck.uuid",
                kSecAttrAccount as String: "user",
                kSecValueData as String: uuidString.data(using: .utf8)!
            ]
            
            let status = SecItemAdd(query as CFDictionary, nil)
            if status == errSecSuccess {
                print("Stored new UUID in keychain: \(uuid)")
                
                // Store the new UUID in Firebase
                let ref = Database.database().reference().child("users").child(uuidString)
                ref.child("chatCount").setValue(500)
                
                let currentDate = Date()
                let oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: oneMonthFromNow!)
                ref.child("renewalDate").setValue(dateString)
                
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? [String: Any], let chatCount = value["chatCount"] as? Int {
                        print("Retrieved chat count from Firebase: \(chatCount)")
                    }
                })
            }
        }

        
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
            defaults.set(defaults.integer(forKey: "balance")+50, forKey: "balance")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            var oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: dateFormatter.date(from: defaults.string(forKey: "renewalDate")!)!)
            while oneMonthFromNow! < Date() {
                defaults.set(defaults.integer(forKey: "balance")+50, forKey: "balance")
                oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: oneMonthFromNow!)
            }
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

