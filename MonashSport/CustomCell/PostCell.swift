//
//  PostCell.swift
//  MonashSport
//
//  Created by 杨申 on 6/6/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//

import UIKit
import Firebase

class  PostCell: UICollectionViewCell {

    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var unlikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    var postId: String!
    
    
    @IBAction func likePressed(_ sender: Any) {
        print("like")
        print(self.postId)
        self.likeButton.isEnabled = false
        let ref = Database.database().reference()
        let keyToPost = ref.child("posts").childByAutoId().key
        ref.child("posts").child(self.postId).observeSingleEvent(of: .value) { (snapshot) in
            if let post = snapshot.value as? [String : AnyObject] {
                let updateLikes: [String : Any] = ["peopleWhoLike/\(keyToPost)" : Auth.auth().currentUser!.uid]
                ref.child("posts").child(self.postId).updateChildValues(updateLikes, withCompletionBlock: { (error, reff) in
                    print(error)
                    if error == nil {
                        ref.child("posts").child(self.postId).observeSingleEvent(of: .value, with: { (snapshot2) in
                            
                            if let properties = snapshot2.value as? [String : AnyObject] {
                                print(properties)
                                if let likes = properties["peopleWhoLike"] as? [String : AnyObject] {
                                    print(likes)
                                    let count = likes.count
                                    self.likesLabel.text = "\(count) Likes"
                                    
                                    let update = ["likes" : count]
                                    ref.child("posts").child(self.postId).updateChildValues(update)
                                    
                                    self.likeButton.isHidden = true
                                    self.unlikeButton.isHidden = false
                                    self.likeButton.isEnabled = true
                                }
                            }
                        })
                    }
                })
            }
        }
        ref.removeAllObservers()
    }
    
    
    @IBAction func unlikePressed(_ sender: Any) {
        print("unlike")
        self.unlikeButton.isEnabled = false
        let ref = Database.database().reference()
        ref.child("posts").child(self.postId).observeSingleEvent(of: .value) { (snapshot) in
            if let properties = snapshot.value as? [String : AnyObject] {
                if let peopleWhoLike = properties["peopleWhoLike"] as? [String : AnyObject] {
                    for (id,person) in peopleWhoLike {
                        if person as? String == Auth.auth().currentUser?.uid {
                            ref.child("posts").child(self.postId).child("peopleWhoLike").child(id).removeValue(completionBlock: { (error, reff) in
                                if error == nil {
                                    ref.child("posts").child(self.postId).observeSingleEvent(of: .value, with: { (snapshot2) in
                                        if let prop = snapshot2.value as? [String : AnyObject] {
                                            if let likes = prop["peopleWhoLike"] as? [String : AnyObject] {
                                                let count = likes.count
                                                self.likesLabel.text = "\(count) Likes"
                                                ref.child("posts").child(self.postId).updateChildValues(["likes" : count])
                                            }else {
                                                self.likesLabel.text = "0 Likes"
                                                ref.child("posts").child(self.postId).updateChildValues(["likes" : 0])
                                            }
                                        }
                                    })
                                    
                                }
                            })
                        }
                        self.likeButton.isHidden = false
                        self.unlikeButton.isHidden = true
                        self.unlikeButton.isEnabled = true
                        break
                    }
                }
            }
        }
        ref.removeAllObservers()
    }
    
    
}
