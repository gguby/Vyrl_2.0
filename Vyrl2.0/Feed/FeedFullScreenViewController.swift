//
//  FeedFullScreenViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 7. 14..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import AVFoundation

class FeedFullScreenViewController: UIViewController {

    @IBOutlet weak var mainScrollView: UIScrollView!
    var imageView : UIImageView!
    var currentImageView : UIImageView!
    var queue : [AVPlayerItem] = []
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    
    var previousDeviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    let samplePhotos = [UIImage(named: "github1"),
                                UIImage(named: "github2"),
                                UIImage(named: "github3"),
                                UIImage(named: "github4"),
                                UIImage(named: "github5"),
                                UIImage(named: "github6"),
                                UIImage(named: "github7"),
                                UIImage(named: "github8"),
                                UIImage(named: "github9")
                                ]
    var initialConstraints = [NSLayoutConstraint]()
    
    var imageIndex: NSInteger = 0
    
    @IBOutlet weak var pageNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url1 = NSURL(string: "http://techslides.com/demos/sample-videos/small.mp4")
        playerItem = AVPlayerItem(url: url1! as URL)
        player = AVPlayer(playerItem: playerItem!)
        
        for i in 0..<(samplePhotos.count) {
            imageView = UIImageView()
            let contentScrollView = UIScrollView()
            contentScrollView.frame = CGRect.init(x: 0, y: 0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
            
            if(i == 4){
                let url = NSURL(string: "https://s3.amazonaws.com/vids4project/sample.mp4")
                
                
//                let playerLayer = AVPlayerLayer(player: player!)
//                let xPosition = self.view.frame.width * CGFloat(i)
//                playerLayer.frame = CGRect(x: xPosition, y:0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
//                
//                imageView.frame = playerLayer.videoRect
//                imageView.layer.addSublayer(playerLayer)
//                
//                scrollView.contentSize.width = scrollView.frame.width * CGFloat(i+1)
//                scrollView.addSubview(imageView)

                

            } else {
                imageView.image = samplePhotos[i]
                imageView.contentMode = .scaleAspectFit
                
                let height = contentScrollView.frame.width * ((samplePhotos[i]?.size.height)! / (samplePhotos[i]?.size.width)!)
                imageView.frame = CGRect(x: 0, y:0, width: contentScrollView.frame.width, height: height)
                
                self.mainScrollView.contentSize.width = contentScrollView.frame.width * CGFloat(i+1)
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
            }
        }

    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
        let subViews = self.mainScrollView.subviews
        for subView in subViews {
            subView.removeFromSuperview()
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
//        if size.height < size.width {
//            // Landscape
//            let subViews = self.scrollView.subviews
//            var i = 0
//            
//            for subView in subViews {
//                let xPosition = self.view.frame.width * CGFloat(i)
//                i += 1
//                subView.contentMode = .scaleAspectFit
//                subView.frame = CGRect(x: xPosition, y:0, width: self.scrollView.frame.height, height: self.scrollView.frame.width)
//                
//               
//                print("SubView ===========  \(subView) \(subView.frame)")
//            }
//
//            print("Landscape")
//        } else {
//            // Portrait
//            let subViews = self.scrollView.subviews
//             var i = 0
//            
//            for subView in subViews {
//                let xPosition = self.view.frame.width * CGFloat(i)
//                i += 1
//                
//                subView.contentMode = .scaleAspectFit
//                subView.frame = CGRect(x: xPosition, y:0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
//                
//                
//                print("SubView ===========  \(subView) \(subView.frame)")
//            }
//            print("Portrait")
//        }
//
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
