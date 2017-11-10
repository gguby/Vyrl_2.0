//
//  PagingFullViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 11. 7..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire
import FLAnimatedImage
import ReachabilitySwift
import Photos

class PagingFullViewController: UIViewController {
    
    @IBOutlet weak var pagingControl: PagingScrollView!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var videoStatusView: UIView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var fileSizeButton: UIButton!
    @IBOutlet weak var videoPlayButton: UIButton!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var mediasArray : [ArticleMedia]!
    
    var downLoadIndex : Int! = -1
    var currentPage : Int! = 0
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pagingControl.frame = self.view.frame
        pagingControl.delegate   = self
        pagingControl.dataSource = self
        pagingControl.reloadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("\(#function)")
        
        if(self.player != nil) {
            self.player!.pause()
            self.playerLayer?.removeFromSuperlayer()
            self.playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            self.playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            self.playerItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
        }
    }
    
    func canRotate() -> Void {
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
         coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            self.pagingControl.frame = self.view.frame
           
            guard let zoomingView = self.pagingControl.pageView(at: self.pagingControl.currentPageIndex) as? ZoomingScrollView else { return }
            
            zoomingView.prepareAfterCompleted()
            zoomingView.setMaxMinZoomScalesForCurrentBounds()
            
            if(self.player != nil) {
                self.playerLayer?.frame = self.pagingControl.frame
            }
        }, completion:  {(UIViewControllerTransitionCoordinatorContext) -> Void in
            
         })
        super.viewWillTransition(to: size, with: coordinator)
        
    }
    
    @IBAction func timeSlideValueChanged(_ sender: UISlider) {
        
        self.player?.pause()
        
        let seconds : Int64 = Int64(sender.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        self.currentTimeLabel.text = self.createTimeString(time: Float(CMTimeGetSeconds(targetTime)))
        
        self.player?.seek(to: targetTime)
        
        if sender.isTracking == false {
            self.player?.play()
        }
    }
    
    @IBAction func downloadImageButtonClick(_ sender: UIButton) {
        let alertController = UIAlertController (title:"사진 다운로드시 3G/LTE를 사용하시겠습니가?", message:"사진 다운로드시 3G/LTE를 사용하시겠습니가?",preferredStyle:.actionSheet)
        
        let okay = UIAlertAction(title: "okay", style: .default,handler: { (action) -> Void in
            if(self.mediasArray[self.currentPage].type == "VIDEO") {
                self.showToast(str: "동영상은 다운로드 불가 입니다.")
            } else {
                self.downloadImage(urlString: self.mediasArray[self.currentPage].url!)
            }
        })
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(okay)
        alertController.addAction(cancel)
        
        if(Reachability.init()?.currentReachabilityStatus == .reachableViaWWAN) {
            self.present(alertController, animated: true, completion: nil)
        } else {
            if(self.mediasArray[currentPage].type == "VIDEO") {
                self.showToast(str: "동영상은 다운로드 불가 입니다.")
            } else {
                self.downloadImage(urlString: self.mediasArray[self.currentPage].url!)
            }
        }
    }
    
    @IBAction func toggleVideoPlay(_ sender: Any) {
        if(self.player?.rate != 0 && self.player?.error == nil) {
            self.videoPlayButton.setImage(UIImage.init(named: "icon_play_01"), for: .normal)
            self.player?.pause()
        } else {
            self.videoPlayButton.setImage(UIImage.init(named: "icon_pause_01"), for: .normal)
            self.player?.play()
        }
    }
    
    func downloadImage(urlString : String) {
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: urlString),
                let urlData = NSData(contentsOf: url)
            {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/\(url.lastPathComponent)";
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            DispatchQueue.main.async {
                                self.showToast(str: "photo is saved!")
                            }
                        }
                        if (error != nil) {
                            print(error as Any)
                        }
                    }
                }
            }
        }
    }
    
    func handleTap() {
        if(self.topView.isHidden == false) {
            self.topView.isHidden = true
            self.bottomView.isHidden = true
            self.contentTextView.isHidden = true
            self.videoPlayButton.isHidden = true
            
        } else {
            self.topView.isHidden = false
            self.bottomView.isHidden = false
            self.contentTextView.isHidden = false
            
            if(mediasArray[currentPage].type == "VIDEO"){
               self.videoStatusView.isHidden = false
                self.videoPlayButton.isHidden = false
            }
        }
    }
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
}

extension PagingFullViewController : PagingScrollViewDelegate, PagingScrollViewDataSource {
    func pagingScrollView(_ pagingScrollView: PagingScrollView, willChangedCurrentPage currentPageIndex: NSInteger) {
         print("current page will be changed to \(currentPageIndex).")
    }
    
    func pagingScrollView(_ pagingScrollView: PagingScrollView, didChangedCurrentPage currentPageIndex: NSInteger) {
        print("current page did changed to \(currentPageIndex).")
        self.fileSizeButton.setTitle("\(self.mediasArray[currentPageIndex].fileSizeString!)", for: .normal)
        self.pageNumberLabel.text =  "\(currentPageIndex+1) / \(self.mediasArray.count)"
        
        self.currentPage = currentPageIndex
        
        guard let zoomingView = self.pagingControl.pageView(at: self.pagingControl.currentPageIndex) as? ZoomingScrollView else { return }
         self.showImageVideo(currentIndex: currentPageIndex, view:  zoomingView)
        
    }
    
