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
    
    var currentImageView : UIImageView!
    var queue : [AVPlayerItem] = []
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    
    var previousDeviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
    var index : Int = 0;
    
    let samplePhotos = ["https://cdn2.vyrl.com/vyrl/images/post/_temp/temp/4ec6d08055c4ebcc76494080bbcd4ee2.jpg",
                        "https://cdn2.vyrl.com/vyrl/images/post/_temp/54841/cfc79b7201ff0caae5fb1f25ac7145a8.jpg",
                        "https://cdn2.vyrl.com/vyrl/images/post/_temp/temp/ae47d8dd720a1f1b36c6aebe635663c7.jpg",
                        "https://cdn2.vyrl.com/vyrl/images/post/_temp/temp/77ee0896da31740db3ee64fd2f30795a.jpg",
                        "https://cdn2.vyrl.com/vyrl/images/post/_temp/temp/b0926fdcadf9b4ab2083efaee041cfc7.jpg"]
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
        
        self.updateImageVideo()
    }

    func updateImageVideo() {
        let url1 = NSURL(string: "http://techslides.com/demos/sample-videos/small.mp4")
        playerItem = AVPlayerItem(url: url1! as URL)
        player = AVPlayer(playerItem: playerItem!)
        
//        for i in 0..<(samplePhotos.count) {
//                            //                let playerLayer = AVPlayerLayer(player: player!)
//                //                let xPosition = self.view.frame.width * CGFloat(i)
//                //                playerLayer.frame = CGRect(x: xPosition, y:0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
//                //
//                //                imageView.frame = playerLayer.videoRect
//                //                imageView.layer.addSublayer(playerLayer)
//                //
//                //                scrollView.contentSize.width = scrollView.frame.width * CGFloat(i+1)
//                //                scrollView.addSubview(imageView)
//            
//            let concurrentQueue = DispatchQueue(label: "queuename", attributes: .concurrent)
//            concurrentQueue.sync {
//                let contentView = FeedFullScreenView.instanceFromNib()
//                contentView.updateData(frame: self.view.frame, imageUrl: self.samplePhotos[i], text: "안녕하세요", index: i)
//                
//                self.mainScrollView.contentSize.width = contentView.frame.width * CGFloat(i+1)
//                self.mainScrollView.addSubview(contentView)
//            }
//        }
        
        for i in 0..<(samplePhotos.count) {
            let imageView = UIImageView()
            self.imageViewArray.append(imageView)
            let contentScrollView = UIScrollView()
            contentScrollView.frame = CGRect.init(x: 0, y: 0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
            
            Alamofire.request(samplePhotos[i])
                    .downloadProgress(closure: { (progress) in
                        
                    }).responseData { response in
                        
                        
                    if let data = response.result.value {
                        let image = UIImage(data: data)
                        self.imageArray.append(image!)
                        imageView.image = image
                        
                        imageView.contentMode = .scaleAspectFit
                        
                        let height = contentScrollView.frame.width * ((image?.size.height)! / (image?.size.width)!)
                        imageView.frame = CGRect(x: 0, y:0, width: contentScrollView.frame.width, height: height)
                        
                        self.mainScrollView.contentSize.width = contentScrollView.frame.width * CGFloat(self.index+1)
                        contentScrollView.addSubview(imageView)
                        
                        let textView = UITextView()
                        textView.text = "반갑습니다."
                        textView.textColor = UIColor.white
                        textView.backgroundColor = UIColor.ivGreyish
                        let size = textView.sizeThatFits(CGSize.init(width: self.view.frame.width, height: 9999))
                        textView.frame = CGRect.init(x: 0, y: imageView.frame.size.height, width: self.view.frame.width, height: size.height)
                        textView.isScrollEnabled = false
                        
                        contentScrollView.addSubview(textView)
                        contentScrollView.contentSize = CGSize.init(width: self.mainScrollView.frame.width, height: imageView.frame.height + textView.frame.height)
                        
                        let xPosition = self.view.frame.width * CGFloat(i)
                        
                        if( imageView.frame.height + textView.frame.height < self.mainScrollView.frame.height){
                            contentScrollView.frame = CGRect.init(x: xPosition, y: 0, width: self.mainScrollView.frame.width, height: imageView.frame.size.height + textView.frame.size.height)
                            contentScrollView.center = CGPoint.init(x: contentScrollView.center.x, y: self.view.center.y)
                        } else {
                            contentScrollView.frame = CGRect.init(x: xPosition, y: 0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
                        }
                        
                        self.mainScrollView.addSubview(contentScrollView)
                        self.index += 1
                    }
                }
            }
        }
    
    func canRotate() -> Void {
    }
    
    func setContextString(text: String, textView : UITextView) {
        var textString: String = text
        var orgStr = textString.replacingOccurrences(of: "\n\n", with: "\n \n")
        orgStr = orgStr.replacingOccurrences(of: "\n\r\n\r", with: "\n\r \n\r")
        orgStr = orgStr.replacingOccurrences(of: "\r\n\r\n", with: "\r\n \r\n")
        orgStr = "\(orgStr) "
        if (textString is NSNull) || textString.characters.count < 1 {
            orgStr = "     "
        }
      
        let str = NSMutableAttributedString(string: orgStr, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
        
        var spcs_set = NSCharacterSet.letters.inverted
        spcs_set.remove(charactersIn: "-_#@0123456789")
        spcs_set.insert(charactersIn: "€£¥•£€·¥$₽₤₩￦₸。")
        var scanStart: Bool = false
        var spcahactor: Bool = false
        var characterRange = NSRange()
        
        textView.dataDetectorTypes = .link
        
        var mentionCount: Int = 0
        
         for i in 0..<orgStr.characters.count {
            var r = NSRange()
            r.location = i
            r.length = 1
            let cutter: String = (orgStr as NSString).substring(with: r)
            spcahactor = false
            if cutter.components(separatedBy: spcs_set).count > 1 {
                spcahactor = true
            }
            if Array(orgStr.characters)[i] == "#" {
                characterRange.location = i
                characterRange.length = 1
                scanStart = true
            }
            if Array(orgStr.characters)[i] == "@" && mentionCount < 30 {
                mentionCount += 1
                characterRange.location = i
                characterRange.length = 1
                scanStart = true
            }
            
            if ((Array(orgStr.characters)[i] == "@" && mentionCount >= 30) || Array(orgStr.characters)[i] == " " || Array(orgStr.characters)[i] == "\n" || Array(orgStr.characters)[i] == "\r" || Array(orgStr.characters)[i] == "\t" || i == characterRange.length - 1 || spcahactor) && scanStart {
                let cRange: NSRange = characterRange
                if i != characterRange.length - 1 {
                    characterRange.length -= 1
                }
                if characterRange.length > 1 {
                    let word: String = (orgStr as NSString).substring(with: cRange)
                    str.addAttribute(NSLinkAttributeName, value: word, range: cRange)
                }
                scanStart = false
            }
            characterRange.length += 1
        }
        
        textView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.ivLighterPurple, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleNone]
        textView.scrollsToTop = false
        textView.attributedText = str
        textView.textColor = UIColor.white
        textView.backgroundColor = UIColor.clear

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
//        if(page == 0)
//        {
//            self.player?.play()
//        } else {
//            self.player?.pause()
//        }
        
        self.pageNumberLabel.text =  "\(page+1) / \(self.samplePhotos.count)"
    }
}
