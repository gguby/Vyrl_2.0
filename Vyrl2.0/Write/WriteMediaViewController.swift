//
//  WriteMediaViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 7. 6..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import Photos

protocol WriteMdeiaDelegate : class {
    func openCameraView()
    func openPhotoView()
    func openLocationView()
    func closeKeyboard()
    func focusTextView()
    func showFullScreen()
    func completeAddMedia(array : [AVAsset])
    func getSeletedArray() -> [AVAsset]
    func albumName(title:String)
}

class WriteMediaViewConroller : UIViewController {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var mediaTable: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var upDownToggle: SmallButton!
    @IBOutlet weak var mediaTitle: UILabel!
    
    var avAssetIdentifiers = [String]()
    var mediaArray = [PHAssetCollection]()

    var selectedAssetArray = [AVAsset]()
    
    weak var delegate : WriteMdeiaDelegate?
    
    var currentSubType : PHAssetCollectionSubtype!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleView.alpha = 0
        
        self.view.backgroundColor = .white
        
        if let nc = self.navigationController as? FeedNavigationController {
            nc.si_delegate = self
            nc.fullScreenSwipeUp = true
            nc.isNavigationBarHidden = true
        }

        
        if PhotoAutorizationStatusCheck() {
            self.getAllAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if ( status == PHAuthorizationStatus.authorized ){
                    
                    DispatchQueue.main.async{
                        self.getAllAlbum()
                    }                    
                }
            })
        }
        
        self.enabledAddBtn(enabled: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if PhotoAutorizationStatusCheck() {
            self.getPhotosAndVideos(self.currentSubType)
        }
    }
    
    func enabledAddBtn(enabled : Bool){
        self.addBtn.isEnabled = enabled
        
        if enabled {
            self.addBtn.setTitleColor(UIColor.ivLighterPurple, for: .normal)
        }else {
            self.addBtn.setTitleColor(UIColor.ivGreyish, for: .normal)
        }
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        
        selectedAssetArray.removeAll()
        
        DispatchQueue.main.async {
            self.parent?.navigationController?.si_dismissModalView(toViewController: self.parent!, completion: {
                if let nc = self.navigationController as? FeedNavigationController {
                    nc.si_delegate?.navigationControllerDidClosed?(navigationController: nc)
                }
                
                if self.mediaTable.isHidden == false {
                    self.toggle()
                }
            })
        }
    }
    
    @IBAction func openMap(_ sender: UIButton) {
        delegate?.openLocationView()
    }
    
    @IBAction func showMedia(_ sender: UIButton) {
        
        selectedAssetArray.removeAll()
        
        let selectedArray = delegate?.getSeletedArray()
        
        for asset in selectedArray! {
            selectedAssetArray.append(asset)
        }
        
        self.enabledAddBtn(enabled: !selectedAssetArray.isEmpty)
        
        collectionView.reloadData()
        
        delegate?.showFullScreen()
    }
    
    @IBAction func focusKeyboard(_ sender : UIButton ){
        delegate?.focusTextView()
    }
    
    @IBAction func closeKeyboard(_ sender: UIButton) {
        delegate?.closeKeyboard()
    }
    
    @IBAction func addMedia(_ sender: SmallButton) {
        
        delegate?.completeAddMedia(array: selectedAssetArray)
        
        DispatchQueue.main.async {
            self.selectedAssetArray.removeAll()
            self.collectionView.reloadData()
        }
    }
    
    func toggle(){
        self.mediaTable.isHidden = !self.mediaTable.isHidden
        
        if self.mediaTable.isHidden {
            upDownToggle.setImage(UIImage.init(named: "btn_select_down_02"), for: .normal)
            self.enabledAddBtn(enabled: selectedAssetArray.count > 0)
        }else {
            upDownToggle.setImage(UIImage.init(named: "btn_select_up_01"), for: .normal)
            self.enabledAddBtn(enabled: false)
        }
    }
    
    @IBAction func showUpPhotoTable(_ sender: SmallButton) {
        self.toggle()
    }
    
    func getAllAlbum(){
        
        mediaArray.removeAll()
        
        let fetchOptions = PHFetchOptions()
        
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: fetchOptions)
        
        var cameraRollAsset : PHAssetCollection!
        
        fetchResult.enumerateObjects({ (collection, start, stop) in
            
            if collection.estimatedAssetCount != 0 {
                let count : Int = collection.photosCount
                
                let videoCount : Int = collection.videoCount

                if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    cameraRollAsset = collection
                }
   
                if (count > 0 || videoCount > 0){
                    if collection.assetCollectionSubtype.rawValue != 1000000201 {
                        self.mediaArray.append(collection)
                    }
                }
            }
        })

        let title = cameraRollAsset.localizedTitle

        self.mediaTitle.text = title
        delegate?.albumName(title: title!)
        
        self.getPhotosAndVideos(cameraRollAsset.assetCollectionSubtype)
        mediaTable.tableFooterView = UIView(frame: .zero)
    }
    
    func getPhotosAndVideos(_ subType: PHAssetCollectionSubtype){
        
        self.currentSubType = subType
        
        self.avAssetIdentifiers.removeAll()
        self.selectedAssetArray.removeAll()
        
        let fetchOptions = PHFetchOptions()
        
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subType, options: fetchOptions)
        
        fetchResult.enumerateObjects({ (collection, start, stop) in
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            assets.enumerateObjects({ (object, count, stop) in
                
                self.avAssetIdentifiers.append(object.localIdentifier)
                
                DispatchQueue.main.async {
                    //reload collectionView
                    self.collectionView.reloadData()
                    
                    if self.avAssetIdentifiers.count == 0 {
                      
                    }
                }
            })
            
            if self.avAssetIdentifiers.count == 0 {
                
            }
        })
    }
}

