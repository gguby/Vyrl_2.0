//
//  WriteViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 6. 1..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation

class WriteViewController : UIViewController {
    
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
            
            self.modalNavigationController.si_delegate?.navigationControllerDidClosed?(navigationController: self.modalNavigationController)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "Write") {
            let vc = segue.destination as! WriteViewController
            present(vc, animated: true, completion: nil)
        }
    }
    
    func setupMediaView(hidden :Bool){
        isSelectedMedia = hidden
        ModalAnimatorPhoto.isKeyboardMode = hidden
    }
    
}

extension WriteViewController : WriteMdeiaDelegate {
    
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
        print("open Camera")
    }
    
    func openPhotoView(){
        print("open Photo")
    }
    
    func openLocationView(){
        print("open Location")
    }
    
    func openPhotoOrVideo(_ mediaType: AVAsset.MediaType?, assetIdentifier: String?){
        
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
