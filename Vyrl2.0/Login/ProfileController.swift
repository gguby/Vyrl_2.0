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
    @IBOutlet weak var overlabLabel: UILabel!
    
    @IBOutlet weak var checkView: UIImageView!
    
    @IBOutlet weak var signUp: UIButton!
    
    @IBOutlet weak var nickNameField: UITextField!    
    @IBOutlet weak var introField: UITextField!
    @IBOutlet weak var webURLField: UITextField!
    @IBOutlet weak var duplicationCheckButton: UIButton!
    
    var type : ProfileViewType = .SignUp
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch self.type {
        case .SignUp:
            overlabLabel.isHidden = true
        case .Modify:
            print("modify")
        }
        
        duplicationCheckButton.setTitleColor(UIColor.ivGreyish, for: .disabled)
        duplicationCheckButton.setTitleColor(UIColor.ivLighterPurple, for: .normal)
        
        signUp.isEnabled = false
        signUp.backgroundColor = UIColor.hexStringToUIColor(hex: "#ACACAC")
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
        LoginManager.sharedInstance.signUp(homePageURL: webURLField.text!, nickName: nickNameField.text!, selfIntro: introField.text!, completionHandler:  {
            response in switch response.result {
            case .success(let json):
                print((response.response?.statusCode)!)
                print(json)
                
                self.pushView(storyboardName: "Login", controllerName: "logincomplete")
                
            case .failure(let error):
                print(error)
            }
        })
    }
    
    @IBAction func checkNicname(_ sender: UIButton) {
        self.duplicationCheckButton.isEnabled = false;
        LoginManager.sharedInstance.editNickname(nickname: nickNameField.text!) { (response)
            in switch response.result {
            case .success(let json):
                print((response.response?.statusCode)!)
                print(json)
                
                if((response.response?.statusCode)! == 900)
                {
                    self.overlabLabel.isHidden = false
                } else if ((response.response?.statusCode)! == 200)
                {
                    self.checkView.isHidden = false
                    self.duplicationCheckButton.isHidden = true
                    
                    self.signUp.isEnabled = true
                    self.signUp.backgroundColor = UIColor.ivLighterPurple
                }
                
            case .failure(let error):
                print(error)
            }
            
            
            
        }
    }
    
    func showAlert() {
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.alert)
        
        let showProfileAction = UIAlertAction(title: "사진 크게 보기", style: .default,handler: { (action) -> Void in
            self.showProfileViewController()
        })
        let changeProfileAction = UIAlertAction(title: "프로필 사진 변경", style: .default, handler: { (action) -> Void in
           self.changeProfile()
        })
        let defaultProfileAction = UIAlertAction(title: "기본 이미지로 변경", style: .default, handler: nil)
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

extension ProfileController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        overlabLabel.isHidden = true
        duplicationCheckButton.isEnabled = false;
        
        signUp.isEnabled = false
        signUp.backgroundColor = UIColor.hexStringToUIColor(hex: "#ACACAC")
        
        self.checkView.isHidden = true
        self.duplicationCheckButton.isHidden = false

        
        let newLength = textField.text!.characters.count + string.characters.count - range.length;
        if(newLength > 3 && newLength < 20)
        {
            duplicationCheckButton.isEnabled = true;
        }
        
        return true

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

enum ProfileViewType {
    case SignUp, Modify
}