extension WriteMediaViewConroller : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if ( indexPath.row < 2 )
        {
            if ModalAnimatorPhoto.isShowFullScreen == false {
                
                delegate?.showFullScreen()

                return
            }
            
            let cell = collectionView.cellForItem(at: indexPath) as! MediaButtonCell
            
            if ( cell.tag == 0)
            {
                delegate?.openPhotoView()
            } else {
                delegate?.openCameraView()
            }
            
        }else {
            let cell = collectionView.cellForItem(at: indexPath) as! MediaPhotoCell
            
            cell.isChecked = !cell.isChecked

            if cell.isChecked {
                if selectedAssetArray.contains(where: { $0.identifier == cell.assetID}) == false {
                    selectedAssetArray.append(cell.asset!)
                }
            }else {
                if let index = selectedAssetArray.index(where: { $0.identifier == cell.assetID}){
                    selectedAssetArray.remove(at: index)
                }
            }
            
            self.enabledAddBtn(enabled: !selectedAssetArray.isEmpty )
            
            delegate?.showFullScreen()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if ( indexPath.row < 2 ){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MediaButtonCell
            
            if (indexPath.row == 0){
                cell.btnImg.image = UIImage(named: "icon_camera_01")
                cell.label.text = "사진 촬영"
            } else {
                cell.btnImg.image = UIImage(named: "icon_video_01")
                cell.label.text = "동영상 촬영"
            }
            
            cell.tag = (indexPath as NSIndexPath).row
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as! MediaPhotoCell
        
        cell.assetID = self.avAssetIdentifiers[indexPath.row - 2]
        cell.tag = (indexPath as NSIndexPath).row
        
        if selectedAssetArray.contains(where: { $0.identifier == cell.assetID}){
            cell.isChecked = true
        }else {
            cell.isChecked = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avAssetIdentifiers.count + 2
    }
}

extension WriteMediaViewConroller: FeedNavigationControllerDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    // MARK: - FeedNavigationControllerDelegate
    func navigationControllerDidSpreadToEntire(navigationController: UINavigationController) {
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        
                        self.titleView.alpha = 1
                        
        }, completion: nil)
    }
    
    func navigationControllerDidClosed(navigationController: UINavigationController) {

        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        
                        self.titleView.alpha = 0
                        
        }, completion: nil)
    }
    
    func reloadAsset() {
        self.getPhotosAndVideos(self.currentSubType)
    }
}

class MediaButtonCell : UICollectionViewCell {
    @IBOutlet weak var btnImg: UIImageView!
    @IBOutlet weak var label: UILabel!
}

class MediaPhotoCell : UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    var asset: AVAsset?
    
    let checkedImage = UIImage(named: "icon_check_06_on")! as UIImage
    
    @IBOutlet weak var checkView: UIImageView!
    @IBOutlet weak var unCheckView: UIView!   
    
    var isChecked: Bool = false {
        didSet{
            checkView.isHidden = !isChecked
            unCheckView.isHidden = isChecked
        }
    }
    
    var assetID: String? {
        
        didSet {
            
            let manager = PHImageManager()
            
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
                    
                    self.asset = AVAsset(type: .photo, identifier: id)
                    
                    manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
                        
                        image,error  in
                        
                        self.photo.image = image
                        self.asset?.photo = image
                        
                        if error != nil {
                        }
                    })
                }
                
                if asset.mediaType == .video {
                    
                    var duration: TimeInterval!
                    
                    duration = asset.duration
                    
                    self.asset = AVAsset(type: .video, identifier: id)
                    self.asset?.duration = duration
                    
                    manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
                        
                        image,error  in
                        
                        if error != nil {
                            
                            self.photo.image = image
                            self.asset?.photo = image
                        }
                    })
                    
                    manager.requestAVAsset(forVideo: asset, options: PHVideoRequestOptions(), resultHandler: {(avAsset, audioMix, info) -> Void in
                        if let asset = avAsset as? AVURLAsset {
      
                            self.asset?.urlAsset = asset
                        }
                    })

                }
            }
        }
    }
}

