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
    func openPhotoOrVideo(_ mediaType: AVAsset.MediaType?, assetIdentifier: String?)
    func closeKeyboard()
    func focusTextView()
    func showMedia()
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
    var checkArray : Set = Set<IndexPath>()
    
    weak var delegate : WriteMdeiaDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleView.alpha = 0
        
        self.view.backgroundColor = .white
        
        if let nc = self.navigationController as? FeedNavigationController {
            nc.si_delegate = self
            nc.fullScreenSwipeUp = true
            nc.isNavigationBarHidden = true
        }
        
        self.getAllAlbum()
        
        self.enabledAddBtn(enabled: false)
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
        delegate?.showMedia()
    }
    
    @IBAction func focusKeyboard(_ sender : UIButton ){
        delegate?.focusTextView()
    }
    
    @IBAction func closeKeyboard(_ sender: UIButton) {
        delegate?.closeKeyboard()
    }
    
    func toggle(){
        self.mediaTable.isHidden = !self.mediaTable.isHidden
        
        if self.mediaTable.isHidden {
            upDownToggle.setImage(UIImage.init(named: "btn_select_down_02"), for: .normal)
        }else {
            upDownToggle.setImage(UIImage.init(named: "btn_select_up_01"), for: .normal)
        }
    }
    
    @IBAction func showUpPhotoTable(_ sender: SmallButton) {
        self.toggle()
    }
    
    func getAllAlbum(){
        
        mediaArray.removeAll()
        
        let fetchOptions = PHFetchOptions()
        
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: fetchOptions)
        
        var min = 99

        fetchResult.enumerateObjects({ (collection, start, stop) in
            
            if collection.estimatedAssetCount != 0 {
                let count : Int = collection.photosCount
                
                let videoCount : Int = collection.videoCount
   
                if (count > 0 || videoCount > 0){
                    if start < min {
                        min = start
                    }
                    self.mediaArray.append(collection)
                }
            }
        })

        let result : PHAssetCollection = fetchResult.object(at: min)
        let title = result.localizedTitle
        self.mediaTitle.text = title
        
        self.getPhotosAndVideos(result.assetCollectionSubtype)
        mediaTable.tableFooterView = UIView(frame: .zero)
    }
    
    func getPhotosAndVideos(_ subType: PHAssetCollectionSubtype){
        
        self.avAssetIdentifiers.removeAll()
        self.checkArray.removeAll()
        
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
                checkArray.insert(indexPath)
            }else {
                checkArray.remove(indexPath)
            }
            
            self.enabledAddBtn(enabled: checkArray.isEmpty == false )
            
            delegate?.openPhotoOrVideo(cell.asset?.type, assetIdentifier: cell.asset?.identifier)
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avAssetIdentifiers.count + 2
    }
    
}

extension WriteMediaViewConroller: FeedNavigationControllerDelegate {
    
    // MARK: - FeedNavigationControllerDelegate
    func navigationControllerDidSpreadToEntire(navigationController: UINavigationController) {
        print("spread to the entire")
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        
                        self.titleView.alpha = 1
                        
        }, completion: nil)
    }
    
    func navigationControllerDidClosed(navigationController: UINavigationController) {
        print("decreased on the view")  
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        
                        self.titleView.alpha = 0
                        
        }, completion: nil)
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
            
            if let id = assetID {
                
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: fetchOptions)
                
                guard let asset = fetchResult.firstObject
                    else { return  }
                
                if asset.mediaType == .image {
                    
                    self.asset = AVAsset(type: .photo, identifier: id)
                    
                    manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                        
                        image,error  in
                        
                        self.photo.image = image
                        
                        if error != nil {
                            
                            
                        }
                    })
                }
                
                if asset.mediaType == .video {
                    
                    var duration: TimeInterval!
                    
                    duration = asset.duration
                    
                    self.asset = AVAsset(type: .video, identifier: id)
                    self.asset?.duration = duration
                    
                    manager.requestImage(for: asset, targetSize: CGSize(width: 120, height: 120), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                        
                        image,error  in
                        
                        if error != nil {
                            
                            self.photo.image = image
             
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
    
    init(type: MediaType?, identifier: String?) {
        self.type = type
        self.identifier = identifier
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
        cell.count.text = "\(asset.photosCount)"
        cell.assetCollectionSubtype = asset.assetCollectionSubtype
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell :AlbumCell = tableView.cellForRow(at: indexPath) as! AlbumCell
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.mediaTitle.text = cell.title.text
        self.toggle()
        self.getPhotosAndVideos(cell.assetCollectionSubtype)
    }
}

class AlbumCell : UITableViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var count: UILabel!
    
    var assetCollectionSubtype: PHAssetCollectionSubtype!
    
    var assetID: String? {
        
        didSet {
            
            let manager = PHImageManager()
            
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
                        
                        if error != nil {
                            
                        }
                    })
                }
                
                if asset.mediaType == .video {
   
                    manager.requestImage(for: asset, targetSize: CGSize(width: 52, height: 52), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                        
                        image,error  in
                        
                        if error != nil {
                            
                            self.photo.image = image
                            
                        }
                    })
                }
            }
        }
    }

}

