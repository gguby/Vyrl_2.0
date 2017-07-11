//
//  WriteViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 6. 1..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import MobileCoreServices
import TOCropViewController
import Sharaku

class WriteViewController : UIViewController , TOCropViewControllerDelegate{
    
    var modalNavigationController = FeedNavigationController()
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var isSelectedMedia : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerSwipe()
        
        self.tabBarItem.image = UIImage(named: "icon_write_01")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        textView.delegate = self
        textView.textColor = UIColor.ivGreyish
        
        setupKeyBoardObservers()
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        DispatchQueue.main.async {
            self.setupNavigation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupMediaView(hidden: false)
    }
    
    @IBAction func dimissPop() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        self.textView.resignFirstResponder()
    }
    
    func setupKeyBoardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setupNavigation(){
        
        let storyboard = UIStoryboard(name:"Write", bundle: nil)
        let mediaVC = storyboard.instantiateViewController(withIdentifier: "media") as! WriteMediaViewConroller
        mediaVC.delegate = self
        
        modalNavigationController = FeedNavigationController(rootViewController: mediaVC)
        navigationController?.addChildViewController(modalNavigationController)
        navigationController?.si_presentViewController(toViewController: modalNavigationController, completion: {
            
        })
    }
    
    func handleKeyboardWillShow(_ notification: Notification){
        
        let info = notification.userInfo
        let infoNSValue = info![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let kbSize = infoNSValue.cgRectValue.size
        
        ModalAnimatorPhoto.keyboardSize = kbSize
        
        self.navigationController?.si_dissmissOnBottom(toViewController: modalNavigationController, kbSize: kbSize, completion:  {
            
            self.modalNavigationController.si_delegate?.navigationControllerDidClosed?(navigationController: self.modalNavigationController)
        })
    }
    
    func handleKeyboardWillHide(_ notification: Notification){
        
        self.navigationController?.si_dismissModalView(toViewController: modalNavigationController, completion:  {
            
//            self.modalNavigationController.si_delegate?.navigationControllerDidClosed?(navigationController: self.modalNavigationController)
        })
    }
    
    func setupMediaView(hidden :Bool){
        isSelectedMedia = hidden
        ModalAnimatorPhoto.isKeyboardMode = hidden
    }
}

extension WriteViewController : WriteMdeiaDelegate, UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func showMedia(){
        textView.resignFirstResponder()
        self.navigationController?.si_showFullScreen(toViewController: modalNavigationController, completion: {
            self.modalNavigationController.si_delegate?.navigationControllerDidSpreadToEntire?(navigationController: self.modalNavigationController)
        })
    }
    
    func focusTextView() {
        textView.becomeFirstResponder()
        self.setupMediaView(hidden: true)
    }
    
    func closeKeyboard() {
        
        textView.resignFirstResponder()
        
        self.navigationController?.si_dismissModalView(toViewController: modalNavigationController, completion:  {
            
            self.modalNavigationController.si_delegate?.navigationControllerDidClosed?(navigationController: self.modalNavigationController)
        })
    }
    
    func openCameraView(){
        if ( UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == false ){
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.mediaTypes = [(kUTTypeMovie as NSString) as String]
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openPhotoView(){
        
        if ( UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == false ){
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self 
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openLocationView(){
        print("open Location")
    }
    
    func openPhotoOrVideo(_ mediaType: AVAsset.MediaType?, assetIdentifier: String?){
        self.navigationController?.si_showFullScreen(toViewController: modalNavigationController, completion: {
            self.modalNavigationController.si_delegate?.navigationControllerDidSpreadToEntire?(navigationController: self.modalNavigationController)
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        self.dismiss(animated:true, completion: nil)
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            if mediaType == "public.image"{
                let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
                
                let cropViewController = TOCropViewController(image: chosenImage)
                
                cropViewController.delegate = self
                self.present(cropViewController, animated: true, completion: nil)
                return
            }
            if mediaType == "public.movie"{
                print("movie")
            }
        }
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

extension WriteViewController: SHViewControllerDelegate {
    
    func shViewControllerImageDidFilter(image: UIImage) {
        // Filtered image will be returned here.
        
        self.dismiss(animated:true, completion: nil)
    }
    
    func shViewControllerDidCancel() {
        // This will be called when you cancel filtering the image.
    }
}


extension WriteViewController : UITextViewDelegate {
    
    func enabledPostBtn (enabled :Bool) {
        postBtn.isEnabled = enabled
        
        if (enabled){
            postBtn.titleLabel?.textColor = UIColor.ivLighterPurple
        }else {
            postBtn.titleLabel?.textColor = UIColor.ivGreyish
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if ( textView.textColor == UIColor.ivGreyish)
        {
            textView.text = ""
            enabledPostBtn(enabled: false)
            textView.textColor = UIColor(red: 62.0 / 255.0, green: 58.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "글을 입력해 주세요."
            textView.textColor = UIColor.ivGreyish
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let chracterCount = textView.text?.characters.count ?? 0
        
        if (range.length + range.location > chracterCount){
            return false
        }
        
        let textLength = chracterCount + text.characters.count - range.length
        
        enabledPostBtn(enabled: textLength > 0)

        return true
    }
}