    func pagingScrollView(_ pagingScrollView: PagingScrollView, layoutSubview view: UIView) {
        print("paging control call layoutsubviews. \(self.view.frame)")
    }
    
    func pagingScrollView(_ pagingScrollView: PagingScrollView, recycledView view: UIView?, viewForIndex index: NSInteger) -> UIView {
        guard view == nil else { return view! }
        
        let zoomingView = ZoomingScrollView(frame: self.view.bounds)
        zoomingView.backgroundColor = UIColor.black
        zoomingView.singleTapEvent = {
            print("single tapped...")
            self.handleTap()
        }
        
        zoomingView.doubleTapEvent = {
            print("double tapped...")
        }
        
        zoomingView.pinchTapEvent = {
            print("pinched...")
        }
        
        return zoomingView
    }
    
    func pagingScrollView(_ pagingScrollView: PagingScrollView, prepareShowPageView view: UIView, viewForIndex index: NSInteger) {
        guard let zoomingView = view as? ZoomingScrollView else { return }
        guard let zoomContentView = zoomingView.targetView as? ZoomContentView else { return }
        
        if( downLoadIndex < index){
            downLoadIndex = index
            self.requestImageVideo(index: index, zoomingView: zoomingView, zoomContentView: zoomContentView)
        } else {
            zoomingView.prepareAfterCompleted()
            zoomingView.setMaxMinZoomScalesForCurrentBounds()
        }
    }
    
    func startIndexOfPageWith(pagingScrollView: PagingScrollView) -> NSInteger {
        return 0
    }
    
    func numberOfPageWith(pagingScrollView: PagingScrollView) -> NSInteger {
        return mediasArray.count
    }
    
    func requestImageVideo(index:Int , zoomingView : ZoomingScrollView, zoomContentView : ZoomContentView) {
        let uri : URL = URL.init(string: mediasArray[index].imageUrl)!
        
        Alamofire.request(uri)
            .downloadProgress(closure: { (progress) in
                self.indicator.isHidden = false
                self.indicator.startAnimating()
            }).responseData { response in
                if let data = response.result.value
                {
                    self.indicator.isHidden = true
                    
                    let image = UIImage(data: data)
                    
                    if(uri.pathExtension == "gif") {
                        zoomContentView.animatedImage = FLAnimatedImage.init(animatedGIFData: data)
                    } else {
                        zoomContentView.image = image
                    }
                    // just call this methods after set image for resizing.
                    zoomingView.prepareAfterCompleted()
                    zoomingView.setMaxMinZoomScalesForCurrentBounds()
                }
        }
    }
    
    func showImageVideo(currentIndex:Int, view: UIView) {
        let uri : URL = URL.init(string: mediasArray[currentIndex].url!)!
        
        if(self.player != nil) {
            self.player!.pause()
            self.playerLayer?.removeFromSuperlayer()
        }
        
        if(mediasArray[currentIndex].type == "IMAGE") {
            self.videoStatusView.isHidden = true
            self.videoPlayButton.isHidden = true
        } else {
            self.videoStatusView.isHidden = false
            self.videoPlayButton.isHidden = false
            
            self.player?.pause()

            self.playerItem = AVPlayerItem.init(url: uri)
            self.playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            self.playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            self.playerItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
            self.player = AVPlayer.init(playerItem: self.playerItem)
            
            let duration : CMTime = playerItem!.asset.duration
            let seconds : Float64 = CMTimeGetSeconds(duration)
            self.timeSlider.minimumValue = 0
            self.timeSlider.maximumValue = Float(seconds)
            self.timeSlider.isContinuous = true
            
            self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 4), queue: .main, using: { (time) in
                if let currentItem = self.player?.currentItem {
                    let duration = currentItem.duration
                    if (CMTIME_IS_INVALID(duration)) {
                        // Do sth
                        return;
                    }
                    
                    let currentTime = currentItem.currentTime()
                    
                    self.timeSlider.value = Float(CMTimeGetSeconds(currentTime))
                    self.currentTimeLabel.text = self.createTimeString(time: Float(CMTimeGetSeconds(currentTime)))
                    self.totalTimeLabel.text = self.createTimeString(time: Float(CMTimeGetSeconds(duration)))
                }
            })

            // Layer for display… Video plays at the full size of the iPad
            self.playerLayer = AVPlayerLayer(player: player)

            view.layer.addSublayer(self.playerLayer!)

            self.playerLayer?.frame = pagingControl.frame
            self.player?.seek(to: kCMTimeZero)
            
            self.videoPlayButton.setImage(UIImage.init(named: "icon_pause_01"), for: .normal)
            self.player?.play()
         }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            switch keyPath {
            case "playbackBufferEmpty"?:
                // Show loader
                indicator.isHidden = false
                indicator.startAnimating()
                break;
            case "playbackLikelyToKeepUp"?:
                // Hide loader
                indicator.isHidden = true
                break;
            case "playbackBufferFull"?:
                // Hide loader
                indicator.isHidden = true
                break;
            default : break
                
            }
        }
    }
    
}
