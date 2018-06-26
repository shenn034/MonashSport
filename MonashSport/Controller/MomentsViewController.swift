//
//  MomentsViewController.swift
//  MonashSport
//
//  Created by 杨申 on 23/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//


// SwiftProgressHUD is a API from Git: stackhou/SwiftProgressHUD

import UIKit
import FirebaseDatabase
import Firebase
import SwiftProgressHUD

class MomentsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var posts = [Post]()
    var following = [String]()
    
    override func viewDidLoad() {
        //fetchPosts()
        
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        posts = [Post]()
        following = [String]()
        fetchPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //get all the posts in firebase
    func fetchPosts() {
        SwiftProgressHUD.showWait()
        
        let ref = Database.database().reference()
        // get all the users
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            for (_, value) in users {
                if let uid = value["userId"] as? String {
                    // get current user's following list
                    if uid == Auth.auth().currentUser?.uid {
                        if let followingUsers = value["following"] as? [String : String] {
                            for (_, user) in followingUsers {
                                // put users in the following list to following array
                                self.following.append(user)
                            }
                        }
                        // put current user in the following array
                        self.following.append(Auth.auth().currentUser!.uid)
                        
                        ref.child("posts").observeSingleEvent(of: .value, with: { (snapshot2) in
                            
                            if let postsSnap = snapshot2.value as? [String : AnyObject] {
                                
                                for (_, post) in postsSnap {
                                    if let uid = post["userId"] as? String {
                                        for each in self.following {
                                            if each == uid {
                                                let postt = Post()
                                                if let author = post["author"] as? String, let content = post["content"] as? String, let likes = post["likes"] as? Int, let date = post["date"] as? Int, let pathToImage = post["pathToImage"] as? String, let postId = post["postId"] as? String {
                                                    
                                                    postt.content = content
                                                    postt.author = author
                                                    postt.likes = likes
                                                    postt.pathToImage = pathToImage
                                                    postt.postId = postId
                                                    postt.userId = uid
                                                    postt.profileImage = pathToImage
                                                    postt.timeStamp = date
                                                    if let people = post["peopleWhoLike"] as? [String : AnyObject] {
                                                        for (_,person) in people {
                                                            postt.peopleWhoLike.append(person as! String)
                                                        }
                                                    }
                                                    for (_, value) in users {
                                                        if let uid = value["userId"] as? String {
                                                            if uid == each {
                                                                if let profileImage = value["profileImageUrl"] as? String {
                                                                    postt.profileImage = profileImage
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    self.posts.append(postt)
                                                    
                                                }
                                            }
                                        }
                                        
                                        self.collectionView.reloadData()
                                    }
                                }
                            }
                            else {
                                SwiftProgressHUD.hideAllHUD()
                            }
                        })
                    }
                }
            }
            
        }
        
        ref.removeAllObservers()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    //configure the values to be used in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let timeInterval:TimeInterval = TimeInterval(self.posts[indexPath.row].timeStamp)
        let date = NSDate(timeIntervalSince1970: timeInterval)
        let dformatter = DateFormatter()
        dformatter.dateFormat = "dd/MM/yyy HH:mm:ss"
        dformatter.string(from: date as Date)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        cell.unlikeButton.isHidden = true
        print(self.posts[indexPath.row].profileImage)
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        cell.profileImage.downloadImage(from: self.posts[indexPath.row].profileImage)
        cell.usernameLabel.text = self.posts[indexPath.row].author
        cell.contentLabel.text = self.posts[indexPath.row].content
        cell.likesLabel.text = "\(self.posts[indexPath.row].likes!) Likes"
        cell.dateLabel.text = dformatter.string(from: date as Date)
        cell.postId = self.posts[indexPath.row].postId
        for person in self.posts[indexPath.row].peopleWhoLike {
            if person == Auth.auth().currentUser?.uid {
                cell.likeButton.isHidden = true
                cell.unlikeButton.isHidden = false
                break
            }
        }
        SwiftProgressHUD.hideAllHUD()
        return cell
        
    }
    
    
}

