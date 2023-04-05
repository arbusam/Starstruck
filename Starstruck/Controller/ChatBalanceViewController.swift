//
//  ChatBalanceViewController.swift
//  Starstruck
//
//  Created by Arhan Busam on 22/3/2023.
//

import UIKit
import FirebaseCore
import FirebaseDatabase

class ChatBalanceViewController: UIViewController {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var renewalDateLabel: UILabel!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // since the userdefaults returns 0 if it has not been set the balance will always be 1 lower than is saved.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.arhanbusam.Starstruck.uuid",
            kSecAttrAccount as String: "user",
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        balanceLabel.text = "Loading..."
        renewalDateLabel.text = "Loading..."

        // If the UUID exists, use it to authenticate with Firebase
        if status == errSecSuccess, let existingItem = item as? [String: Any],
           let uuidData = existingItem[kSecValueData as String] as? Data,
           let uuidString = String(data: uuidData, encoding: .utf8) {
            
            // Retrieve the user's chat count from Firebase
            let ref = Database.database().reference().child("users").child(uuidString)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? [String: Any], let chatCount = value["chatCount"] as? Int, let renewalDate = value["renewalDate"] as? String {
                    print("Retrieved chat count from Firebase: \(chatCount)")
                    self.balanceLabel.text = String(chatCount)
                    self.renewalDateLabel.text = renewalDate
                }
            })
        } else {
            print("Error retrieving chat count")
            balanceLabel.text = "Error"
        }
    }

}
