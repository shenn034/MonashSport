//
//  Post.swift
//  MonashSport
//
//  Created by 杨申 on 23/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//

import Foundation
class Post: NSObject {
    var author: String!
    var content: String!
    var likes: Int!
    var pathToImage: String!
    var postId: String!
    var userId: String!
    var profileImage: String!
    var timeStamp: Int!
    
    var peopleWhoLike: [String] = [String]()
}

