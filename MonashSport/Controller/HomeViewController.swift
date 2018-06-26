//
//  HomeViewController.swift
//  MonashSport
//
//  Created by 杨申 on 16/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//


// SwiftProgressHUD is a API from Git: stackhou/SwiftProgressHUD
import UIKit
import FirebaseAuth
import SwiftProgressHUD
import Firebase
import UserNotifications

class HomeViewController: UIViewController {
    @IBOutlet weak var calsLabel: UILabel!
    
    @IBOutlet weak var milesLabel: UILabel!
    
    @IBOutlet weak var stepsLabel: UILabel!

    @IBOutlet weak var currentTrackLabel: UILabel!
    
    var miles: Double?
    var cals: Double?
    var steps: Int?
    var track: Double?
    var allRuns = [Runs]()
    
    override func viewDidLoad() {
        
        miles = 0.0
        cals = 0.0
        steps = 0
        calsLabel.text = "0.0"
        milesLabel.text = "0.0"
        stepsLabel.text = "0"
        fetchData()
        changeLabel()
        super.viewDidLoad()
        let content = UNMutableNotificationContent()
        content.title = "Monash Sport"
        content.body = "Your yesterday report has been updated!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "report", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func trackButtonPressed(_ sender: Any) {
    }
    
    //get current users' running records in the current day and calculate them to update the label text
    func fetchData(){
        SwiftProgressHUD.showWait()
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let now = NSDate()
        let dformatter = DateFormatter()
        dformatter.dateFormat = "dd-MM-yyyy"
        dformatter.string(from: now as Date)
        ref.child("runs").child(uid).child(dformatter.string(from: now as Date)).queryOrdered(byChild: "cals").observe(.value) { (snapshot) in
            
            if let runs = snapshot.value as? [String : AnyObject] {
                for (_, run) in runs {
                    let singleRun = Runs()
                    if let cal = run["cals"] as? Double, let mile = run["miles"] as? Double, let step = run["steps"] as? Int, let img = run["snapshot"] as? String, let time = run["time"] as? Int {
                        self.cals = self.cals! + cal
                        self.miles = self.miles! + mile
                        self.steps = self.steps! + step
                        singleRun.cals = cal
                        singleRun.miles = mile
                        singleRun.image = img
                        singleRun.steps = step
                        singleRun.time = time
                        
                        self.allRuns.append(singleRun)
                        
                    }
                }
                
                self.calsLabel.text = "\(self.cals!)"
                self.milesLabel.text = "\(self.miles!)"
                self.stepsLabel.text = "\(self.steps!)"
                SwiftProgressHUD.hideAllHUD()
            }
            else {
                
                self.milesLabel.text = "0.0"
                self.calsLabel.text = "0.0"
                self.stepsLabel.text = "0"
                SwiftProgressHUD.hideAllHUD()
            }
        }
        ref.removeAllObservers()
        
    }
    
    //function to change the label in the track area, if a new workout is saved, the label will update.
    func changeLabel() {
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let now = NSDate()
        let dformatter = DateFormatter()
        
        dformatter.dateFormat = "dd-MM-yyyy"
        dformatter.string(from: now as Date)
        ref.child("runs").child(uid).child(dformatter.string(from: now as Date)).observe(.childAdded) { (snapshot2) in
            if let newRun = snapshot2.value as? [String: AnyObject]{
                //print(newRun)
                if let time = newRun["time"] as? Int, let mile = newRun["miles"] as? Double {
                    let timeInterval:TimeInterval = TimeInterval(time)
                    let date = NSDate(timeIntervalSince1970: timeInterval)
                    let dformatter = DateFormatter()
                    dformatter.dateFormat = "HH:mm:ss"
                    dformatter.string(from: date as Date)
                    self.currentTrackLabel.text = "\(dformatter.string(from: date as Date)) You've finished \(mile) km!"
                }
            }
            else {
                self.currentTrackLabel.text = ""
            }
        }
        ref.removeAllObservers()
    }
    
}
