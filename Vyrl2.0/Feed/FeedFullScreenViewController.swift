//
//  FeedFullScreenViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 7. 14..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class FeedFullScreenViewController: UIViewController {
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    var imageArray : [UIImage] = []
    var imageViewArray : [UIImageView] = []
    var textViewArray : [UITextView] = []
    var contentScrollViewArray : [UIScrollView] = []
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!

    @IBOutlet weak var videoPlayButton: UIButton!
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var videoStatusView: UIView!
    
    var currentPage : Int = 0;
    var index : Int = 0;
    var isRotate = false
    var profileId : Int!
    var mediasArray : [[String:String]]!
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pageNumberLabel.text =  "1 / \(self.mediasArray.count)"
        self.index = 0
        
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
            if(mediasArray[currentPage]["type"] == "VIDEO"){
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
            let imageView = UIImageView()
            self.imageViewArray.append(imageView)
            let contentScrollView = UIScrollView()
            contentScrollView.frame = CGRect.init(x: 0, y: 0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
            
            self.contentScrollViewArray.append(contentScrollView)
            self.mainScrollView.contentSize.width = contentScrollView.frame.width * CGFloat(i+1)
            self.mainScrollView.addSubview(contentScrollView)
        }
        
        requestImageVideo()
        
    }
    
    func requestImageVideo() {
        var uri : URL
        if(mediasArray[index]["type"] == "IMAGE"){
            uri = URL.init(string: mediasArray[index]["url"]!)!
        } else {
            uri = URL.init(string: mediasArray[index]["thumbnail"]!)!
        }
        
        Alamofire.request(uri)
            .downloadProgress(closure: { (progress) in
                
            }).responseData { response in
                if let data = response.result.value {
                    print("finish")
                    
                    let image = UIImage(data: data)
                    self.imageArray.append(image!)
                    
                    self.imageViewArray[self.index].image = image
                    self.imageViewArray[self.index].contentMode = .scaleAspectFit
                    
                    let height = self.contentScrollViewArray[self.index].frame.width * ((image?.size.height)! / (image?.size.width)!)
                    self.imageViewArray[self.index].frame = CGRect(x: 0, y:0, width: self.contentScrollViewArray[self.index].frame.width, height: height)
                    
                    self.contentScrollViewArray[self.index].addSubview(self.imageViewArray[self.index])
                    
                    let textView = UITextView()
                    textView.text = "반갑습니다."
                    textView.textColor = UIColor.white
                    textView.backgroundColor = UIColor.ivGreyish
                    let size = textView.sizeThatFits(CGSize.init(width: self.view.frame.width, height: 9999))
                    textView.frame = CGRect.init(x: 0, y: self.imageViewArray[self.index].frame.size.height, width: self.view.frame.width, height: size.height)
                    textView.isScrollEnabled = false
                    
                    self.contentScrollViewArray[self.index].addSubview(textView)
                    self.contentScrollViewArray[self.index].contentSize = CGSize.init(width: self.mainScrollView.frame.width, height: self.imageViewArray[self.index].frame.height + textView.frame.height)
                    
                    let xPosition = self.view.frame.width * CGFloat(self.index)
                    
                    if( self.imageViewArray[self.index].frame.height + textView.frame.height < self.mainScrollView.frame.height){
                        self.contentScrollViewArray[self.index].frame = CGRect.init(x: xPosition, y: 0, width: self.mainScrollView.frame.width, height: self.imageViewArray[self.index].frame.size.height + textView.frame.size.height)
                        self.contentScrollViewArray[self.index].center = CGPoint.init(x: self.contentScrollViewArray[self.index].center.x, y: self.view.center.y)
                    } else {
                        self.contentScrollViewArray[self.index].frame = CGRect.init(x: xPosition, y: 0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
                    }
                    
                    if(self.index == 0){
                        self.showImageVideo(page: 0)
                    }
                    
                }
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
                    self.contentScrollViewArray[i].frame = CGRect.init(x: 0, y: 0, width: size.width, height:size.height)
                    
                    let height = self.contentScrollViewArray[i].frame.width * (self.imageArray[i].size.height / self.imageArray[i].size.width)
                    self.imageViewArray[i].frame = CGRect(x: 0, y:0, width: self.contentScrollViewArray[i].frame.width, height: height)
                    
                    self.contentScrollViewArray[i].contentSize = CGSize.init(width: self.mainScrollView.frame.width, height: self.imageViewArray[i].frame.height)
                    
                    let xPosition = self.view.frame.width * CGFloat(i)
                    
                    if( self.imageViewArray[i].frame.height < self.mainScrollView.frame.height){
                        self.contentScrollViewArray[i].frame = CGRect.init(x: xPosition, y: 0, width: self.mainScrollView.frame.width, height: self.imageViewArray[i].frame.size.height)
                        self.contentScrollViewArray[i].center = CGPoint.init(x: self.contentScrollViewArray[i].center.x, y: self.view.center.y)
                    } else {
                        self.contentScrollViewArray[i].frame = CGRect.init(x: xPosition, y: 0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
                    }
                }
                self.mainScrollView.setContentOffset(CGPoint.init(x: size.width*CGFloat(self.currentPage), y: 0), animated: true)
                self.playerLayer?.frame = self.imageViewArray[self.currentPage].frame
                print("Portrait")
            case .landscapeLeft,.landscapeRight :
                for i in 0..<self.index+1 {
                    self.contentScrollViewArray[i].frame = CGRect.init(x: 0, y: 0, width: size.width, height:size.height)
                    
                    self.imageViewArray[i].frame = CGRect(x: 0, y:0, width: size.width, height: size.height)
                    self.contentScrollViewArray[i].contentSize = CGSize.init(width: size.width, height: size.height)
                    
                    let xPosition = self.view.frame.width * CGFloat(i)
                    
                    
                    self.contentScrollViewArray[i].frame = CGRect.init(x: xPosition, y: 0, width: self.mainScrollView.frame.width, height: self.imageViewArray[i].frame.size.height)
                    self.contentScrollViewArray[i].center = CGPoint.init(x: self.contentScrollViewArray[i].center.x, y: self.view.center.y)
                    
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
    
}

extension FeedFullScreenViewController : UIScrollViewDelegate {
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
        self.showImageVideo(page: page)
    }
    
    func showImageVideo(page: Int) {
        let uri : URL = URL.init(string: mediasArray[page]["url"]!)!
        //
        if(mediasArray[page]["type"] == "IMAGE"){
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
                }
            })
            
            // Layer for display… Video plays at the full size of the iPad
            self.playerLayer = AVPlayerLayer(player: player)
            
            self.imageViewArray[page].layer.addSublayer(self.playerLayer!)
            
            self.playerLayer?.frame = self.imageViewArray[page].frame
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
            self.videoPlayButton.setImage(UIImage.init(named: "icon_pause_01"), for: .normal)
            
        }
        print("\(page) scrollViewDidEndDecelerating")
    }
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
}
