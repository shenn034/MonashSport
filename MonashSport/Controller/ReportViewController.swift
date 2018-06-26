//
//  ReportViewController.swift
//  MonashSport
//
//  Created by 杨申 on 22/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//


// SwiftProgressHUD is a API from Git: stackhou/SwiftProgressHUD
// SwiftChart is a API from Git: gpbl/SwiftChart
import UIKit
import SwiftProgressHUD
import Firebase
import SwiftChart


class ReportViewController: UIViewController {
    
    
    
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var avgLabel: UILabel!
    
    
    var steps = [Double]()
    var times = [String]()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        fetchData()
        
        
        super.viewDidLoad()
        
      
    }
    
    //function to fetch all data from yesterday and draw the steps bar chart
    func fetchData(){
        SwiftProgressHUD.showWait()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let dformatter = DateFormatter()
        dformatter.dateFormat = "dd-MM-yyyy"
        dformatter.string(from: yesterday! as Date)
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        ref.child("runs").child(uid!).child(dformatter.string(from: yesterday! as Date)).observeSingleEvent(of: .value) { (snapshot) in
            var allObjects = snapshot.children.allObjects as? [DataSnapshot]
            allObjects?.forEach({ (snapshot) in
                
                if let runs = snapshot.value as? [String: AnyObject] {
                    
                    for (key, value) in runs {
          
                        
                        if key == "steps"{
                            self.steps.append(value as! Double)
                        }
                        if key == "time" {
                            let timeInterval:TimeInterval = TimeInterval(truncating: value as! NSNumber)
                            let date = NSDate(timeIntervalSince1970: timeInterval)
                            let dformatter = DateFormatter()
                            dformatter.dateFormat = "HH:mm"
                            dformatter.string(from: date as Date)
                            self.times.append(dformatter.string(from: date as Date))
                        }
                    }
                }
                
            })
            
            //assgin the required line chart data set
            let series = ChartSeries(self.steps)
            series.color = ChartColors.greenColor()
            self.chart.add(series)
            
            
            var total = 0.0
            for each in self.steps{
                total = total + each
            }
            
            //calculate the value to update the labels
            if self.steps.count != 0 {
            let avg = Int(total)/(self.steps.count)
            self.totalLabel.text = "\(Int(total))"
            self.avgLabel.text = "\(avg)"
            SwiftProgressHUD.hideAllHUD()
            }
            else{
                self.totalLabel.text = "0"
                self.avgLabel.text = "0"
                SwiftProgressHUD.hideAllHUD()
            }
        }
        
    }
    
    
    
}



