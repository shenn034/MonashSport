//
//  ViewController.swift
//  MonashSport
//
//  Created by 杨申 on 8/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//


// SwiftProgressHUD is a API from Git: stackhou/SwiftProgressHUD
import UIKit
import FirebaseDatabase
import FirebaseAuth
import SwiftProgressHUD
import UserNotifications

class ViewController: UIViewController {
    
   

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var creatAccountLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    
    //function to show validation messages and login
    @IBAction func login(_ sender: Any) {
        view.endEditing(true)
        SwiftProgressHUD.showWait()
        if let email = emailField.text, let password = passwordField.text{
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let firebaseError = error {
                    SwiftProgressHUD.hideAllHUD()
                    SwiftProgressHUD.showOnlyText(firebaseError.localizedDescription)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        SwiftProgressHUD.hideAllHUD()
                    }
                    return
                }
                SwiftProgressHUD.hideAllHUD()
                SwiftProgressHUD.showSuccess("Success")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        SwiftProgressHUD.hideAllHUD()
                    }
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }
    }
    
    
    
    
    

    override func viewDidLoad() {
        
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }
        emailField.text = "test2@gmail.com"
        passwordField.text = "aaaaaa"
        emailField.layer.cornerRadius = 5
        passwordField.layer.cornerRadius = 5
        
        self.view.backgroundColor = UIColor.white
        super.viewDidLoad()
        emailField.becomeFirstResponder()
        handleTextField()
        
        let content = UNMutableNotificationContent()
        content.title = "Monash Sport"
        content.body = "Time to do a workout!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "home", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        
    }
    
    //function to hide the virtual keyboard while user tap other area of the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    //add the listener to validate the input fields, if the fields are empty then disable the login button
    func handleTextField(){
        emailField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        emailField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingDidBegin)
    }
    
    @objc func textFieldDidChange(){
        guard let email = emailField.text, !email.isEmpty, let password = passwordField.text, !password.isEmpty else {
            signInButton.isEnabled = false
            signInButton.alpha = 0.65
            return
        }
        signInButton.isEnabled = true
        signInButton.alpha = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    


}

