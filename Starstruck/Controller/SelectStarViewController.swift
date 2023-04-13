//
//  SelectStarViewController.swift
//  ChatStar
//
//  Created by Arhan Busam on 8/3/2023.
//

import UIKit
import FirebaseRemoteConfig
import FirebaseStorage

class SelectStarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    
    let defaultStars: [String] = [
        "Steve Jobs",
        "Elon Musk",
        "Albert Einstein",
        "J.K. Rowling",
        "Mr Beast",
        "Taylor Swift",
        "Michael Jackson",
        "Donald Trump",
        "Lebron James"
      ]
    var stars: [String] = [
        "Steve Jobs",
        "Elon Musk",
        "Albert Einstein",
        "J.K. Rowling",
        "Mr Beast",
        "Taylor Swift",
        "Michael Jackson",
        "Donald Trump",
        "Lebron James"
      ]
    
    func setupRemoteConfigDefaults() {
        let defaultValues = [
            "stars": defaultStars as NSObject
        ]
        RemoteConfig.remoteConfig().setDefaults(defaultValues)
    }
    
    private func loadStars() {
        if let starsArray = (self.remoteConfig.configValue(forKey: "stars").jsonValue as? NSArray) {
            if let starsString = starsArray as? [String] {
                stars = starsString
                if let customStars = UserDefaults.standard.array(forKey: "customStars") {
                    for customStar in customStars {
                        if customStar is String {
                            stars.append(customStar as! String)
                        }
                    }
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func fetchRemoteConfig() {
        let settings = RemoteConfigSettings()
        remoteConfig.configSettings = settings
        remoteConfig.fetch { (status, error) in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { changed, error in
                    DispatchQueue.main.async {
                        self.loadStars()
                        self.downloadImages()
                    }
                }
              } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
              }
        }
    }
    
    func downloadImages() {
        let storageRef = Storage.storage().reference()
        
        for star in stars {
            // Create a reference to the file you want to download
            let islandRef = storageRef.child("images/\(star).png")
            
            // Create local filesystem URL
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let localURL = documentsURL.appendingPathComponent("\(star).png")
            
            if UIImage(contentsOfFile: localURL.path) != nil {
                continue
            }
            
            // Download to the local filesystem
            islandRef.write(toFile: localURL) { url, error in
                if let error = error {
                    print("Error downloading: \(error)")
                }
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStars()
        setupRemoteConfigDefaults()
        fetchRemoteConfig()
        tableView.register(UINib(nibName: "StarCell", bundle: nil), forCellReuseIdentifier: "starCell")
        tableView.delegate = self
        tableView.dataSource = self

        downloadImages()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stars.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row+1 > stars.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "starCell", for: indexPath) as! StarCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "starCell", for: indexPath) as! StarCell
            return cell
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row+1 > stars.count {
            (cell as! StarCell).configure(name: "Add a new star", avatar: UIImage(systemName: "plus.circle"))
        } else {
            let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(stars[indexPath.row]).png")
            if let image = UIImage(contentsOfFile: localURL.path) {
                (cell as! StarCell).configure(name: stars[indexPath.row], avatar: image)
                return
            }
            (cell as! StarCell).configure(name: stars[indexPath.row], avatar: UIImage(named: "botSymbol"))
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row+1 > stars.count {
            addStar()
        } else{
            // Show chat
            let vc = ChatViewController()
            vc.currentBotName = stars[indexPath.row]
            vc.title = stars[indexPath.row] + " Bot"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let customStarCount = UserDefaults.standard.array(forKey: "customStars")?.count {
            if indexPath.row + 1 <= stars.count - customStarCount || indexPath.row+1 > stars.count {
                return nil
            }
        } else {
            return nil
        }
        
        let item = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            //Delete the row, the element inside of stars and remove it from the UserDefaults custom stars array
            var customStars = UserDefaults.standard.array(forKey: "customStars") as! [String]
            customStars.remove(at: indexPath.row - self.stars.count + customStars.count)
            self.stars.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            UserDefaults.standard.set(customStars, forKey: "customStars")
        }
        item.image = UIImage(systemName: "trash.fill")

        let swipeActions = UISwipeActionsConfiguration(actions: [item])
    
        return swipeActions
    }

    func addStar() {
        let alert = UIAlertController(title: "Who do you want to add?", message: "Type in the full name of who you want to add. Please ensure spelling and capitalisation are correct. Feel free to add non living things as well but make sure you use a/an before it. DO NOT add anyone or anything who is not recognisable (like your own name)", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter the name here"
            textField.keyboardType = .default
            textField.autocapitalizationType = .words
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            print(alert.textFields![0].text!)
            if alert.textFields![0].text == "" {
                return
            }
            // If the name is longer than 200 characters, don't add it
            if alert.textFields![0].text!.count > 200 {
                let alert = UIAlertController(title: "Name too long", message: "The name you entered is too long. Please enter a name that is less than 200 characters", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
                return
            }
            self.stars.append(alert.textFields![0].text!)
            self.tableView.reloadData()
            if var customStars = UserDefaults.standard.array(forKey: "customStars") as? [String] {
                customStars.append(alert.textFields![0].text!)
                UserDefaults.standard.set(customStars, forKey: "customStars")
            } else {
                UserDefaults.standard.set([alert.textFields![0].text], forKey: "customStars")
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        addStar()
    }
}
