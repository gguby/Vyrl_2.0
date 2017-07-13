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
import Photos
import Alamofire

protocol UploadMediaCellDelegate {
    func remove(asset : AVAsset)
}

class WriteViewController : UIViewController , TOCropViewControllerDelegate{
    
    var modalNavigationController = FeedNavigationController()
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    var isSelectedMedia : Bool = false
    var selectedAssetArray = [AVAsset]()
    var albumTitle : String!
    
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
        
        self.collectionViewHeight.constant = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupMediaView(hidden: false)
    }
    
    @IBAction func post(_ sender: UIButton) {
        
        let parameters :[String:String] = [
            "title": "test",
            "content": textView.text
        ]
        
        let uri = Constants.VyrlAPIURL.feedWrite
        let fileName = "1.jpg"
        
        let queryUrl = URL.init(string: uri, parameters: parameters)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for asset in self.selectedAssetArray {
                if asset.type == .photo {
                    if let imageData = asset.mediaData {
                        multipartFormData.append(imageData, withName: "image", fileName: fileName, mimeType: "image/jpg")
                    }
                } else {
                    if let imageData = asset.mediaData {
                        multipartFormData.append(imageData, withName: "video", fileName: fileName, mimeType: "image/jpg")
                    }
                }
            }
            
        }, usingThreshold: UInt64.init(), to: queryUrl!, method: .patch, headers: Constants.VyrlAPIConstants.getHeader(), encodingCompletion:
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
                        
                    }
                case .failure(let encodingError):
                    print(encodingError.localizedDescription)
                }
        })
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
        })
    }
    
    func setupMediaView(hidden :Bool){
        isSelectedMedia = hidden
        ModalAnimatorPhoto.isKeyboardMode = hidden
    }
}

extension WriteViewController : WriteMdeiaDelegate, UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func albumName(title: String) {
        self.albumTitle = title
    }
    
    func getSeletedArray() -> [AVAsset] {
        return selectedAssetArray        
    }
    
    func showFullScreen() {
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
    
    func completeAddMedia(array : [AVAsset]) {
        
        self.setupMediaView(hidden: true)
        
        selectedAssetArray.removeAll()
        
        for asset in array {
            selectedAssetArray.append(asset)
        }
        
        self.navigationController?.si_dismissModalView(toViewController: modalNavigationController, completion:  {
            
            self.modalNavigationController.si_delegate?.navigationControllerDidClosed?(navigationController: self.modalNavigationController)
            
            self.collectionView.reloadData()
            
            if self.selectedAssetArray.isEmpty {
                self.collectionViewHeight.constant = 0
            } else {
                self.collectionViewHeight.constant = 146
            }
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
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error)
        } else {
            DispatchQueue.main.async {
                self.modalNavigationController.si_delegate?.reloadAsset!()
            }
        }
    }
    
    func shViewControllerImageDidFilter(image: UIImage) {
        // Filtered image will be returned here.
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        self.dismiss(animated:true, completion: nil)
    }
    
    func shViewControllerDidCancel() {
        // This will be called when you cancel filtering the image.
    }
}


extension WriteViewController : UITextViewDelegate {
    
    func enabledPostBtn (enabled :Bool) {
        postBtn.isEnabled = enabled
        
        let titleColor = enabled ? UIColor.ivLighterPurple : UIColor.ivGreyish
        
        postBtn.setTitleColor(titleColor, for: .normal)
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

extension WriteViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset : AVAsset = selectedAssetArray[indexPath.row]
        
        if asset.type == .photo {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadMediaPhotoCell", for: indexPath) as! UploadMediaPhotoCell
            cell.delegte = self
            cell.asset = asset
            cell.image.image = asset.photo
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadMediaVideoCell", for: indexPath) as! UploadMediaVideoCell
            
            cell.delegte = self
            cell.asset = asset
            cell.duration.text = asset.getDurationStr()
            cell.photo.image = asset.photo
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAssetArray.count
    }
}

extension WriteViewController : UploadMediaCellDelegate {
    
    func remove(asset: AVAsset) {
        let index = selectedAssetArray.index(where: { $0.identifier == asset.identifier})
        selectedAssetArray.remove(at: index!)
        
        collectionView.reloadData()
        if selectedAssetArray.isEmpty {
            self.collectionViewHeight.constant = 0
        }
    }
}

class UploadMediaPhotoCell : UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    
    var delegte : UploadMediaCellDelegate!
    
    var asset : AVAsset?
    
    @IBAction func remove(_ sender: SmallButton) {
        delegte.remove(asset: self.asset!)
    }
    
    @IBAction func editPhoto(_ sender: SmallButton) {
        print("editPhoto")
    }
}

class UploadMediaVideoCell : UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var mute: SmallButton!
    @IBOutlet weak var duration: UILabel!
    
    var delegte : UploadMediaCellDelegate!
    
    var asset: AVAsset?
    
    @IBAction func remove(_ sender: SmallButton) {
        delegte.remove(asset: self.asset!)
    }

    @IBAction func mute(_ sender: SmallButton) {
        self.asset!.removeAudioFromVideo()
    }
}
