//
//  FanPageCreateViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 8. 4..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import TOCropViewController
import Sharaku
import Alamofire
import AlamofireImage

class FanPageCreateViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {

    @IBOutlet weak var fanClubImageButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var introduceTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var noticeTextView: UITextView!
    
    @IBOutlet weak var duplicationCheckButton: UIButton!
    @IBOutlet weak var signUpFanPageButton: UIButton!
    
    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var checkBox: CheckBox!
    
    @IBOutlet weak var iconCheck: UIImageView!
    
    var randomImageCount = 0
    var delegate : FanViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameTextField.delegate = self
        self.introduceTextField.delegate = self
        self.linkTextField.delegate = self
        
        // Do any additional setup after loading the view.
        duplicationCheckButton.setTitleColor(UIColor.ivGreyish, for: .disabled)
        duplicationCheckButton.setTitleColor(UIColor.ivLighterPurple, for: .normal)
        duplicationCheckButton.isEnabled = false        
        
        self.checkBox.delegate = self
        self.checkBox.label = self.agreeLabel
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(self.tap(sender:)))
        view.addGestureRecognizer(tapGestureReconizer)
    }

    func tap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    func keyboardWillShow(notification : NSNotification){
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification : NSNotification){
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkFanpageName(_ sender: UIButton) {
        self.duplicationCheckButton.isEnabled = false;
        
        let uri = Constants.VyrlFanAPIURL.checkFanPageName(fanPageName:nameTextField.text!.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: URLEncoding.queryString, headers:Constants.VyrlAPIConstants.getHeader()).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                
                let jsonData = json as! NSDictionary
                
                let isExistFanpage = jsonData["exist"] as! Bool
                
                if isExistFanpage == false {
                    
                    self.duplicationCheckButton.isHidden = true
                    self.iconCheck.isHidden  = false
                    self.nameTextField.resignFirstResponder()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func createFanPage(_ sender: UIButton) {
        let uri = Constants.VyrlFanAPIURL.FANPAGE
        
        let parameters : [String:String] = [
            "pageName": nameTextField.text!,
            "pageInfo" : introduceTextField.text!,
            "link" : linkTextField.text!,
            "randomImage" : "\(randomImageCount)"
        ]

        let fileName = "\(nameTextField.text!).jpg"
        
        let image = self.fanClubImageButton.image(for: .normal)
        
        self.showLoading(show: true)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let imageData = UIImageJPEGRepresentation(image!, 1.0) {
                if self.randomImageCount == 0 {
                    multipartFormData.append(imageData, withName: "profileImagefile", fileName: fileName, mimeType: "image/jpg")
                }
            }
    
        }, usingThreshold: UInt64.init(), to:URL.init(string: uri, parameters: parameters)!, method: .post, headers: Constants.VyrlAPIConstants.getHeader(), encodingCompletion:
            {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                    })
                    
                    upload.responseString { response in
                        if ((response.response?.statusCode)! == 200){
                            self.showLoading(show: false)
                            self.navigationController?.popViewController(animated: true)
                            self.delegate.refresh()
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError.localizedDescription)
                    self.showLoading(show: false)
                }
        })
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
            
            let diceRoll = Int(arc4random_uniform(3)+1)
            self.randomImageCount = diceRoll
            let str = "img_fanbg_default_0\(diceRoll)"
            
            self.fanClubImageButton.setImage( UIImage.init(named: str), for: .normal)
            
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

    
    @IBAction func cameraButtonClick(_ sender: UIButton) {
         self.showAlert()
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

extension FanPageCreateViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField == self.introduceTextField || textField == self.linkTextField )
        {
            return true
        }
        
        self.duplicationCheckButton.isHidden = false
        self.duplicationCheckButton.isEnabled = false
        self.iconCheck.isHidden = true
        
        let newLength = textField.text!.characters.count + string.characters.count - range.length;
        if(newLength > 1 && newLength < 50)
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

extension FanPageCreateViewController: SHViewControllerDelegate {
    
    func shViewControllerImageDidFilter(image: UIImage) {
        // Filtered image will be returned here.
        
        self.randomImageCount = 0
        fanClubImageButton.setImage(image, for: .normal)
        
        self.dismiss(animated:true, completion: nil)
    }
    
    func shViewControllerDidCancel() {
        // This will be called when you cancel filtering the image.
    }
}

extension FanPageCreateViewController : checkBoxDelegate {
    func respondCheckBox(checkBox: CheckBox) {
        if checkBox.isChecked && self.nameTextField.text?.isEmpty == false {
            self.signUpFanPageButton.isEnabled = true
            self.signUpFanPageButton.backgroundColor = UIColor.ivLighterPurple
        } else {
            signUpFanPageButton.isEnabled = false
            signUpFanPageButton.backgroundColor = UIColor.hexStringToUIColor(hex: "#ACACAC")
        }
    }
}

