//
//  WriteMediaViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 7. 6..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import Photos
import MobileCoreServices

protocol WriteMdeiaDelegate : class {
    func openCameraView()
    func openPhotoView()
    func openLocationView()
    func closeKeyboard()
    func focusTextView()
    func showFullScreen()
    func completeAddMedia(array : [AVAsset], isOpenYn : Bool)
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
    
    @IBOutlet weak var openYnLabel: UILabel!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var openYnView: UIView!
    
    var avAssetIdentifiers = [String]()
    var mediaArray = [PHAssetCollection]()

    var selectedAssetArray = [AVAsset]()
    
    weak var delegate : WriteMdeiaDelegate?
    
    var currentSubType : PHAssetCollectionSubtype!
    
    var isOpenYn = false
    
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
        
        self.openYnView.alpha = self.isOpenYn ? 1 : 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if PhotoAutorizationStatusCheck() {
            self.getPhotosAndVideos(self.currentSubType)
        }
    }
    
    @IBAction func openYnCheck(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            sender.setImage(UIImage.init(named: "icon_check_08_on"), for: .normal)
            self.openYnLabel.textColor = UIColor.ivLighterPurple
        } else {
            sender.tag = 0
            sender.setImage(UIImage.init(named: "icon_check_08_off"), for: .normal)
            self.openYnLabel.textColor = UIColor.ivGreyish
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
        
        selectedAssetArray = (selectedArray?.clone())!
        
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
    
    func setupGifData(asset : AVAsset){
        
        if asset.type! != .gif {
            return
        }
        
        let manager = PHImageManager()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [asset.identifier!], options: fetchOptions)
        
        guard let origin = fetchResult.firstObject
            else { return }
        
        if origin.mediaType == .image {
            manager.requestImageData(for: origin, options: requestOptions, resultHandler: { (imageData, UTI, _, _) in
                if let uti = UTI,let data = imageData ,
                    UTTypeConformsTo(uti as CFString, kUTTypeGIF) {
                        asset.gifData = data
                    }
            })
        }
    }
    
    @IBAction func addMedia(_ sender: SmallButton) {
        
        for asset in selectedAssetArray {
            self.setupGifData(asset: asset)
        }
        
        delegate?.completeAddMedia(array: selectedAssetArray, isOpenYn: (self.checkBtn.tag == 1))
        
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
            })
            
            if self.avAssetIdentifiers.count == 0 {
                
            }
        })
        
        self.collectionView.reloadData()
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
                    cell.asset?.selectedCount = selectedAssetArray.count
                    cell.count = selectedAssetArray.count
                }
            }else {
                if let index = selectedAssetArray.index(where: { $0.identifier == cell.assetID}){
                    selectedAssetArray.remove(at: index)
                }
                
                var i  = 1
                
                for asset in selectedAssetArray {
                    asset.selectedCount = i
                    i += 1
                }
                
                collectionView.reloadData()
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
        
        if let index = selectedAssetArray.index(where: { $0.identifier == cell.assetID}){
            let asset = selectedAssetArray[index]
            cell.isChecked = true
            cell.count = asset.selectedCount
        }
        else {
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
    
    @IBOutlet weak var unCheckView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    
    var count : Int! {
        didSet {
            countLabel.text = "\(count!)"
        }
    }
    
    var isChecked: Bool = false {
        didSet{
            if isChecked {
                unCheckView.backgroundColor = UIColor.ivLighterPurple
                countLabel.alpha = 1
            }else {
                unCheckView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
                countLabel.alpha = 0
            }
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
            
            let photoSize = self.photo.frame.size
            
            if let id = assetID {
                
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: fetchOptions)
                
                guard let asset = fetchResult.firstObject
                    else { return  }
                
                if asset.mediaType == .image {
                    
                    self.asset = AVAsset(type: .photo, identifier: id)
                    
                    DispatchQueue.global().async {
                        
                        manager.requestImageData(for: asset, options: requestOptions, resultHandler: { (imageData, UTI, _, _) in
                            if let uti = UTI,let data = imageData ,
                                UTTypeConformsTo(uti as CFString, kUTTypeGIF) {
                                    self.asset?.type = .gif
                                }
                            
                            DispatchQueue.main.async {
                                self.photo.image = UIImage.init(data: imageData!)
                            }
                        })
                    }
                }
                
                if asset.mediaType == .video {
                    
                    var duration: TimeInterval!
                    
                    duration = asset.duration
                    
                    self.asset = AVAsset(type: .video, identifier: id)
                    self.asset?.duration = duration
                    
                    DispatchQueue.global().async {
                        manager.requestImage(for: asset, targetSize: photoSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
                            
                            image,error  in
                            
                            DispatchQueue.main.async {
                                if error != nil {
                                    self.photo.image = image
                                }
                            }
                        })
                        
                        manager.requestAVAsset(forVideo: asset, options: PHVideoRequestOptions(), resultHandler: {(avAsset, audioMix, info) -> Void in
                            if let asset = avAsset as? AVURLAsset {
                                
                                DispatchQueue.main.async {
                                    self.asset?.urlAsset = asset
                                }
                            }
                        })
                    }
                }
            }
        }
    }
}

