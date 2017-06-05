//
//  ProfileController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 22..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import TOCropViewController
import Sharaku


class ProfileController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate{
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var photoView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismiss(sender :AnyObject )
    {
       self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
        
        self.showAlert()
        
    }
    
    @IBAction func pushView(sender :AnyObject )
    {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "logincomplete")
        self.navigationController?.pushViewController(controller, animated: true)
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
        imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        self.dismiss(animated:true, completion: nil)

        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let cropViewController = TOCropViewController(image: chosenImage)
        
        cropViewController.delegate = self
        
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil);
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        
        let vc = SHViewController(image: image)
        vc.delegate = self;
        cropViewController.present(vc, animated: true, completion: nil)
    }
}

extension ProfileController: SHViewControllerDelegate {
    
    func shViewControllerImageDidFilter(image: UIImage) {
        // Filtered image will be returned here.
        photoView.setImage(image, for: UIControlState.normal)
        photoView.layer.masksToBounds = true
        photoView.layer.cornerRadius = photoView.frame.width / 2
        photoView.layer.borderColor = UIColor.black.cgColor
        photoView.layer.borderWidth = 1.0
        
        self.dismiss(animated:true, completion: nil)
    }
    
    func shViewControllerDidCancel() {
        // This will be called when you cancel filtering the image.
    }
}


