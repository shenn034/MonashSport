//
//  MeViewController.swift
//  MonashSport
//
//  Created by 杨申 on 25/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {

    @IBOutlet weak var friendsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //add the tap gesture to navigate the current view to the next view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MeViewController.friendsSelected))
        friendsView.addGestureRecognizer(tapGesture)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func backOnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func friendsSelected() {
        performSegue(withIdentifier: "FriendsSegue", sender: self)
    }


}
