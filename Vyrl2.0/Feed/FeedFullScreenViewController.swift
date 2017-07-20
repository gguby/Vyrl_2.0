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
    
    var queue : [AVPlayerItem] = []
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    
    var currentPage : Int = 0;
    var index : Int = 0;
    
    let samplePhotos = ["https://cdn2.vyrl.com/vyrl/images/post/_temp/temp/4ec6d08055c4ebcc76494080bbcd4ee2.jpg",
                        "https://cdn2.vyrl.com/vyrl/images/post/_temp/54841/cfc79b7201ff0caae5fb1f25ac7145a8.jpg",
                        "https://cdn2.vyrl.com/vyrl/images/post/_temp/temp/ae47d8dd720a1f1b36c6aebe635663c7.jpg",
                        "https://cdn2.vyrl.com/vyrl/images/post/_temp/temp/77ee0896da31740db3ee64fd2f30795a.jpg",
                        "https://cdn2.vyrl.com/vyrl/images/post/_temp/temp/b0926fdcadf9b4ab2083efaee041cfc7.jpg"
                        ]
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
        self.pageNumberLabel.text =  "1 / \(self.samplePhotos.count)"
        self.index = 0
        
        self.initImageVideo()
    }

    func initImageVideo() {
        for i in 0..<(samplePhotos.count) {
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
        Alamofire.request(samplePhotos[index])
            .downloadProgress(closure: { (progress) in
                print(progress)
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
        if size.height < size.width {
                // Landscape
        }
    }
}

extension FeedFullScreenViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(Double(scrollView.contentOffset.x) / Double(scrollView.bounds.size.width)))
        self.pageNumberLabel.text =  "\(page+1) / \(self.samplePhotos.count)"
        
        if(page > self.index){
            self.index = page
            self.requestImageVideo()
        }
    }
}
