//
//  WorkoutViewController.swift
//  MonashSport
//
//  Created by 杨申 on 19/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//


// SwiftProgressHUD is a API from Git: stackhou/SwiftProgressHUD
import UIKit
import CoreLocation
import MapKit
import CoreData
import Firebase
import SwiftProgressHUD

class WorkoutViewController: UIViewController {
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var calsLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationTextField: UILabel!
    @IBOutlet weak var calsTextField: UILabel!
    @IBOutlet weak var milesTextField: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var blackbg: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var timer: Timer?
    private var distance = 0.00
    private var weight = 60.00
    private var locationList: [CLLocation] = []
    private var pace = 0.01
    private var cals = 0.0
    private var run: Run?
    var displayDistance = 0.00
    
    
    
    
    override func viewDidLoad() {
        endButton.alpha = 0
        milesLabel.alpha = 0
        calsLabel.alpha = 0
        durationLabel.alpha = 0
        durationTextField.alpha = 0
        calsTextField.alpha = 0
        milesTextField.alpha = 0
        blackbg.alpha = 0.0
        super.viewDidLoad()
        mapView.delegate = self
        
        
        
        
    }
    
    //method to stop the timer and the location manager while the view will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //when the start workout pressed, change the view and start the timer and recording location
    @IBAction func startTapped(_ sender: Any) {
        endButton.alpha = 1
        milesLabel.alpha = 1
        calsLabel.alpha = 1
        durationLabel.alpha = 1
        durationTextField.alpha = 1
        calsTextField.alpha = 1
        milesTextField.alpha = 1
        blackbg.alpha = 0.6
        mapView.removeOverlays(mapView.overlays)
        seconds = 0
        distance = 0.00
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        startLocationUpdates()
    }
    
    //when the end button pressed, according the button pressed to do different actions
    @IBAction func endTapped(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        let alert = UIAlertController(title: "Well Done!", message: "Do you want to save this record?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.saveReord()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(action: UIAlertAction!) in self.cancelReord()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    //save the record to coredata and then upload the data to firebase
    func saveReord(){
        
        endButton.alpha = 0
        milesLabel.alpha = 0
        calsLabel.alpha = 0
        durationLabel.alpha = 0
        durationTextField.alpha = 0
        calsTextField.alpha = 0
        milesTextField.alpha = 0
        blackbg.alpha = 0
        let newRun = Run(context: CoreDataStack.context)
        newRun.distance = distance
        newRun.duration = Int16(seconds)
        newRun.timestamp = Date() as NSDate
        for location in locationList {
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp as NSDate
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRun.addToLocations(locationObject)
        }
        
        CoreDataStack.saveContext()
        run = newRun
        seconds = 0
        timer?.invalidate()
        createSnapshot()
       
    }
    
    //before upload the workout record to firebase, a snapshot of the map view overlays should be created
    func createSnapshot() {
        SwiftProgressHUD.showWait()
        let now = NSDate()
        let dformatter = DateFormatter()
        dformatter.dateFormat = "dd-MM-yyyy"
        dformatter.string(from: now as Date)
        let steps = Int(displayDistance * 1333)
        
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        UIGraphicsBeginImageContextWithOptions(mapView.frame.size, false, UIScreen.main.scale)
        mapView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //upload the data to firebase
        let storage = Storage.storage().reference(forURL: "gs://fit4039-3e313.appspot.com")
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser!.uid
        let key = ref.child("runs").child(uid).child(dformatter.string(from: now as Date)).childByAutoId().key
        let imageRef = storage.child("runs").child(uid).child(dformatter.string(from: now as Date)).child("\(key).jpg")
        let data = UIImageJPEGRepresentation(image!, 0.6)
        let uploadTask = imageRef.putData(data!, metadata: nil) { (metadata, error) in
            if error != nil {
                SwiftProgressHUD.hideAllHUD()
                SwiftProgressHUD.showOnlyText(error!.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    SwiftProgressHUD.hideAllHUD()
                    return
                }
            }
            imageRef.downloadURL(completion: { (url, error) in
                if let url = url {
                    let feed = ["userId" : uid,
                                "time" : timeStamp,
                                "cals" : self.cals,
                                "miles" : self.displayDistance,
                                "steps" : steps,
                                "snapshot" : url.absoluteString,
                                "runId" : key] as [String:Any]
                    let postFeed = ["\(key)" : feed]
                    ref.child("runs").child(uid).child(dformatter.string(from: now as Date)).updateChildValues(postFeed)
                    SwiftProgressHUD.hideAllHUD()
                    
                }
            })
        }
        uploadTask.resume()
    }
    
    
    //if the user choose to withdraw the current record, the view will change
    func cancelReord(){
        endButton.alpha = 0
        milesLabel.alpha = 0
        calsLabel.alpha = 0
        durationLabel.alpha = 0
        durationTextField.alpha = 0
        calsTextField.alpha = 0
        milesTextField.alpha = 0
        blackbg.alpha = 0
        seconds = 0
        timer?.invalidate()
    }
    
    //function to update the timer
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    //function to update the labels' text while running
    private func updateDisplay() {
        
        let formattedTime = FormatDisplay.time(seconds)
        displayDistance = Double(round((distance/1000)*100)/100)
        pace = distance/(Double(seconds))
        let index = 30/((400/pace)/60)
        cals = Double(round(((index * Double(seconds) * weight)/3600)*10)/10)
        
        
        
        milesTextField.text = "\(displayDistance)"
        durationTextField.text = "\(formattedTime)"
        calsTextField.text = "\(cals)"
    }
    
    //start recording the running data using cllocation
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        //locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }
    
   
    
    
    
    
    
    
    
}



// function to decide when to record the running according to the current accuracy and set the region to 500 meters
extension WorkoutViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = Double(newLocation.distance(from: lastLocation))
                distance = distance + delta
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                print("\(coordinates)")
                mapView.add(MKPolyline(coordinates: coordinates, count: 2))
                let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500)
                mapView.setRegion(region, animated: true)
            }
            
            locationList.append(newLocation)
        }
    }
}

// draw the lines on the map according to the running track
extension WorkoutViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        return renderer
    }
    
    
}

