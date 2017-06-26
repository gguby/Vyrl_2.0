//
//  MyProfileViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 22..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import TOCropViewController
import Sharaku
import Alamofire
import AlamofireImage

class MyProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    
    @IBOutlet weak var photoView: UIButton!
    @IBOutlet weak var overlabLabel: UILabel!
    
    @IBOutlet weak var checkView: UIImageView!
    
    @IBOutlet weak var confirm: UIButton!
    
    @IBOutlet weak var nickNameField: UITextField!
    @IBOutlet weak var introField: UITextField!
    @IBOutlet weak var webURLField: UITextField!
    @IBOutlet weak var duplicationCheckButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getProfileData()
        
        overlabLabel.isHidden = true
        duplicationCheckButton.setTitleColor(UIColor.ivGreyish, for: .disabled)
        duplicationCheckButton.setTitleColor(UIColor.ivLighterPurple, for: .normal)
        
        confirm.backgroundColor = UIColor.ivLighterPurple
        
        photoView.layer.masksToBounds = true
        photoView.layer.cornerRadius = photoView.frame.width / 2
        photoView.layer.borderColor = UIColor.black.cgColor
        photoView.layer.borderWidth = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(sender :AnyObject )
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
        self.showAlert()
    }
    
    
    @IBAction func checkNicname(_ sender: UIButton) {
        self.duplicationCheckButton.isEnabled = false;
        LoginManager.sharedInstance.checkNickname(nickname: nickNameField.text!) { (response)
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
                    
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func changeProfile(_ sender: UIButton) {
        let profile = self.photoView.imageView?.image
        
        let parameters : Parameters = [
            "homePageUrl": webURLField.text!,
            "nickName": nickNameField.text!,
            "selfIntro": introField.text!,
            ]
        
        let uri = LoginManager.sharedInstance.baseURL + "my/profile"
        let fileName = "\(nickNameField.text!).jpg"
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let imageData = UIImageJPEGRepresentation(profile!, 1.0) {
                multipartFormData.append(imageData, withName: "profile", fileName: fileName, mimeType: "image/jpg")
            }
            
            for ( key, value ) in parameters {
                let valueStr = value as! String
                multipartFormData.append(valueStr.data(using: String.Encoding.utf8)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: uri, method: .post, headers: LoginManager.sharedInstance.getHeader(), encodingCompletion:
            {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print(progress)
                    })
                    
                    upload.responseString { response in
                        print(response.result)
                        print((response.response?.statusCode)!)
                        print(response)
                        
                        if ((response.response?.statusCode)! == 200){
                            self.navigationController?.popViewController(animated: true)                            
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError.localizedDescription)
                }
        })
    }
    
    func getProfileData() {
        let uri = LoginManager.sharedInstance.baseURL + "my/profile"
         Alamofire.request(uri, method: .get, parameters:nil, encoding: JSONEncoding.default, headers: LoginManager.sharedInstance.getHeader()).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                
                let jsonData = json as! NSDictionary
                
                self.nickNameField.text = jsonData["nickName"] as? String
                self.introField.text = jsonData["selfIntro"] as? String
                self.webURLField.text = jsonData["homepageUrl"] as? String
                
                let url = NSURL(string: jsonData["imagePath"] as! String)
                self.photoView.af_setImage(for: UIControlState.normal, url: url! as URL)
                
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
        let defaultProfileAction = UIAlertAction(title: "기본 이미지로 변경", style: .default, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: {
                
            })
        })
        
        alertController.addAction(showProfileAction)
        alertController.addAction(changeProfileAction)
        alertController.addAction(defaultProfileAction)
        
        present(alertController, animated: true, completion: {
            alertController.view.superview?.isUserInteractionEnabled = true
            alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
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

extension MyProfileViewController: SHViewControllerDelegate {
    
    func shViewControllerImageDidFilter(image: UIImage) {
        // Filtered image will be returned here.
        
        photoView.setImage(image, for: UIControlState.normal)
        
        self.dismiss(animated:true, completion: nil)
    }
    
    func shViewControllerDidCancel() {
        // This will be called when you cancel filtering the image.
    }
}

extension MyProfileViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        overlabLabel.isHidden = true
        duplicationCheckButton.isEnabled = false;
        
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
