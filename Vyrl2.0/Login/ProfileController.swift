//
//  ProfileController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 22..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class ProfileController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var photoView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismiss(sender :AnyObject )
    {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
        
        self.showAlert()
        
    }
    
    func showAlert() {
        let alertController = UIAlertController (title:"", message:"",preferredStyle:.alert)
        
        let showProfileAction = UIAlertAction(title: "Show Profile", style: .default,handler: { (action) -> Void in
            self.showProfileViewController()
        })
        let changeProfileAction = UIAlertAction(title: "Change Profile", style: .default, handler: { (action) -> Void in
           self.changeProfile()
        })
        let defaultProfileAction = UIAlertAction(title: "Default Profile", style: .default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alertController.addAction(showProfileAction)
        alertController.addAction(changeProfileAction)
        alertController.addAction(defaultProfileAction)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showProfileViewController() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfilePhotoViewController") as! ProfilePhotoViewController
    
        present(vc, animated: true, completion: nil)
    }
    
    func changeProfile() {
        if ( UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) == false ){
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){

        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        photoView.setImage(chosenImage, for: UIControlState.normal)
        photoView.layer.masksToBounds = true
        photoView.layer.cornerRadius = photoView.frame.width / 2
        photoView.layer.borderColor = UIColor.black.cgColor
        photoView.layer.borderWidth = 1.0
        
        self.dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.dismiss(animated: true, completion: nil);
    }

}
