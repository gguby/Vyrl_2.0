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
        
        if ( UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) == false ){
                return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
    }

    
    @IBAction func ss(_ sender: Any) {
        
//        if ( UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) == false ){
//            return
//        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera

        imagePicker.allowsEditing = true
        
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
