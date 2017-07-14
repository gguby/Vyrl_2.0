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
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    
    let samplePhotos = [UIImage(named: "github1"),
                                UIImage(named: "github2"),
                                UIImage(named: "github3"),
                                UIImage(named: "github4"),
                                UIImage(named: "github5"),
                                UIImage(named: "github6"),
                                UIImage(named: "github7"),
                                UIImage(named: "github8"),
                                UIImage(named: "github9"),
                                ]
    var imageIndex: NSInteger = 0
    
    @IBOutlet weak var pageNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.frame = view.frame
        
        let url = NSURL(string: "https://s3.amazonaws.com/vids4project/sample.mp4")
        playerItem = AVPlayerItem(url: url! as URL)
        player = AVPlayer(playerItem: playerItem!)
        
        for i in 0..<(samplePhotos.count) {
            if(i == 0 ){
                
                let playerLayer = AVPlayerLayer(player: player!)
                let xPosition = self.view.frame.width * CGFloat(i)
                playerLayer.frame = CGRect(x: xPosition, y:0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
                
                 let imageView = UIImageView()
                 imageView.frame = playerLayer.videoRect
                 imageView.layer.addSublayer(playerLayer)
                self.player?.play()
                
                scrollView.contentSize.width = scrollView.frame.width * CGFloat(i+1)
                scrollView.addSubview(imageView)
            
            } else {
                let imageView = UIImageView()
                imageView.image = samplePhotos[i] as! UIImage
                imageView.contentMode = .scaleAspectFit
                let xPosition = self.view.frame.width * CGFloat(i)
                imageView.frame = CGRect(x: xPosition, y:0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
                
                scrollView.contentSize.width = scrollView.frame.width * CGFloat(i+1)
                scrollView.addSubview(imageView)
            }
        }
    }
    
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
