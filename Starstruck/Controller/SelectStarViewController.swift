//
//  SelectStarViewController.swift
//  ChatStar
//
//  Created by Arhan Busam on 8/3/2023.
//

import UIKit

class SelectStarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var stars: [String] = ["Steve Jobs", "Bill Gates", "Larry Page", "Elon Musk", "Sir Isaac Newton", "Albert Einstein", "Henry Ford", "J.K. Rowling", "Stephen King", "J. R. R. Tolkien"]
    
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
        vc.title = stars[indexPath.row] + " Bot"
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func addButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Who do you want to add?", message: "Type in the full name of who you want to add. Please ensure spelling and capitalisation are correct. Feel free to add non living things as well but make sure you use a/an before it. DO NOT add anyone or anything who is not recognisable (like your own name)", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter the name here"
            textField.keyboardType = .default
            textField.autocapitalizationType = .words
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            print(alert.textFields![0].text!)
            self.stars.append(alert.textFields![0].text!)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}
