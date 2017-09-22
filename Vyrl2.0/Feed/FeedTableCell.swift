//
//  FeedTableCell.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 7. 24..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import NSDate_TimeAgo
import GoogleMobileAds
import FBAudienceNetwork

@objc protocol FeedCellDelegate {
    
    func didPressCell(sender: Any, cell : FeedTableCell)
    
    @objc optional func didPressPhoto(sender: Any, cell : FeedTableCell)
    @objc optional func setBookMark(cell : FeedTableCell)
    @objc optional func showFeedAlert(cell : FeedTableCell)
    @objc optional func showFeedShareAlert(cell : FeedTableCell)
    @objc optional func showUserProfileView(userId : Int)    
}

class FeedTableCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewLeading: NSLayoutConstraint!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var cntLike: UIButton!
    
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var comment: UIButton!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var firstCommentView: UIView!
    @IBOutlet weak var firstCommentNicknameButton: UIButton!
    @IBOutlet weak var firstCommentContent: UILabel!
    
    
    @IBOutlet weak var secondCommentView: UIView!
    @IBOutlet weak var secondCommentNicknameButton: UIButton!
    @IBOutlet weak var seconCommentContent: UILabel!
    
    @IBOutlet weak var officialImage: UIImageView!
    @IBOutlet weak var followBtn: UIButton!
    
    var nativeAd :FBNativeAd!
    
    var adLoader: GADAdLoader!
    
    var cellWidth = 124

    var delegate: FeedCellDelegate!
    
    var isAdTypeGoogle = false
    
    var isMyArticle : Bool! {
        didSet {
            if isMyArticle {
                self.followBtn.alpha = 0
            }
        }
    }
    
    var isBookMark : Bool! {
        didSet {
            if isBookMark {
                self.bookmarkBtn.setImage(UIImage.init(named: "icon_bookmark_01_on"), for: .normal)
            } else {
                self.bookmarkBtn.setImage(UIImage.init(named: "icon_bookmark_01_off"), for: .normal)
            }
        }
    }
    
    var article : Article? {
        didSet{
            
            var count = article?.medias.count
            
            if ( count == 1 ){
                let str = article?.medias[0].url
                let url : URL = URL.init(string: str!)!
                self.photo.af_setImage(withURL: url)
                
                if(self.article?.medias[0].type == "VIDEO")
                {
                    let playImage = UIImage.init(named: "icon_play_01")
                    let subImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: (playImage?.size.width)!, height: (playImage?.size.height)!))
                    subImageView.center = CGPoint.init(x: self.photo.frame.size.width/2, y: self.photo.frame.size.height/2)
                    subImageView.image = playImage
                    
                    self.photo.addSubview(subImageView)
                }
                
                if(url.pathExtension == "gif")
                {
                    let gifImage = UIImage.init(named: "icon_gif_01")
                    let subImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: (gifImage?.size.width)!, height: (gifImage?.size.height)!))
                    subImageView.center = CGPoint.init(x: self.photo.frame.size.width/2, y: self.photo.frame.size.height/2)
                    subImageView.image = gifImage
                    
                    self.photo.addSubview(subImageView)
                }

            }
            
            
            
            self.cntLike.setTitle(article?.likeCount, for: .normal)
            
            self.comment.setTitle(article?.commentCount, for: .normal)

            self.profileButton.addTarget(self, action: #selector(showProfile(sender:)), for: .touchUpInside)
            self.profileButton.tag = (article?.profile.id)!
            if article?.profile.imagePath != nil {
                if let url = URL.init(string:(article?.profile.imagePath)!) {
                    self.profileButton.af_setBackgroundImage(for: .normal, url: url)
                }
            }
            
            self.nickNameLabel.text = article?.profile.nickName
            self.timeLabel.text = (article?.date! as! NSDate).timeAgo()
            
            if let str = article?.location {
                self.locationLabel.text = str + "에서"
            }
            
            if(article?.cntComment == 0) {
                self.commentView.isHidden = true
            } else if (article?.cntComment == 1){
                self.commentView.isHidden = false
                self.secondCommentView.isHidden = true
                
                self.firstCommentNicknameButton.setTitle(article?.comments[0].nickName, for: .normal)
                self.firstCommentContent.text = article?.comments[0].content
                self.firstCommentNicknameButton.tag = (article?.comments[0].userId)!
                self.firstCommentNicknameButton.addTarget(self, action: #selector(showProfile(sender:)), for: .touchUpInside)
            } else {
                self.commentView.isHidden = false
                self.secondCommentView.isHidden = false
                
                self.firstCommentNicknameButton.setTitle(article?.comments[0].nickName, for: .normal)
                self.firstCommentContent.text = article?.comments[0].content
                self.firstCommentNicknameButton.tag = (article?.comments[0].userId)!
                self.firstCommentNicknameButton.addTarget(self, action: #selector(showProfile(sender:)), for: .touchUpInside)

                self.secondCommentNicknameButton.setTitle(article?.comments[1].nickName, for: .normal)
                self.seconCommentContent.text = article?.comments[1].content
                self.secondCommentNicknameButton.tag = (article?.comments[1].userId)!
                self.secondCommentNicknameButton.addTarget(self, action: #selector(showProfile(sender:)), for: .touchUpInside)
            }
            
            if self.article?.openYn == false {
                self.share.alpha = 0
            }
            
            self.share.setTitle(article?.shareCount, for: .normal)
            
            self.isBookMark = (article?.isBookMark)!
            self.isMyArticle = article?.isMyArticle
            
            if self.isMyArticle == false && article?.profile.follow == false {
                self.followBtn.alpha = 1
            }
            
            if (article?.isLike)! {
                self.likeBtn.setImage(UIImage.init(named: "icon_heart_01_on"), for: .normal)
                self.likeBtn.tag = 1
            } else {
                self.likeBtn.setImage(UIImage.init(named: "icon_heart_01"), for: .normal)
                self.likeBtn.tag = 0
            }
            
            self.officialImage.isHidden  = true
            
            guard self.collectionView != nil else {
                return
            }
  
            if ( count == 2 ){
                cellWidth = 186
            }else {
                cellWidth = 124
            }
            
            if ( count! > 6){
                count = 6
            }
            
            contentHeight.constant = CGFloat(ceilf( Float(count!) / 3) * Float(cellWidth))
            
            self.collectionView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if(self.collectionView != nil) {
            self.collectionView.delegate = self as UICollectionViewDelegate
            self.collectionView.dataSource = self as UICollectionViewDataSource
            
            let size = UIScreen.main.bounds
       
            if (size.width > 375){
                self.collectionViewLeading.constant = 20
            }            
        }
        
        if(self.contentTextView != nil) {
            self.contentTextView.textContainerInset = UIEdgeInsets.zero
            self.contentTextView.textContainer.lineFragmentPadding = 0
            
//            self.contentTextView.textContainer.maximumNumberOfLines = 3
//            self.contentTextView.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail            
        }
        
        self.followBtn.addTarget(self, action: #selector(followUser(sender:)), for: .touchUpInside)
        self.comment.addTarget(self, action: #selector(showCommentDetail(sender:)), for: .touchUpInside)
        self.likeBtn.addTarget(self, action: #selector(like(sender:)), for: .touchUpInside)
        
        if isAdTypeGoogle {
            var adTypes = [GADAdLoaderAdType]()
            adTypes.append(GADAdLoaderAdType.nativeContent)
            
            adLoader = GADAdLoader(adUnitID: Constants.GoogleADTest, rootViewController: self.delegate as? UIViewController,
                                   adTypes: adTypes, options: nil)
            adLoader.delegate = self
            adLoader.load(GADRequest())
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func photoClick(_ sender: UIButton) {
        delegate.didPressPhoto!(sender: sender, cell: self)
    }
    
    func reloadContext(){
//        contentTextView.resolveHashTags()
    }
    
    func showCommentDetail(sender:UIButton){
        delegate.didPressCell(sender: sender, cell: self)
    }
    
    func showProfile(sender:UIButton){
        delegate.showUserProfileView!(userId: sender.tag)
    }
    
    func followUser(sender:UIButton)
    {
        let uri = URL.init(string: Constants.VyrlFeedURL.follow(followId: (self.article?.profile.id)!))
        Alamofire.request(uri!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
            response in switch response.result {
            case .success(let json):
                self.isMyArticle = true
                print(json)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func like(sender:UIButton){
        var method = HTTPMethod.post
        
        if sender.tag == 1 {
            method = HTTPMethod.delete
        }
        
        let uri = URL.init(string: Constants.VyrlFeedURL.feedLike(articleId: (self.article?.id)!))
        Alamofire.request(uri!, method: method, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON(completionHandler: {
            response in switch response.result {
            case .success(let json):
                
                let jsonData = json as! NSDictionary
                let cntLike = jsonData["cntLike"] as! Int
                self.cntLike.setTitle("\(cntLike)", for: .normal)
                
                if sender.tag == 0 {
                    sender.setImage(UIImage.init(named: "icon_heart_01_on"), for: .normal)
                    sender.tag = 1
                }else {
                    sender.setImage(UIImage.init(named: "icon_heart_01"), for: .normal)
                    sender.tag = 0
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    @IBAction func editFeed(_ sender: Any) {
        delegate.showFeedAlert!(cell: self)
    }
    
    @IBAction func share(_ sender: Any) {
        delegate.showFeedShareAlert!(cell: self)
    }
    
    @IBAction func setBookMark(_ sender: Any) {
        delegate.setBookMark!(cell: self)
    }    
}

extension FeedTableCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}


extension FeedTableCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (article?.medias.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxCell", for: indexPath) as! BoxCell
        
        let media : ArticleMedia = (self.article?.medias[indexPath.row])!
        
        if (self.article?.medias.count)! > 6 && indexPath.row == 5 {
            cell.dimView.alpha = 1
            cell.mediaCount.alpha = 1
            
            let str = "+\((self.article?.medias.count)! - 6)"
            
            let attributedString = NSMutableAttributedString(string: str + " 더보기")
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 13.0)!, range: NSRange(location: 0, length: str.characters.count))
            cell.mediaCount.attributedText = attributedString
        }else {
            cell.dimView.alpha = 0
            cell.mediaCount.alpha = 0
        }
        
        cell.imageView.af_setImage(withURL: URL(string: media.imageUrl)!)
        cell.iconImageView.image = nil
        if(self.article?.medias[indexPath.row].type == "VIDEO")
        {
            let playImage = UIImage.init(named: "icon_play_01")
            cell.iconImageView.image = playImage
        }
        
        if(URL.init(string: media.imageUrl)?.pathExtension == "gif")
        {
            var gifImage : UIImage!
            if((self.article?.medias.count)! > 2){
                gifImage = UIImage.init(named: "icon_gif_02")
            } else {
                gifImage = UIImage.init(named: "icon_gif_01")
            }
            
             cell.iconImageView.image = gifImage
        }


        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate.didPressCell(sender: self, cell: self)
    }
}

extension FeedTableCell : GADNativeContentAdLoaderDelegate , GADNativeAppInstallAdLoaderDelegate{
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd){
        print(nativeContentAd.headline!)
        print(nativeContentAd.body!)
        print(nativeContentAd.callToAction!)
    }
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAppInstallAd: GADNativeAppInstallAd){
        print(nativeAppInstallAd.headline!)
        print(nativeAppInstallAd.body!)
        print(nativeAppInstallAd.callToAction!)
        print(nativeAppInstallAd.store!)
    }
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError){
        print(adLoader.adUnitID)
    }
}

class BoxCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var mediaCount: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
}



