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
import RxCocoa
import RxSwift
import RxDataSources

@objc protocol FeedCellDelegate {
    
    func didPressCell(sender: Any, cell : FeedTableCell)
     @objc optional func showFanPage(cell : FeedTableCell)
    
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
    
    @IBOutlet weak var subTitle: UILabel!
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var firstCommentView: UIView!
    @IBOutlet weak var firstCommentNicknameButton: UIButton!
    @IBOutlet weak var firstCommentContent: UILabel!
    
    @IBOutlet weak var secondCommentView: UIView!
    @IBOutlet weak var secondCommentNicknameButton: UIButton!
    @IBOutlet weak var seconCommentContent: UILabel!
    
    @IBOutlet weak var officialImage: UIImageView!
    @IBOutlet weak var followBtn: UIButton!
    
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var fanView: UIView!
    @IBOutlet weak var fanPageLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var likeView: UIView!
    var nativeAd :FBNativeAd!
    
    var adLoader: GADAdLoader!
    
    var cellWidth = 124

    var delegate: FeedCellDelegate!
    
    var isAdTypeGoogle = false
    var isAdTypeFaceBook = false
    
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
                
                self.iconView.isHidden = true
                
                if(self.article?.medias[0].type == "VIDEO")
                {
                    let playImage = UIImage.init(named: "icon_play_01")
                    self.iconView.image = playImage
                    self.iconView.isHidden = false
                }
                
                if(url.pathExtension == "gif")
                {
                    let gifImage = UIImage.init(named: "icon_gif_01")
                    self.iconView.image = gifImage
                    self.iconView.isHidden = false
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
            
            if (article?.isFanPageType)! {
                self.fanView.isHidden = false
                self.fanPageLabel.text = article?.fanPageName
            } else {
                self.fanView.isHidden = true
            }
            
            self.officialImage.isHidden  = true
            
            let likeUsers = self.article?.likeUsers
            
            if ( likeUsers?.count != 0 ){
                var text = likeUsers![0] + "님, " + likeUsers![1] + "님 외 "
                text += (self.article?.likeCount)! + "이 좋아합니다."
                self.likeLabel.text = text
            }else {
                self.likeView.isHidden = true
            }
            
            self.followBtn.addTarget(self, action: #selector(followUser(sender:)), for: .touchUpInside)
            self.comment.addTarget(self, action: #selector(showCommentDetail(sender:)), for: .touchUpInside)
            self.likeBtn.addTarget(self, action: #selector(like(sender:)), for: .touchUpInside)
            self.share.addTarget(self, action: #selector(doShare(sender:)), for: .touchUpInside)
            self.bookmarkBtn.addTarget(self, action: #selector(doBookMark(sender:)), for: .touchUpInside)
            
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
            
            Observable.just(self.article?.medias).map {(customDatas) -> [Section] in
                [Section(model: "FirstSection", items: customDatas!)]
                }.bind(to: sections).addDisposableTo(disposeBag)
        }
    }
    
    let disposeBag = DisposeBag()
    
    typealias Section = SectionModel<String, ArticleMedia>
    private let sections = Variable<[Section]>([])
    private let dataSource = RxCollectionViewSectionedReloadDataSource<Section>()
    
    func configure(){
        dataSource.configureCell =  { ds, cv, ip, item in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BoxCell", for: ip) as! BoxCell
            
            if (self.article?.medias.count)! > 6 && ip.row == 5 {
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
            
            cell.imageView.af_setImage(withURL: URL(string: item.imageUrl)!)
            cell.iconImageView.image = nil
            if(item.type == "VIDEO")
            {
                let playImage = UIImage.init(named: "icon_play_01")
                cell.iconImageView.image = playImage
            }
            
            if(URL.init(string: item.imageUrl)?.pathExtension == "gif")
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
        
        sections.asDriver().drive(self.collectionView.rx.items(dataSource: dataSource)).addDisposableTo(disposeBag)
        
        collectionView.rx.setDelegate(self).addDisposableTo(disposeBag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if(self.collectionView != nil) {

            let size = UIScreen.main.bounds
            self.configure()
       
            if (size.width > 375){
                self.collectionViewLeading.constant = 20
            }
        }
        
        if(self.contentTextView != nil) {
            self.contentTextView.textContainerInset = UIEdgeInsets.zero
            self.contentTextView.textContainer.lineFragmentPadding = 0
        }
        
        self.initGoogleAD()
        
        self.initFBAD()
    }
    
    func initFBAD(){
        
        if isAdTypeFaceBook == false {
            return
        }
        
        let placeMentID = "150088642241764_165434230707205"
        nativeAd = FBNativeAd(placementID: placeMentID)
        nativeAd.delegate = self
        nativeAd.mediaCachePolicy = FBNativeAdsCachePolicy.all
        nativeAd.load()
    }
    
    func initGoogleAD(){
        if isAdTypeGoogle == false {
            return
        }
        var adTypes = [GADAdLoaderAdType]()
        adTypes.append(GADAdLoaderAdType.nativeContent)
        
        adLoader = GADAdLoader(adUnitID: Constants.GoogleADTest, rootViewController: self.delegate as? UIViewController,
                               adTypes: adTypes, options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if self.photo != nil {
            self.photo.image = nil
        }
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
    
    @IBAction func showFanPage(_ sender: UIButton) {
        delegate.showFanPage!(cell: self)
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
    
    func doShare(sender:UIButton){
        delegate.showFeedShareAlert!(cell: self)
    }
    
    func doBookMark(sender:UIButton){
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

extension FeedTableCell: UICollectionViewDelegate {
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

extension FeedTableCell : FBNativeAdDelegate {
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        if self.nativeAd != nil {
            self.nativeAd.unregisterView()
        }
        
        self.nativeAd = nativeAd
        
        nativeAd.icon?.loadAsync(block: { (image) in
            self.profileButton.setImage(image, for: UIControlState.normal)
        })
        
        nativeAd.coverImage?.loadAsync(block: {
            (image) in
            self.photo.image = image
        })
        
        self.nickNameLabel.text = nativeAd.title
        self.subTitle.text = nativeAd.subtitle
        self.contentTextView.text = nativeAd.body
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        
    }
}

class BoxCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var mediaCount: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
