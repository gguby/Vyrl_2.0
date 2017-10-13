//
//  FeedDetailTableCell.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 10. 12..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire
import NukeFLAnimatedImagePlugin
import FLAnimatedImage

protocol FeedDetailTableCellProtocol {
    func profileButtonDidSelect(profileId : Int)
    func imageDidSelect(profileId : Int)
}

class FeedDetailTableCell : UITableViewCell {
    var article : Article! {
        didSet {
            if(article.isFanPageType == true)
            {
                self.fanView.isHidden = false
                self.fanPageNameLabel.text = article.fanPageName
            } else {
                self.fanView.isHidden = true
            }
        }
    }
    var imageViewArray : [UIImageView] = []
    var subScrollViewArray : [UIScrollView] = []
    var lastRequestIndex : Int = 0;
    var currentIndex : Int = 0;
    var profileId : Int!
    var delegate: FeedDetailTableCellProtocol!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var shareCountButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var fanView: UIView!
    @IBOutlet weak var fanPageNameLabel: UILabel!
    
    @IBOutlet weak var videoPlayButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if(self.imageScrollView != nil) {
            self.imageScrollView.delegate = self as UIScrollViewDelegate
            self.contentTextView.textContainerInset = UIEdgeInsets.zero
            self.contentTextView.textContainer.lineFragmentPadding = 0
        }
    }
    
    @IBAction func translateContent(_ sender: UIButton) {
        let uri = URL.init(string: Constants.VyrlFeedURL.translate(id: article.id, type: .article))
        
        Alamofire.request(uri!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString { (response) in
            switch response.result {
            case .success(let result) :
                print(result)
                
                if let code = response.response?.statusCode {
                    if code == 200 {
                        self.contentTextView.text = result
                    }
                }
            case .failure(let error) :
                print(error)
            }
        }
    }
    
    func initImageVideo() {
        self.lastRequestIndex = 0
        
        for i in 0..<(article.medias.count) {
            var contentImageView : UIImageView
            
            let url = URL.init(string: article.medias[i].imageUrl)
            if(url?.pathExtension == "gif")
            {
                contentImageView = FLAnimatedImageView()
            } else {
                
                contentImageView = UIImageView()
            }
            
            self.imageViewArray.append(contentImageView)
            
            let subScrollView = UIScrollView()
            subScrollView.frame = CGRect.init(x: 0, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            subScrollView.addGestureRecognizer(tapGestureRecognizer)
            
            self.subScrollViewArray.append(subScrollView)
            self.imageScrollView.contentSize.width = self.imageScrollView.frame.width * CGFloat(i+1)
            self.imageScrollView.addSubview(subScrollView)
        }
        
        self.requestImageVideo()
        self.showVideoButton()
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.delegate.imageDidSelect(profileId: profileId)
    }
    
    func requestImageVideo() {
        
        var uri : URL
        uri = URL.init(string: article.medias[lastRequestIndex].imageUrl!)!
        
        Alamofire.request(uri)
            .downloadProgress(closure: { (progress) in
                
            }).responseData { response in
                if let data = response.result.value {
                    if(uri.pathExtension == "gif") {
                        (self.imageViewArray[self.lastRequestIndex] as! FLAnimatedImageView).animatedImage = FLAnimatedImage.init(animatedGIFData: data)
                    } else {
                        self.imageViewArray[self.lastRequestIndex].image =  UIImage(data: data)!
                    }
                    self.imageViewArray[self.lastRequestIndex].contentMode = .scaleAspectFit
                    self.imageViewArray[self.lastRequestIndex].frame = CGRect.init(x: 0, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
                    
                    self.subScrollViewArray[self.lastRequestIndex].addSubview(self.imageViewArray[self.lastRequestIndex])
                    
                    let xPosition = self.imageScrollView.frame.width * CGFloat(self.lastRequestIndex)
                    self.subScrollViewArray[self.lastRequestIndex].frame = CGRect.init(x: xPosition, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
                }
        }
    }
    
    func showVideoButton() {
        if(self.article.medias[currentIndex].type == "VIDEO")
        {
            self.videoPlayButton.isHidden = false
        } else {
            self.videoPlayButton.isHidden = true
        }
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        let uri : URL = URL.init(string: self.article.medias[currentIndex].url!)!
        
        if(self.imageViewArray[currentIndex].layer.sublayers != nil) {
            self.imageViewArray[currentIndex].layer.sublayers?.removeAll()
        }
        
        self.player?.pause()
        
        self.playerItem = AVPlayerItem.init(url: uri)
        self.player = AVPlayer.init(playerItem: self.playerItem)
        
        self.playerLayer = AVPlayerLayer(player: player)
        self.imageViewArray[currentIndex].layer.addSublayer(self.playerLayer!)
        self.playerLayer?.frame = self.imageViewArray[currentIndex].frame
        
        self.player?.play()
        
        self.videoPlayButton.isHidden = true
    }
    
    @IBAction func profileButtonClick(_ sender: UIButton) {
        delegate.profileButtonDidSelect(profileId: self.profileId)
    }
    
    
}

extension FeedDetailTableCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("\(#function)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("\(#function)")
        self.showVideoButton()
        
        let page = Int(round(Double(scrollView.contentOffset.x) / Double(scrollView.bounds.size.width)))
        self.currentIndex = page
        self.pageLabel.text =  String("\(page+1) / \(self.article.medias.count)")
        
        if(page > self.lastRequestIndex) {
            self.lastRequestIndex = page
            self.requestImageVideo()
        }
    }
    
}
