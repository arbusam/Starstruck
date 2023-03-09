//
//  SelectStarViewController.swift
//  ChatStar
//
//  Created by Arhan Busam on 8/3/2023.
//

import UIKit

class SelectStarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "selectStarCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectStarCell", for: indexPath)
        cell.textLabel?.text = "Steve Jobs"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Show chat
        let vc = ChatViewController()
        vc.title = "Steve Jobs"
        navigationController?.pushViewController(vc, animated: true)
    }
}
