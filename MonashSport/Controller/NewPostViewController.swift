//
//  NewPostViewController.swift
//  MonashSport
//
//  Created by 杨申 on 23/5/18.
//  Copyright © 2018 Shen Yang. All rights reserved.
//

// SwiftProgressHUD is a API from Git: stackhou/SwiftProgressHUD
// SwiftChart is a API from Git: gpbl/SwiftChart
import UIKit
import SwiftProgressHUD
import FirebaseStorage
import FirebaseDatabase
import Firebase


class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.becomeFirstResponder()
        shareButton.isEnabled = false
        shareButton.alpha = 0.5
        picker.delegate = self
        textView.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //automatically enable and disable the share button
    //if there is no pic chosen, the button will be disabled
    func textViewDidChange(_ textView: UITextView) {
        if photo.image != nil{
            shareButton.isEnabled = true
            shareButton.alpha = 1
        }
        else {
            shareButton.isEnabled = false
            shareButton.alpha = 0.5
        }
    }
    
    //upload the post to firebase
    @IBAction func shareTapped(_ sender: Any) {
        SwiftProgressHUD.showWait()
        let now = NSDate()
        let dformatter = DateFormatter()
        dformatter.dateFormat = "dd-MM-yyyy"
        dformatter.string(from: now as Date)
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://fit4039-3e313.appspot.com")
        let key = ref.child("posts").childByAutoId().key
        let imageRef = storage.child("posts").child(uid).child("\(key).jpg")
        let data = UIImageJPEGRepresentation(self.photo.image!, 0.6)
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
                                "author" : Auth.auth().currentUser!.email!,
                                "content" : self.textView.text,
                                "pathToImage" : url.absoluteString,
                                "likes" : 0,
                                "date" : timeStamp,
                                "postId" : key] as [String:Any]
                    let postFeed = ["\(key)" : feed]
                    ref.child("posts").updateChildValues(postFeed)
                    SwiftProgressHUD.hideAllHUD()
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        
        uploadTask.resume()
        
        
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //dismiss the view if the cancel button is tapped
    @IBAction func cancelPostTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //let user to choose a pic from either camera or gallery
    @IBAction func postTapped(_ sender: Any) {
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
    
    func openGallary()
    {
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.photo.image = image
            shareButton.isEnabled = true
            shareButton.alpha = 1
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}


