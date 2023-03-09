//
//  SelectStarViewController.swift
//  ChatStar
//
//  Created by Arhan Busam on 8/3/2023.
//

import UIKit

class SelectStarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let stars: [String] = ["Steve Jobs", "Bill Gates", "Larry Page", "Elon Musk", "Sir Isaac Newton", "Albert Einstein", "Henry Ford", "J.K. Rowling", "Stephen King", "J. R. R. Tolkien"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "selectStarCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectStarCell", for: indexPath)
        cell.textLabel?.text = stars[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Show chat
        let vc = ChatViewController()
        vc.currentBotName = stars[indexPath.row]
        vc.title = stars[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
