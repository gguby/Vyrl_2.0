//
//  FeedFullViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 9. 14..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import ReachabilitySwift
import Photos
import NukeFLAnimatedImagePlugin
import FLAnimatedImage

class FeedFullViewController: UIViewController {

    @IBOutlet weak var mainScrollView: UIScrollView!
    var imageViewArray : [UIImageView] = []

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var videoPlayButton: UIButton!
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var videoStatusView: UIView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var fileSizeButton: UIButton!
    
    var currentPage : Int = 0;
    var index : Int = 0;
    var isRotate = false
    var profileId : Int!
    var mediasArray : [ArticleMedia]!
    
    var timer : Timer?
    
    var initialConstraints = [NSLayoutConstraint]()
    var imageIndex: NSInteger = 0
    
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
    
    @IBOutlet weak var pageNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTimer()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        singleTap.cancelsTouchesInView = false
        singleTap.numberOfTapsRequired = 1
        mainScrollView.addGestureRecognizer(singleTap)
        
        enableDownloadImageButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pageNumberLabel.text =  "1 / \(self.mediasArray.count)"
        self.index = 0
        self.fileSizeButton.setTitle("\(self.mediasArray[0].mbFileSize!)MB", for: .normal)
        
        self.initImageVideo()
        
    }
    
    func handleTap() {
        if(self.topView.isHidden == false) {
            self.topView.isHidden = true
            self.bottomView.isHidden = true
            self.videoPlayButton.isHidden = true
            
            stopTimer()
        } else {
            self.topView.isHidden = false
            self.bottomView.isHidden = false
            if(mediasArray[currentPage].type == "VIDEO"){
                self.videoPlayButton.isHidden = false
                self.videoStatusView.isHidden = false
            }
            
            startTimer()
        }
    }
    
    func startTimer()
    {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer()
    {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    func timerAction() {
        if(self.topView.isHidden == false) {
            self.topView.isHidden = true
            self.bottomView.isHidden = true
            self.videoPlayButton.isHidden = true
            
            stopTimer()
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
    
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
        let subViews = self.mainScrollView.subviews
        for subView in subViews {
            subView.removeFromSuperview()
        }
    }
    
    func initImageVideo() {
        for i in 0..<(self.mediasArray.count)  {
            let xPosition = self.view.frame.width * CGFloat(i)
            var imageView : UIImageView
            
            let url = URL.init(string: self.mediasArray[i].imageUrl)
            if(url?.pathExtension == "gif"){
                imageView = FLAnimatedImageView()
            } else {
                
                imageView = UIImageView()
            }
            imageView.frame = CGRect.init(x: xPosition, y: 0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
            self.imageViewArray.append(imageView)
            self.mainScrollView.contentSize.width = imageView.frame.width * CGFloat(i+1)
            self.mainScrollView.addSubview(imageView)
        }
        
        requestImageVideo()
        
    }
    
    func requestImageVideo() {
        var uri : URL
        if(mediasArray[index].type == "IMAGE"){
            uri = URL.init(string: mediasArray[index].url!)!
        } else {
            uri = URL.init(string: mediasArray[index].thumbnail!)!
        }
        
        Alamofire.request(uri)
            .downloadProgress(closure: { (progress) in
                
            }).responseData { response in
                if let data = response.result.value {
                    print("finish")
                    
                     if(uri.pathExtension == "gif") {
                        (self.imageViewArray[self.index] as! FLAnimatedImageView).animatedImage = FLAnimatedImage.init(animatedGIFData: data)
                    } else {
                        self.imageViewArray[self.index].image =  UIImage(data: data)!
                    }
                    
                    let xPosition = self.mainScrollView.frame.width * CGFloat(self.index)
                    self.imageViewArray[self.index].frame = CGRect.init(x: xPosition, y: 0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
                    self.imageViewArray[self.index].contentMode = .scaleAspectFit
                    
    
                    if(self.index == 0){
                        self.showImageVideo(page: 0)
                    }
                    
                }
        }
        
    }
    
    @IBAction func downloadImageButtonClick(_ sender: UIButton) {
        let alertController = UIAlertController (title:"사진 다운로드시 3G/LTE를 사용하시겠습니가?", message:"사진 다운로드시 3G/LTE를 사용하시겠습니가?",preferredStyle:.actionSheet)
        
        let okay = UIAlertAction(title: "okay", style: .default,handler: { (action) -> Void in
            self.downloadImage(urlString: self.mediasArray[self.currentPage].url!)
        })
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(okay)
        alertController.addAction(cancel)
        
        if(Reachability.init()?.currentReachabilityStatus == .reachableViaWWAN) {
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.downloadImage(urlString: self.mediasArray[self.currentPage].url!)
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
                            print("photo is saved!")
                        }
                        
                        if (error != nil) {
                            print(error as Any)
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func timeSlideValueChanged(_ sender: UISlider) {
        //        if((self.player?.rate)! > Float(0) && self.player?.error == nil) {
        //            let newTime = CMTimeMake(Int64(Float(sender.value)), 1)
        //            player?.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        //        }
        self.player?.pause()
        var timeInSecond = sender.value
        timeInSecond *= 1000;
        let cmTime = CMTimeMake(Int64(timeInSecond), 1000)
        
        self.player?.seek(to: cmTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
    }
    
    func enableDownloadImageButton() {
        if(mediasArray[self.currentPage].type == "IMAGE") {
            self.downloadButton.isEnabled = true
        } else {
            self.downloadButton.isEnabled = false
        }
        
    }
    
    func showUseDataAlert() {
        let alertController = UIAlertController (title:"영상 재생시 3G/LTE를 사용하시겠습니가?", message:"영상 재생시 3G/LTE를 사용하시겠습니가?",preferredStyle:.actionSheet)
        
        let okay = UIAlertAction(title: "okay", style: .default,handler: { (action) -> Void in
            self.player?.play()
            self.videoPlayButton.setImage(UIImage.init(named: "icon_pause_01"), for: .normal)
        })
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(okay)
        alertController.addAction(cancel)
        
        if(Reachability.init()?.currentReachabilityStatus == .reachableViaWWAN) {
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.player?.play()
            self.videoPlayButton.setImage(UIImage.init(named: "icon_pause_01"), for: .normal)
        }
    }
    
    
    func canRotate() -> Void {
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.isRotate = true
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            self.mainScrollView.contentSize.width = size.width * CGFloat(self.mediasArray.count)
            
            let orient = UIApplication.shared.statusBarOrientation
            switch orient {
            case .portrait:
                for i in 0..<self.index+1 {
                    let xPosition = size.width * CGFloat(i)
                    
                    self.imageViewArray[i].frame = CGRect.init(x: xPosition, y: 0, width: size.width, height: size.height)
                   
                }
                
                self.mainScrollView.setContentOffset(CGPoint.init(x: size.width*CGFloat(self.currentPage), y: 0), animated: true)
                self.playerLayer?.frame = self.imageViewArray[self.currentPage].frame
                print("Portrait")
            case .landscapeLeft,.landscapeRight :
                for i in 0..<self.index+1 {
                    let xPosition = size.width * CGFloat(i)
                    
                    self.imageViewArray[i].frame = CGRect.init(x: xPosition, y: 0, width: size.width, height: size.height)
                }
                self.mainScrollView.setContentOffset(CGPoint.init(x: size.width*CGFloat(self.currentPage), y: 0), animated: true)
                self.playerLayer?.frame = self.imageViewArray[self.currentPage].frame
                print("Landscape")
                
            default:
                
                print("Anything But Portrait")
            }
            
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            self.isRotate = false
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
}

extension FeedFullViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(Double(scrollView.contentOffset.x) / Double(scrollView.bounds.size.width)))
        self.pageNumberLabel.text =  "\(page+1) / \(self.mediasArray.count)"
        if(self.isRotate == false){
            self.currentPage = page
            if(page > self.index) {
                self.index = page
                self.requestImageVideo()
            }
        }
        
        print("scrollViewDidScroll")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let page = Int(round(Double(scrollView.contentOffset.x) / Double(scrollView.bounds.size.width)))
        print("\(page) scrollViewDidEndDragging")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(round(Double(scrollView.contentOffset.x) / Double(scrollView.bounds.size.width)))
        
        self.fileSizeButton.setTitle("\(self.mediasArray[page].mbFileSize!)MB", for: .normal)
        self.enableDownloadImageButton()
        self.showImageVideo(page: page)
    }
    
    func showImageVideo(page: Int) {
        let uri : URL = URL.init(string: mediasArray[page].url!)!
        //
        if(mediasArray[page].type == "IMAGE"){
            if(self.player != nil) {
                self.player!.pause()
                self.playerLayer?.removeFromSuperlayer()
            }
            
            self.videoStatusView.isHidden = true
            self.videoPlayButton.isHidden = true
        } else {
            if(self.imageViewArray[page].layer.sublayers != nil) {
                self.imageViewArray[page].layer.sublayers?.removeAll()
            }
            
            self.player?.pause()
            
            self.playerItem = AVPlayerItem.init(url: uri)
            self.player = AVPlayer.init(playerItem: self.playerItem)
            self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(33, 1000), queue: .main, using: { (time) in
                if let currentItem = self.player?.currentItem {
                    let duration = currentItem.duration
                    if (CMTIME_IS_INVALID(duration)) {
                        // Do sth
                        return;
                    }
                    let currentTime = currentItem.currentTime()
                    self.timeSlider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
                    self.currentTimeLabel.text = self.createTimeString(time: Float(CMTimeGetSeconds(currentTime)))
                    self.totalTimeLabel.text = self.createTimeString(time: Float(CMTimeGetSeconds(duration)))
                }
            })
            
            // Layer for display… Video plays at the full size of the iPad
            self.playerLayer = AVPlayerLayer(player: player)
            
            self.imageViewArray[page].layer.addSublayer(self.playerLayer!)
            
            self.playerLayer?.frame = self.imageViewArray[page].frame
            self.player?.seek(to: kCMTimeZero)
            self.showUseDataAlert()
            
            
        }
        print("\(page) scrollViewDidEndDecelerating")
    }
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }

}