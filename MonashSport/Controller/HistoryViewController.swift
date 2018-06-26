//
//  HistoryViewController.swift
//  MonashSport
//
//  Created by 杨申 on 8/6/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//


// SwiftProgressHUD is a API from Git: stackhou/SwiftProgressHUD
import UIKit
import SwiftProgressHUD
import Firebase

class HistoryViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var runTableView: UITableView!
    var runs = [Runs]()
    var steps = [Int]()
    var miles = [Double]()
    var times = [String]()
    var images = [String]()
    var cals = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData()
    }

    @IBAction func backOnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //function to get all the running records of the current user and display them in order
    func retrieveData(){
        
            SwiftProgressHUD.showWait()
            
            let uid = Auth.auth().currentUser?.uid
            let ref = Database.database().reference()
            ref.child("runs").child(uid!).observe(.value) { (snapshot) in
                
                var allObjects = snapshot.children.allObjects as? [DataSnapshot]
                
                allObjects?.forEach({ (snapshot) in
                    var allObjs = snapshot.children.allObjects as? [DataSnapshot]
                    allObjs?.forEach({ (snapshot) in
                        print(snapshot)
                        if let runs = snapshot.value as? [String: AnyObject] {
                            
                            for (key, value) in runs {
                                if key == "steps"{
                                    
                                    self.steps.append(value as! Int)
                                }
                                if key == "time" {
                                    let timeInterval:TimeInterval = TimeInterval(truncating: value as! NSNumber)
                                    let date = NSDate(timeIntervalSince1970: timeInterval)
                                    let dformatter = DateFormatter()
                                    dformatter.dateFormat = "dd/MM/yyy HH:mm:ss"
                                    dformatter.string(from: date as Date)
                                    self.times.append(dformatter.string(from: date as Date))
                                }
                                if key == "cals" {
                                    self.cals.append(value as! Double)
                                }
                                if key == "snapshot" {
                                    self.images.append(value as! String)
                                }
                                if key == "miles" {
                                    self.miles.append(value as! Double)
                                }
                            }
                        }
                    })
                    
                    
                })
                print(self.steps)
                print(self.cals)
                print(self.miles)
                print(self.images)
                print(self.times)
                self.cals.reverse()
                self.miles.reverse()
                self.images.reverse()
                self.times.reverse()
                self.steps.reverse()
                self.runTableView.reloadData()
                SwiftProgressHUD.hideAllHUD()
            }
            
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "runCell", for: indexPath) as! HistoryCell
        cell.calLabel.text = "\(self.cals[indexPath.row])"
        cell.mileLabel.text = "\(self.miles[indexPath.row])"
        cell.stepLabel.text = "\(self.steps[indexPath.row])"
        cell.timeLabel.text = self.times[indexPath.row]
        cell.runImage.downloadImage(from: self.images[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return steps.count ?? 0
    }
    
}
