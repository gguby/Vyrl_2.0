//
//  FullViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 11. 6..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import ReachabilitySwift
import Photos
import NukeFLAnimatedImagePlugin
import FLAnimatedImage

class FullViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    var imageArray : [UIImage] = []
    var imageViewArray : [UIImageView] = []
    var textViewArray : [UITextView] = []
    
    var mediasArray : [ArticleMedia]!
    
    var currentPage : Int = 0;
    var index : Int = 0;
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("\(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.index = 0
        
        self.initImageVideo()
    }
    
    func initImageVideo() {
        for i in 0..<(self.mediasArray.count) {
            var imageView : UIImageView
            let url = URL.init(string: self.mediasArray[i].imageUrl)
            if(url?.pathExtension == "gif"){
                imageView = FLAnimatedImageView()
            } else {
                imageView = UIImageView()
            }
            imageView.isUserInteractionEnabled = true
            
            self.imageViewArray.append(imageView)
            self.scrollView.contentSize.width = self.scrollView.frame.width * CGFloat(i+1)
         }
        
        requestImageVideo()
    }
    
    func requestImageVideo() {
        let uri : URL = URL.init(string: mediasArray[index].imageUrl)!
        
        Alamofire.request(uri)
            .downloadProgress(closure: { (progress) in
                
            }).responseData { response in
                if let data = response.result.value
                {
                    if(uri.pathExtension == "gif") {
                        (self.imageViewArray[self.index] as! FLAnimatedImageView).animatedImage = FLAnimatedImage.init(animatedGIFData: data)
                    } else {
                        self.imageViewArray[self.index].image =  UIImage(data: data)!
                    }
                    
                    let image = UIImage(data: data)
                    self.imageArray.append(image!)
                    self.imageViewArray[self.index].contentMode = .scaleAspectFit
                    
                    let xPosition = self.view.frame.width * CGFloat(self.index)
                    self.imageViewArray[self.index].frame = CGRect(x: xPosition, y:0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
                    self.scrollView.addSubview(self.imageViewArray[self.index])
                    
                    
                   if(self.index == 0){
                        self.showImageVideo(page: 0)
                }
            }
        }
    }


    func showImageVideo(page: Int) {
        let uri : URL = URL.init(string: mediasArray[page].url!)!
        //
        if(mediasArray[page].type == "IMAGE"){
            if(self.player != nil) {
                self.player!.pause()
                self.playerLayer?.removeFromSuperlayer()
            }
            
//            self.videoStatusView.isHidden = true
//            self.videoPlayButton.isHidden = true
        } else {
            if(self.imageViewArray[page].layer.sublayers != nil) {
                self.imageViewArray[page].layer.sublayers?.removeAll()
            }
            
            self.player?.pause()
            
            self.playerItem = AVPlayerItem.init(url: uri)
            self.player = AVPlayer.init(playerItem: self.playerItem)
            
            let duration : CMTime = playerItem!.asset.duration
            let seconds : Float64 = CMTimeGetSeconds(duration)
//            self.timeSlider.minimumValue = 0
//            self.timeSlider.maximumValue = Float(seconds)
//            self.timeSlider.isContinuous = true
            
            self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 4), queue: .main, using: { (time) in
                if let currentItem = self.player?.currentItem {
                    let duration = currentItem.duration
                    if (CMTIME_IS_INVALID(duration)) {
                        // Do sth
                        return;
                    }
                    
                    let currentTime = currentItem.currentTime()
                    
//                    self.timeSlider.value = Float(CMTimeGetSeconds(currentTime))
//                    self.currentTimeLabel.text = self.createTimeString(time: Float(CMTimeGetSeconds(currentTime)))
//                    self.totalTimeLabel.text = self.createTimeString(time: Float(CMTimeGetSeconds(duration)))
                }
            })
            
            // Layer for display… Video plays at the full size of the iPad
            self.playerLayer = AVPlayerLayer(player: player)
            
            self.imageViewArray[page].layer.addSublayer(self.playerLayer!)
            
            self.playerLayer?.frame = self.imageViewArray[page].frame
            self.player?.seek(to: kCMTimeZero)
            
        }
 
    }

}

extension FullViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("\(#function)")
        
        let page = Int(round(Double(scrollView.contentOffset.x) / Double(scrollView.bounds.size.width)))
        self.currentPage = page
        if(page > self.index) {
            self.index = page
            self.requestImageVideo()
         }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("\(#function)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("\(#function)")
        
        let page = Int(round(Double(scrollView.contentOffset.x) / Double(scrollView.bounds.size.width)))
        if(page != self.currentPage) {
            self.showImageVideo(page: page)
        }
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        print("\(#function)")
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
         print("\(#function)")
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        print("\(#function)")
        
        return self.imageViewArray[self.currentPage]
    }
}
