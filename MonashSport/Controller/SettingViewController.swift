//
//  SettingViewController.swift
//  MonashSport
//
//  Created by 杨申 on 23/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//


// SwiftProgressHUD is a API from Git: stackhou/SwiftProgressHUD
import UIKit
import FirebaseAuth
import Firebase
import SwiftProgressHUD

class SettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var profilePhoto: UIImageView!
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        SwiftProgressHUD.showWait()
        loadPhoto()
    }
    
    //dismiss the page while the back button pressed
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //while the change photo button is pressed, an alert will appear to let user choose
    @IBAction func changePhoto(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //open the camera if the user choose to take a photo from camera
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //open the gallary if the user choose to take a photo from gallery
    func openGallary()
    {
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    //function to set image pikcer
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profilePhoto.image = image
        }
        self.dismiss(animated: true, completion: nil)
        upload()
    }
    
    //logout current user if the user pressed the logout button
    @IBAction func logoutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logoutSegue", sender: nil)
        } catch (let error) {
            print ("\(error)")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //load the profile photo for the current user
    func loadPhoto(){
        
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        ref.child("users").child(uid).child("profileImageUrl").observeSingleEvent(of: .value) { (snapshot) in
            
            
            self.profilePhoto.downloadImage(from: "\(snapshot.value!)")
            SwiftProgressHUD.hideAllHUD()
            
        }
    }
    
    //update the new profile photo to firebase
    func upload(){
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        let storageRef = Storage.storage().reference(forURL: "gs://fit4039-3e313.appspot.com").child("profileIamge").child(uid)
        let data = UIImageJPEGRepresentation(self.profilePhoto.image!, 0.6)
        print("this is data")
        print(data!)
        let uploadTask = storageRef.putData(data!, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
        
        storageRef.downloadURL(completion: { (url, error) in
            if let url = url {
                let profile = url.absoluteString
                print("this is url")
                print(profile)
                ref.child("users").child(uid).updateChildValues(["profileImageUrl": profile])
                
            }
        })
        }
        
        uploadTask.resume()
        
    }
    
    
}
