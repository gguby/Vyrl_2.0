//
//  DetailViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 9. 22..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import GrowingTextView
import AVFoundation
import Alamofire
import ObjectMapper
import NSDate_TimeAgo
import NukeFLAnimatedImagePlugin
import FLAnimatedImage

class DetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var article : Article?
    var articleId : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestFeedDetail()
        tableView.tableFooterView = UIView(frame: .zero)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        } else {
            // Fallback on earlier versions
        }
    }
    
    func requestFeedDetail() {
        let url = URL.init(string: Constants.VyrlFeedURL.feed(articleId: articleId))
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseObject { (response: DataResponse<Article>) in
            let article = response.result.value
            self.article = article
             self.tableView.reloadData()
        }
    }
}

extension DetailViewController : UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 700
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "oneFeed") as! DetailTableCell
        if(self.article != nil) {
            cell.article = self.article
            if((self.article?.medias.count)! > 0){
                cell.imageScrollView.isHidden = false
                cell.pageLabel.isHidden = false
                
                cell.initImageVideo()
            } else {
                cell.imageScrollView.isHidden = true
                cell.pageLabel.isHidden = true
            }
            
            cell.contentTextView.text = self.article?.content
            cell.contentTextView.resolveHashTags()
              
            cell.pageLabel.text = String("1 / \((self.article?.medias.count)!)")
            
            cell.profileButton.af_setBackgroundImage(for: .normal, url: URL.init(string: (self.article?.profile.imagePath)!)!)
            cell.nickNameLabel.text = self.article?.profile.nickName
            
            cell.profileId = self.article?.profile.id
           
        }
        return cell

    }
}

protocol DetailTableCellProtocol {
    func profileButtonDidSelect(profileId : Int)
    func imageDidSelect(profileId : Int)
}

class DetailTableCell : UITableViewCell {
    var article : Article!
    var imageViewArray : [UIImageView] = []
    var subScrollViewArray : [UIScrollView] = []
    var lastRequestIndex : Int = 0;
    var currentIndex : Int = 0;
    var profileId : Int!
    var delegate: DetailTableCellProtocol!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var shareCountButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    @IBOutlet weak var videoPlayButton: UIButton!
    
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

extension DetailTableCell : UIScrollViewDelegate {
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
