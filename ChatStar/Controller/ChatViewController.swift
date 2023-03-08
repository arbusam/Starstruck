//
//  ViewController.swift
//  ChatStar
//
//  Created by Arhan Busam on 7/3/2023.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {
    let apiManager = APIManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        apiManager.chat(with: "Steve Jobs", message: "What is your perspective on Google Pixel phones?")
    }


}

