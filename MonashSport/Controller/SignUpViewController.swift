//
//  SignUpViewController.swift
//  MonashSport
//
//  Created by 杨申 on 22/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//


// SwiftProgressHUD is a API from Git: stackhou/SwiftProgressHUD
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftProgressHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var confirmPassLabel: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var defaultProfileImage: UIImageView!
    
    var selectedImage: UIImage?
    
    
    @IBAction func SignUpTapped(_ sender: Any) {
        guard passwordLabel.text == confirmPassLabel.text else {
            //show the progress bar
            SwiftProgressHUD.showOnlyText("Two passwords are different!")
            //dismiss the progress bar after 1 sec
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                SwiftProgressHUD.hideAllHUD()
            }
            return
        }
        // dismiss the keyboard after tapping other places
        view.endEditing(true)
        SwiftProgressHUD.showWait()
        if self.selectedImage != nil {
            //create user in firebase
            Auth.auth().createUser(withEmail: emailLabel.text!, password: passwordLabel.text!, completion:  { (user, error) in
                if let firebaseError = error {
                    SwiftProgressHUD.hideAllHUD()
                    SwiftProgressHUD.showOnlyText(firebaseError.localizedDescription)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        SwiftProgressHUD.hideAllHUD()
                    }
                    return
                    
                }
                let uid = user?.uid
                let storageRef = Storage.storage().reference(forURL: "gs://fit4039-3e313.appspot.com").child("profileIamge").child(uid!)
                if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
                    print(imageData)
                    
                    //upload the image to firebase storage
                    storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                        if error != nil{
                            SwiftProgressHUD.hideAllHUD()
                            SwiftProgressHUD.showOnlyText(error!.localizedDescription)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                SwiftProgressHUD.hideAllHUD()
                            }
                            return
                        }
                        //get the image url
                        let profileImageUrl = metadata!.downloadURL()?.absoluteString
                        self.setUserInfomation(profileImageUrl: profileImageUrl!, username: self.username.text!, email: self.emailLabel.text!, uid: uid!)
                    })
                    SwiftProgressHUD.hideAllHUD()
                    self.performSegue(withIdentifier: "signInSegue", sender: nil)
                }
                
            })
        }
        else {
            Auth.auth().createUser(withEmail: emailLabel.text!, password: passwordLabel.text!, completion:  { (user, error) in
                if let firebaseError = error {
                    SwiftProgressHUD.hideAllHUD()
                    SwiftProgressHUD.showOnlyText(firebaseError.localizedDescription)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        SwiftProgressHUD.hideAllHUD()
                    }
                    return
                    
                }
                let uid = user?.uid
                let storageRef = Storage.storage().reference(forURL: "gs://fit4039-3e313.appspot.com").child("profileIamge").child(uid!)
                if let profileImg = self.defaultProfileImage.image, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
                    print(imageData)
                    
                    storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                        if error != nil{
                            SwiftProgressHUD.hideAllHUD()
                            SwiftProgressHUD.showOnlyText(error!.localizedDescription)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                SwiftProgressHUD.hideAllHUD()
                            }
                            return
                        }
                        let profileImageUrl = metadata!.downloadURL()?.absoluteString
                        self.setUserInfomation(profileImageUrl: profileImageUrl!, username: self.username.text!, email: self.emailLabel.text!, uid: uid!)
                    })
                    SwiftProgressHUD.hideAllHUD()
                    self.performSegue(withIdentifier: "signInSegue", sender: nil)
                }
                
            })
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func SignInTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = 10
        profileImage.clipsToBounds = true
        //add tap gesture to the profile image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.handleSelectProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        username.becomeFirstResponder()
        handleTextField()
        
        // Do any additional setup after loading the view.
    }
    
    //validation method
    func handleTextField(){
        username.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        emailLabel.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordLabel.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        confirmPassLabel.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        username.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingDidBegin)
    }
    
    //method to monitor the sign up button
    @objc func textFieldDidChange(){
        guard let username = username.text, !username.isEmpty, let email = emailLabel.text, !email.isEmpty, let password = passwordLabel.text, !password.isEmpty, let confirmPassword = confirmPassLabel.text, !confirmPassword.isEmpty else {
            signUpButton.isEnabled = false
            signUpButton.alpha = 0.65
            return
        }
        signUpButton.isEnabled = true
        signUpButton.alpha = 1
    }
    
    //put user informaiton into firebase
    func setUserInfomation(profileImageUrl: String, username: String, email: String, uid: String) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference =  usersReference.child(uid)
        newUserReference.setValue(["username": username, "email": email, "profileImageUrl": profileImageUrl, "userId": uid])
    }
    
    //image picker settings
    @objc func handleSelectProfileImageView(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = image
            profileImage.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
}