class AVAsset {
    
    enum MediaType: Int {
        case video
        case photo
    }
    
    var type: MediaType?
    var identifier: String?
    var duration :TimeInterval!
    
    var isMute : Bool = false
    
    var photo : UIImage?
    
    var editedData : Data?
    
    var mediaData : Data? {

        get {
            guard type == .photo else {
                if let asset = urlAsset {
                    do {
                        let data : Data!
                        
                        if isMute {
                            data = try Data(contentsOf: self.savedMuteFileURL)
                        }
                        else {
                            data = try Data(contentsOf: asset.url)
                        }
                       
                        return data
                    } catch {
                        
                    }
                    
                }
                return nil
            }
            
            if let data = self.editedData {
                return data
            }
            
            if let image = photo {
                return UIImageJPEGRepresentation(image, 1.0)!
            }
            
            return nil
        }
    }
    
    func removeAudioFromVideo(){
        
        let composition = AVMutableComposition()
        let sourceAsset = self.urlAsset!
        let compositionVideoTrack: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let sourceVideoTrack: AVAssetTrack? = sourceAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        let x: CMTimeRange = CMTimeRangeMake(kCMTimeZero, sourceAsset.duration)
        _ = try? compositionVideoTrack!.insertTimeRange(x, of: sourceVideoTrack!, at: kCMTimeZero)
        
        if FileManager.default.fileExists(atPath: self.savedMuteFileURL.path) {
            return
        }
        
        let url = urlAsset!.url
        
        let urlStr =  ( url.absoluteString as NSString ).lastPathComponent
        let fileURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(urlStr)
        
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = fileURL
        exporter?.outputFileType = "com.apple.quicktime-movie"
        exporter?.exportAsynchronously(completionHandler: {() -> Void in
            self.savedMuteFileURL = fileURL
            self.isMute = true
        })
    }
    
    var urlAsset : AVURLAsset?
    
    var savedMuteFileURL : URL!
    
    init(type: MediaType?, identifier: String?) {
        self.type = type
        self.identifier = identifier
    }
    
    func getDurationStr()->String {
        let interval = Int(duration)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

extension PHAssetCollection {
    
    var assetID : String? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let assets = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return assets.firstObject?.localIdentifier
    }
    var photosCount: Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
    
    var videoCount: Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        let result = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return result.count
    }
}

extension WriteMediaViewConroller : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.mediaArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell :AlbumCell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell") as! AlbumCell
        
        let asset : PHAssetCollection = mediaArray[indexPath.row]
        
        cell.assetID = asset.assetID
        cell.title.text = asset.localizedTitle
        
        let count = asset.photosCount + asset.videoCount
        
        cell.count.text = "\(count)"
        
        cell.assetCollectionSubtype = asset.assetCollectionSubtype
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell :AlbumCell = tableView.cellForRow(at: indexPath) as! AlbumCell
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.mediaTitle.text = cell.title.text
        delegate?.albumName(title: cell.title.text!)
        self.toggle()
        self.getPhotosAndVideos(cell.assetCollectionSubtype)
    }
}

class AlbumCell : UITableViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var count: UILabel!
    
    var assetCollectionSubtype: PHAssetCollectionSubtype!
    var mediaType : PHAssetMediaType!
    
    var assetID: String? {
        
        didSet {
            
            let manager = PHCachingImageManager()
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            
            if let id = assetID {
                
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: fetchOptions)
                
                guard let asset = fetchResult.firstObject
                    else { return  }
                
                if asset.mediaType == .image {
                    
                    manager.requestImage(for: asset, targetSize: CGSize(width: 52, height: 52), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                        
                        image,error  in
                        
                        self.photo.image = image
                        self.mediaType = .image
                        
                        if error != nil {
                            
                        }
                    })
                }
                
                if asset.mediaType == .video {
   
                    manager.requestImage(for: asset, targetSize: CGSize(width: 52, height: 52), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                        
                        image,error  in
                        
                        if error != nil {
                            self.photo.image = image
                            self.mediaType = .video
                        }
                    })
                }
            }
        }
    }

}

