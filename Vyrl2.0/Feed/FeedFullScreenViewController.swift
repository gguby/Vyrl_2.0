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

    @IBOutlet weak var scrollView: UIScrollView!
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
        scrollView.frame = view.frame
        let url1 = NSURL(string: "http://techslides.com/demos/sample-videos/small.mp4")
        playerItem = AVPlayerItem(url: url1! as URL)
        player = AVPlayer(playerItem: playerItem!)
        
        for i in 0..<(samplePhotos.count) {
            imageView = UIImageView()
            
            if(i == 4){
                let url = NSURL(string: "https://s3.amazonaws.com/vids4project/sample.mp4")
                
                
                let playerLayer = AVPlayerLayer(player: player!)
                let xPosition = self.view.frame.width * CGFloat(i)
                playerLayer.frame = CGRect(x: xPosition, y:0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
                
                imageView.frame = playerLayer.videoRect
                imageView.layer.addSublayer(playerLayer)
                
                scrollView.contentSize.width = scrollView.frame.width * CGFloat(i+1)
                

            } else {
                imageView.image = samplePhotos[i]
                imageView.contentMode = .scaleAspectFit
                let xPosition = self.view.frame.width * CGFloat(i)
                imageView.frame = CGRect(x: xPosition, y:0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
                
                scrollView.contentSize.width = scrollView.frame.width * CGFloat(i+1)
            
//                let textView = UITextView()
//                textView.text = "안녕하세요 \n 안녕하세요 \n 안녕하세요 \n 안녕하세요 \n 안녕하세요 \n  안녕하세요 \n 안녕하세요 \n"
//                let yPosition = imageView.frame.origin.y
//                textView.frame = CGRect(x: xPosition, y: yPosition, width: self.scrollView.frame.width, height: textView.frame.height)
//                
//               scrollView.addSubview(textView)
            }
        
            scrollView.addSubview(imageView)
        }

    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
        let subViews = self.scrollView.subviews
        for subView in subViews {
            subView.removeFromSuperview()
        }
    }

    
    func canRotate() -> Void {
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
