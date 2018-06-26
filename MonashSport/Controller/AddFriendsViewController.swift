//
//  AddFriendsViewController.swift
//  MonashSport
//
//  Created by 杨申 on 25/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//

import UIKit
import Firebase

class AddFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    var filteredUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        filteredUsers.removeAll()
        retrieveUsers()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search User"
        navigationItem.searchController = searchController
        searchController.searchBar.becomeFirstResponder()
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // search result updating
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(), searchText.count > 0 {
            filteredUsers.removeAll()
            for user in users {
                if user.userName == searchText {
                filteredUsers.append(user)
                }
            }
        }
        else {
            filteredUsers = users
        }
        self.tableView.reloadData()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    @IBAction func backOnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //display all the registered user in the table view
    func retrieveUsers(){
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as! [String: AnyObject]
            self.users.removeAll()
            for(_, value) in users {
                if let email = value["email"] as? String {
                    if email != Auth.auth().currentUser?.email {
                        let userToShow = User()
                        if let username = value["username"] as? String, let imagePath = value["profileImageUrl"] as? String, let userId = value["userId"] as? String {
                            userToShow.userName = username
                            userToShow.imagePath = imagePath
                            userToShow.userEmail = email
                            userToShow.userID = userId
                            self.users.append(userToShow)
                            self.filteredUsers.append(userToShow)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
        ref.removeAllObservers()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchUserCell", for: indexPath) as! SearchUserCell
        cell.nameLabel.text = self.filteredUsers[indexPath.row].userName
        cell.userImage.downloadImage(from: self.filteredUsers[indexPath.row].imagePath)
        cell.emailLabel.text = self.filteredUsers[indexPath.row].userEmail
        checkFollowing(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count ?? 0
    }
    
    //function to follow/unfollow a user by tapping the cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            if let following = snapshot.value as? [String: AnyObject] {
                for (ke, value) in following {
                    if value as! String == self.filteredUsers[indexPath.row].userID{
                        isFollower = true
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.users[indexPath.row].userID).child("followers/\(ke)").removeValue()
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            
            // Follow as user has no followers
            if !isFollower{
                let following = ["following/\(key)" : self.filteredUsers[indexPath.row].userID]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                
                ref.child("users").child(self.filteredUsers[indexPath.row].userID).updateChildValues(followers)
                
                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        }
        ref.removeAllObservers()
    }
    
    func checkFollowing(indexPath: IndexPath) {
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            if let following = snapshot.value as? [String: AnyObject] {
                for (ke, value) in following {
                    if value as! String == self.filteredUsers[indexPath.row].userID {
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        }
        ref.removeAllObservers()
    }
    
}


//function to download image using the url retrieving from firebase
extension UIImageView {
    func downloadImage(from imgUrl: String) {
        let url = URLRequest(url: URL(string: imgUrl)!)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}

