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
    
    @IBOutlet weak var collectionView: UICollectionView!
    var avAssetIdentifiers = [String]()
    
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
        
        self.getPhotosAndVideos(.smartAlbumUserLibrary)
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.parent?.navigationController?.si_dismissModalView(toViewController: self.parent!, completion: {
                
                if let nc = self.navigationController as? FeedNavigationController {
                    nc.si_delegate?.navigationControllerDidClosed?(navigationController: nc)
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
    
    func getPhotosAndVideos(_ subType: PHAssetCollectionSubtype){
        
        self.avAssetIdentifiers.removeAll()
        
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


