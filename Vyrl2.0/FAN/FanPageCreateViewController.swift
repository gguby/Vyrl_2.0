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

    @IBOutlet weak var fanClubImageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var introduceTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var noticeTextView: UITextView!
    
    @IBOutlet weak var duplicationCheckButton: UIButton!
    @IBOutlet weak var checkView: UIImageView!
    
    @IBOutlet weak var signUpFanPageButton: UIButton!
    
    @IBOutlet weak var photoButtonVIew: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameTextField.delegate = self
        // Do any additional setup after loading the view.
        duplicationCheckButton.setTitleColor(UIColor.ivGreyish, for: .disabled)
        duplicationCheckButton.setTitleColor(UIColor.ivLighterPurple, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkFanpageName(_ sender: UIButton) {
        self.duplicationCheckButton.isEnabled = false;
        
        let uri = Constants.VyrlFanAPIURL.checkFanPageName(fanPageName: self.nameTextField.text!)
        
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: URLEncoding.queryString, headers:Constants.VyrlAPIConstants.getHeader()).responseString { (response) in
            switch response.result {
            case .success(let json):
                print((response.response?.statusCode)!)
                print(json)
                
                if((response.response?.statusCode)! == Constants.VyrlResponseCode.NickNameAleadyInUse.rawValue)
                {
                    
                } else if ((response.response?.statusCode)! == 200)
                {
                    self.checkView.isHidden = false
                    self.duplicationCheckButton.isHidden = true
                    
                    self.signUpFanPageButton.isEnabled = true
                    self.signUpFanPageButton.backgroundColor = UIColor.ivLighterPurple
                }
                
            case .failure(let error):
                print(error)
            }

        }
    }
    
    @IBAction func cameraButtonClick(_ sender: UIButton) {
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

extension FanPageCreateViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        duplicationCheckButton.isEnabled = false;
        
        signUpFanPageButton.isEnabled = false
        signUpFanPageButton.backgroundColor = UIColor.hexStringToUIColor(hex: "#ACACAC")
        
        self.checkView.isHidden = true
        self.duplicationCheckButton.isHidden = false
        
        
        let newLength = textField.text!.characters.count + string.characters.count - range.length;
        if(newLength > 3 && newLength < 30)
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
        
        fanClubImageView.image = image
        
        self.dismiss(animated:true, completion: nil)
    }
    
    func shViewControllerDidCancel() {
        // This will be called when you cancel filtering the image.
    }
}

