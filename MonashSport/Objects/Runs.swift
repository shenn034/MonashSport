//
//  Runs.swift
//  MonashSport
//
//  Created by 杨申 on 7/6/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//

import UIKit

class Runs: NSObject {
    var miles: Double!
    var cals: Double!
    var steps: Int!
    var time: Int!
    var image: String!
    
    var userSteps: Int
    
    override init() {
        userSteps = 0
    }
    
    func setSteps(step: Int){
        userSteps = step
    }
}
