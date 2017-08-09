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
    
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    var currentPage : Int = 0;
    var index : Int = 0;
    var isRotate = false
    var profileId : Int!
    var mediasArray : [[String:String]]!
    
    var initialConstraints = [NSLayoutConstraint]()
    
    var imageIndex: NSInteger = 0
    
    @IBOutlet weak var pageNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
        let subViews = self.mainScrollView.subviews
        for subView in subViews {
            subView.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pageNumberLabel.text =  "1 / \(self.mediasArray.count)"
        self.index = 0
        
        self.initImageVideo()
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
                if(self.currentPage > 4)
                {
                    self.playerLayer?.frame = self.imageViewArray[self.currentPage].frame
                }
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
                if(self.currentPage > 4)
                {
                    self.playerLayer?.frame = self.imageViewArray[self.currentPage].frame
                }
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
        let uri : URL = URL.init(string: mediasArray[index]["url"]!)!
        
        if(mediasArray[index]["type"] == "IMAGE"){
            if(self.player != nil) {
                self.player!.pause()
                self.playerLayer?.removeFromSuperlayer()
            }
        } else {
            self.player = AVPlayer.init(url: uri)
            
            // Layer for display… Video plays at the full size of the iPad
            self.playerLayer = AVPlayerLayer(player: player)
            
            if(self.imageViewArray[page].layer.sublayers == nil) {
                self.imageViewArray[page].layer.addSublayer(self.playerLayer!)
            }
            self.playerLayer?.frame = self.imageViewArray[page].frame
            self.player!.play()
        }
        print("\(page) scrollViewDidEndDecelerating")
    }
}
