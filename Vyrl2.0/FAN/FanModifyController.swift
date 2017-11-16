//
//  FanModifyController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 9. 1..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import Alamofire
import TOCropViewController
import Sharaku

class FanModifyController : UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageEditBtn: UIButton!
    
    @IBOutlet weak var fanPageNameTextField: UITextField!
    @IBOutlet weak var introTextField: UITextField!
    @IBOutlet weak var checkOn: UIImageView!
    @IBOutlet weak var duplicateBtn: UIButton!
    @IBOutlet weak var linkTextField: UITextField!
    
    @IBOutlet weak var completeBtn: UIButton!
    
    var fanPage : FanPage!
    var fanPageView : FanPageController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadFan()
        
        self.fanPageNameTextField.addTarget(self, action: #selector(textFieldInputDidChange(sender:)), for: .editingChanged)
        self.imageEditBtn.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
        self.completeBtn.addTarget(self, action: #selector(modifyFanPage), for: .touchUpInside)
    }
    
    func modifyFanPage(){
        let profile = self.imageView.image
        
        var keepStr = "KEEP"
        if self.imageView.tag == 1 {
            keepStr = "PATCH"
        }else if self.imageView.tag == 2 {
            keepStr = "DELETE"
        }
        
        var parameters : Parameters = [
            "pageName": fanPageNameTextField.text!,
            "fileStatus" : keepStr,
            "randomImage" : "\(randomImage)"
        ]
        
        if let text = introTextField.text {
            if text.isEmpty == false {
                parameters["pageInfo"] = text
            }
        }
        
        if let text = linkTextField.text{
            if text.isEmpty == false {
                parameters["link"] = text
            }
        }
            
        let fileName = "1.jpg"
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let imageData = UIImageJPEGRepresentation(profile!, 1.0) {
                multipartFormData.append(imageData, withName: "profileImagefile", fileName: fileName, mimeType: "image/jpg")
            }
            
        }, usingThreshold: UInt64.init(), to: URL(string: Constants.VyrlFanAPIURL.fanPage(fanPageId: self.fanPage.fanPageId), parameters: parameters as! [String : String])!, method: .patch, headers: Constants.VyrlAPIConstants.getHeader(), encodingCompletion:
            {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        
                    })
                    
                    upload.responseString { response in
                        
                        if ((response.response?.statusCode)! == 200){
                            
                            self.fanPageView.reloadFanPage()
                            self.navigationController!.popViewController(animated: true)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError.localizedDescription)
                }
        })
    }
    
    func showProfileViewController() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfilePhotoViewController") as! ProfilePhotoViewController
        vc.image = self.imageView.image
        
        present(vc, animated: true, completion: nil)
    }
    
    var randomImage = 0
    
    func showAlert() {
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.alert)
        
        let showProfileAction = UIAlertAction(title: "사진 크게 보기", style: .default,handler: { (action) -> Void in
            self.showProfileViewController()
        })
        let changeProfileAction = UIAlertAction(title: "프로필 사진 변경", style: .default, handler: { (action) -> Void in
            self.changeProfile()
        })
        let defaultProfileAction = UIAlertAction(title: "기본 이미지로 변경", style: .default, handler: { (action) -> Void in
            
            let diceRoll = Int(arc4random_uniform(3)+1)
            self.randomImage = diceRoll
            let str = "img_fanbg_default_0\(diceRoll)"
            
            self.imageView.image = UIImage.init(named: str)
            self.imageView.tag = 2
            
            self.completeBtn.isEnabled = true
            self.completeBtn.backgroundColor = UIColor.ivLighterPurple
            
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
    
    func changeProfile() {
        if ( UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) == false ){
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func loadFan(){
        self.fanPageNameTextField.text = self.fanPage.pageName
        self.introTextField.text = self.fanPage.pageInfo
        self.linkTextField.text = self.fanPage.link
        
        if self.fanPage.randomImage > 0 {
            let str = "img_fanbg_default_0\(self.fanPage.randomImage!)"
            self.imageView.image = UIImage.init(named: str)
        }else {
            self.imageView.af_setImage(withURL: URL.init(string: self.fanPage.pageprofileImagePath)!)
        }
        
        fanPageNameTextField.delegate = self
        introTextField.delegate = self
        linkTextField.delegate = self
        
        self.duplicateBtn.isEnabled = false
        self.completeBtn.isEnabled = false
        
        self.duplicateBtn.addTarget(self, action: #selector(duplicateCheck(sender:)), for: .touchUpInside)
        self.introTextField.addTarget(self, action: #selector(duplicateCheck(sender:)), for: .touchUpInside)
        self.linkTextField.addTarget(self, action: #selector(duplicateCheck(sender:)), for: .touchUpInside)
    }
    
    func duplicateCheck(sender : UIButton){
        
        let uri = Constants.VyrlFanAPIURL.checkFanPageName(fanPageName:fanPageNameTextField.text!.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: URLEncoding.queryString, headers:Constants.VyrlAPIConstants.getHeader()).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                
                let jsonData = json as! NSDictionary
                
                let isExistFanpage = jsonData["exist"] as! Bool
                
                if isExistFanpage == false {
                    
                    self.duplicateBtn.isHidden = true
                    self.checkOn.isHidden  = false
                    self.fanPageNameTextField.resignFirstResponder()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func textFieldInputDidChange(sender : UITextField){
        
        if sender == self.fanPageNameTextField {
            if fanPage.pageName != sender.text {
                self.duplicateBtn.isEnabled = true
            }else {
                self.duplicateBtn.isEnabled = false
            }
        }
        
        if self.fanPageNameTextField.text == fanPage.pageName && introTextField.text == fanPage.pageInfo && linkTextField.text == fanPage.link {
            self.completeBtn.isEnabled = false
            self.completeBtn.backgroundColor = UIColor.hexStringToUIColor(hex: "#ACACAC")
        } else {
            self.completeBtn.isEnabled = true
            self.completeBtn.backgroundColor = UIColor.ivLighterPurple
        }
    }
}

extension FanModifyController : UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate, SHViewControllerDelegate {
    
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
    
    func shViewControllerImageDidFilter(image: UIImage) {
        // Filtered image will be returned here.
        
        imageView.image =  image
        imageView.tag = 1
        
        self.dismiss(animated:true, completion: nil)
        
        self.completeBtn.isEnabled = true
        self.completeBtn.backgroundColor = UIColor.ivLighterPurple
    }
    
    func shViewControllerDidCancel() {
        // This will be called when you cancel filtering the image.
    }

}

extension FanModifyController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == linkTextField || textField == introTextField {
            return true
        }
        
        self.duplicateBtn.isHidden = false
        self.checkOn.isHidden  = true
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
