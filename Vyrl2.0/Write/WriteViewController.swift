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

protocol UploadMediaCellDelegate {
    func remove(id : String)
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

extension WriteViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset : AVAsset = selectedAssetArray[indexPath.row]
        
        if asset.type == .photo {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadMediaPhotoCell", for: indexPath) as! UploadMediaPhotoCell
            cell.delegte = self
            cell.assetID = asset.identifier
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UploadMediaVideoCell", for: indexPath) as! UploadMediaVideoCell
            
            cell.delegte = self
            cell.assetID = asset.identifier
            cell.duration.text = asset.getDurationStr()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAssetArray.count
    }
}

extension WriteViewController : UploadMediaCellDelegate {
    
    func remove(id: String) {
        let index = selectedAssetArray.index(where: { $0.identifier == id})
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
    
    var assetID: String? {
        
        didSet {
            
            let manager = PHCachingImageManager()
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.resizeMode = .exact
            
            if let id = assetID {
                
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: fetchOptions)
                
                guard let asset = fetchResult.firstObject
                    else { return  }
                
                if asset.mediaType == .image {
                    
                    manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
                        
                        image,error  in
                        
                        self.image.image = image
                        
                        if error != nil {
                            
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func remove(_ sender: SmallButton) {
        delegte.remove(id: self.assetID!)
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
    
    var assetID: String? {
        
        didSet {
            
            let manager = PHCachingImageManager()
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.resizeMode = .exact
            
            if let id = assetID {
                
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: fetchOptions)
                
                guard let asset = fetchResult.firstObject
                    else { return  }
                
                if asset.mediaType == .video {
                    
                    manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
                        
                        image,error  in
                        
                        self.photo.image = image
                        
                        if error != nil {
                            
                        }
                    })
                    
                    manager.requestAVAsset(forVideo: asset, options: PHVideoRequestOptions(), resultHandler: {(avAsset, audioMix, info) -> Void in
                        if let asset = avAsset as? AVURLAsset {
                            //let videoData = NSData(contentsOf: asset.url)
                            let duration : CMTime = asset.duration
                            let durationInSecond = CMTimeGetSeconds(duration)
                            print(durationInSecond)
                            
                            if  let audioMix = audioMix {
                                audioMix.inputParameters
                            }
                            
                        }
                        
                    })
                }
            }
        }
    }
    
    @IBAction func remove(_ sender: SmallButton) {
        delegte.remove(id: self.assetID!)
    }

    @IBAction func mute(_ sender: SmallButton) {
        
    }
}
