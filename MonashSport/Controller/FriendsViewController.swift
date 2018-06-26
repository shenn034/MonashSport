//
//  FriendsViewController.swift
//  MonashSport
//
//  Created by 杨申 on 25/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//

// SwiftProgressHUD is a API from Git: stackhou/SwiftProgressHUD
import UIKit
import Firebase
import SwiftProgressHUD

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    var following = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        SwiftProgressHUD.showWait()
        retrieveUsers()
        
        // Do any additional setup after loading the view.
    }
    
    //get all the users which is followed by the current user
    func retrieveUsers(){
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as! [String: AnyObject]
            self.users.removeAll()
            for(_, value) in users {
                if let uid = value["userId"] as? String {
                    // get current user's following list
                    if uid == Auth.auth().currentUser?.uid {
                        if let followingUsers = value["following"] as? [String : String] {
                            for (_, user) in followingUsers {
                                // put users in the following list to following array
                                self.following.append(user)
                            }
                        }
                    }
                }
            }
            
            for each in self.following{
                for (_, value) in users {
                    if let uid = value["userId"] as? String {
                        if uid == each {
                            let userToShow = User()
                            if let username = value["username"] as? String, let imagePath = value["profileImageUrl"] as? String, let userId = value["userId"] as? String, let email = value["email"] as? String {
                                userToShow.userName = username
                                userToShow.imagePath = imagePath
                                userToShow.userEmail = email
                                userToShow.userID = userId
                                self.users.append(userToShow)
                            }
                        }
                    }
                }
            }
            
            
            
            
            self.tableView.reloadData()
            SwiftProgressHUD.hideAllHUD()
        })
        ref.removeAllObservers()
    }
    
    @IBAction func backOnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        cell.nameLabel.text = self.users[indexPath.row].userName
        cell.userImage.downloadImage(from: self.users[indexPath.row].imagePath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count ?? 0
    }
  
    
}

