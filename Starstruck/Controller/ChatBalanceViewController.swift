//
//  ChatBalanceViewController.swift
//  Starstruck
//
//  Created by Arhan Busam on 22/3/2023.
//

import UIKit

class ChatBalanceViewController: UIViewController {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var renewalDateLabel: UILabel!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // since the userdefaults returns 0 if it has not been set the balance will always be 1 lower than is saved.
        let balance = defaults.integer(forKey: "balance")
        balanceLabel.text = String(balance-1)
        renewalDateLabel.text = defaults.string(forKey: "renewalDate")
    }

}
