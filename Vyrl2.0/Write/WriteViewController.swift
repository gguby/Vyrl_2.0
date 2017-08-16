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
    func openCropView(vc : UIViewController)
    func replaceData(identifier : String , photo : UIImage)
}

class WriteViewController : UIViewController , TOCropViewControllerDelegate{
    
    var modalNavigationController = FeedNavigationController()
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    var isSelectedMedia : Bool = false
    var selectedAssetArray = [AVAsset]()
    var albumTitle : String!
    var currentPlace : Place!
    
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
        
        textView.resignFirstResponder()
        
        let parameters :[String:String] = [
            "content": textView.text,
            "latitude" : "\(self.currentPlace.latitude!)",
            "longitude" : "\(self.currentPlace.longitude!)"
        ]
        
        let uri = Constants.VyrlFeedURL.FEED
        
        let queryUrl = URL.init(string: uri, parameters: parameters)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.feedView.upload(query: queryUrl!, array: self.selectedAssetArray)
        
        self.dismiss(animated: true, completion: nil)
        
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
    
    func loadFirstAsset(type : PHAssetMediaType) -> AVAsset {
        
        var resultAsset : AVAsset!
        
        let manager = PHImageManager()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        
        let fetchResult = PHAsset.fetchAssets(with: type, options: fetchOptions)
   
        if (fetchResult.firstObject != nil ){
            let lastAsset : PHAsset = fetchResult.lastObject!
            
            if lastAsset.mediaType == .image {
                resultAsset = AVAsset(type: .photo, identifier: lastAsset.localIdentifier)
                
                manager.requestImage(for: lastAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
                    
                    image,error  in
                    
                    resultAsset.photo = image
                    
                    if error != nil {
                    }
                })

            }else {
                var duration: TimeInterval!
                
                duration = lastAsset.duration
                
                resultAsset = AVAsset(type: .video, identifier: lastAsset.localIdentifier)
                resultAsset.duration = duration
                
                manager.requestImage(for: lastAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
                    
                    image,error  in
                    
                    if error != nil {
                        resultAsset.photo = image
                    }
                })
                
                manager.requestAVAsset(forVideo: lastAsset, options: PHVideoRequestOptions(), resultHandler: {(avAsset, audioMix, info) -> Void in
                    if let asset = avAsset as? AVURLAsset {
                        resultAsset.urlAsset = asset
                    }
                })
            }
        }
        
        return resultAsset
        
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
        let storyboard = UIStoryboard(name:"Write", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "Location") as! LocationViewController
        controller.delegate = self
        controller.currentPlace = self.currentPlace
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func completeAddMedia(array : [AVAsset]) {
        
        self.setupMediaView(hidden: true)
        
        self.navigationController?.si_dismissModalView(toViewController: modalNavigationController, completion:  {
            
            self.modalNavigationController.si_delegate?.navigationControllerDidClosed?(navigationController: self.modalNavigationController)
            
            self.selectedAssetArray.removeAll()
            
            for asset in array {
                self.selectedAssetArray.append(asset)
            }
            
            if self.selectedAssetArray.isEmpty {
                self.collectionViewHeight.constant = 0
            } else {
                self.collectionViewHeight.constant = 146
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject)
    {
        if let _ = error {
            print("Error,Video failed to save")
        }else{
            
            let asset = self.loadFirstAsset(type: PHAssetMediaType.video)
            
            let array :[AVAsset] = [asset]
            
            self.completeAddMedia(array: array)
        }
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
                
                let theVideoURL: URL? = (info[UIImagePickerControllerMediaURL] as? URL)
                
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum((theVideoURL?.path)!))
                {
                    UISaveVideoAtPathToSavedPhotosAlbum((theVideoURL?.path)!, self, #selector(self.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                }
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
            let asset = self.loadFirstAsset(type: PHAssetMediaType.image)
            
            let array :[AVAsset] = [asset]
            
            self.completeAddMedia(array: array)
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
    
    func textViewDidChange(_ textView: UITextView){
        let h = ceil(textView.contentSize.height)
        if h != textViewHeight.constant {
            textViewHeight.constant = h
            textView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
        }
    }
}

extension WriteViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
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
    
    func openCropView(vc : UIViewController) {
       self.present(vc, animated: true, completion: nil)
    }
    
    func replaceData(identifier: String, photo: UIImage) {
        let index = selectedAssetArray.index(where: { $0.identifier == identifier})
        let asset : AVAsset = selectedAssetArray[index!]
        asset.editedData = UIImageJPEGRepresentation(photo, 1.0)!
        asset.photo = photo
        selectedAssetArray[index!] = asset
        
        self.dismiss(animated:true, completion: nil)
    }
}

class UploadMediaPhotoCell : UICollectionViewCell , TOCropViewControllerDelegate, SHViewControllerDelegate {
    
    @IBOutlet weak var image: UIImageView!
    
    var delegte : UploadMediaCellDelegate!
    
    var asset : AVAsset?
    
    @IBAction func remove(_ sender: SmallButton) {
        delegte.remove(asset: self.asset!)
    }
    
    @IBAction func editPhoto(_ sender: SmallButton) {
        
        let cropViewController = TOCropViewController(image: self.image.image!)
        cropViewController.delegate = self
        
        delegte.openCropView(vc: cropViewController)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        
        let vc = SHViewController(image: image)
        vc.delegate = self;
        cropViewController.present(vc, animated: true, completion: nil)
    }
    
    func shViewControllerImageDidFilter(image: UIImage){
        
        self.image.image = image
        delegte.replaceData(identifier: (self.asset?.identifier)!, photo: image)
    }
    
    func shViewControllerDidCancel(){
    }
}

extension WriteViewController : LocationDelegate {
    func addLocationText(place : Place) {
        self.currentPlace = place
        self.location.attributedText = place.attributeString()
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