class AVAsset : Copying {
    
    enum MediaType: Int {
        case video
        case photo
        case gif
    }
    
    var type: MediaType?
    var identifier: String?
    var duration :TimeInterval!
    
    var isMute : Bool = false
    
    var photo : UIImage?
    
    var editedData : Data?
    
    var selectedCount : Int!
    
    var gifData : Data?
    
    var mediaData : Data? {

        get {
            guard type == .photo else {
                
                if type == .gif  {
                    
                    return self.gifData
                }
                
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
            
            if self.type == .photo {
                let size = PHImageManagerMaximumSize
                self.getImage(size: size)
                
                var compression = 1.0
                let maxCompression = 0.1
                let maxFileSize = 300 * 1024
                
                var imgData: NSData = NSData(data: UIImageJPEGRepresentation(self.photo!, CGFloat(compression))!)
                
                var imageSize : Int = imgData.length
                
                while( imageSize > maxFileSize && compression > maxCompression ){
                    compression -= 0.1
                    imgData = NSData(data: UIImageJPEGRepresentation(self.photo!, CGFloat(compression))!)
                    imageSize = imgData.length
                }
                
                return imgData as Data
                
            }
            return nil
        }
    }
    
    func getImage(size : CGSize){
        let manager = PHImageManager()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [self.identifier!], options: fetchOptions)
        
        guard let asset = fetchResult.firstObject
            else { return  }
        
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions, resultHandler: {
            image,error  in
            self.photo = image
            if error != nil {
            }
        })
    }
    
    func removeAudioFromVideo(){
        
        if let url = self.savedMuteFileURL {
            if FileManager.default.fileExists(atPath: url.path) {
                return
            }
        }
        
        let composition = AVMutableComposition()
        let sourceAsset = self.urlAsset!
        let compositionVideoTrack: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let sourceVideoTrack: AVAssetTrack? = sourceAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        let x: CMTimeRange = CMTimeRangeMake(kCMTimeZero, sourceAsset.duration)
        _ = try? compositionVideoTrack!.insertTimeRange(x, of: sourceVideoTrack!, at: kCMTimeZero)
        
        let mainCompositionInst = AVMutableVideoComposition.init()
        
        mainCompositionInst.frameDuration = (sourceVideoTrack?.minFrameDuration)!
        mainCompositionInst.renderSize = (sourceVideoTrack?.naturalSize)!
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: sourceVideoTrack!)
        let rotation: CGAffineTransform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
        
        layerInstruction.setTransform(rotation, at: kCMTimeZero)
        
        let inst = AVMutableVideoCompositionInstruction.init()
        inst.timeRange = CMTimeRange.init(start: kCMTimeZero, end: sourceAsset.duration)
        inst.layerInstructions.append(layerInstruction)
        mainCompositionInst.instructions.append(inst)
        
        let url = urlAsset!.url
        
        let urlStr =  ( url.absoluteString as NSString ).lastPathComponent
        let fileURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(urlStr)
        
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = fileURL
        exporter?.outputFileType = "com.apple.quicktime-movie"
        exporter?.videoComposition = mainCompositionInst
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
    
    required init(original: AVAsset) {
        self.type = original.type
        self.identifier = original.identifier
        self.selectedCount = original.selectedCount
        self.urlAsset = original.urlAsset
        self.editedData = original.editedData
        self.gifData = original.gifData
        self.duration = original.duration
        self.savedMuteFileURL = original.savedMuteFileURL
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
            requestOptions.resizeMode = .exact
            
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

