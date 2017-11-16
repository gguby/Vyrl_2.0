//
//  PostCollectionViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 8. 9..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import RxCocoa
import RxSwift
import RxDataSources
import GoogleMobileAds
import FBAudienceNetwork

class PostCollectionViewController : UICollectionViewController {
    
    var type : PostType = .Fan
    let disposeBag = DisposeBag()
    
    var aritlces = [Article]()
    var hashTagString : String = ""
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfArticleData>()
    private let sections = Variable<[SectionOfArticleData]>([])
    
    var fanPageId = 0
    var userId = 0
    
    var cellSizeWidth = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.delegate = nil
        self.collectionView?.dataSource = nil
        
        self.initPostTable()
        
        self.getPostMedias()
        
        self.setHotPostCollectionCellTapHandling()
        self.collectionView?.rx.setDelegate(self).addDisposableTo(disposeBag)
        
        let size = UIScreen.main.bounds
        self.cellSizeWidth = Int(size.width / 3)
    }
    
    func refresh(){
        self.getPostMedias()
    }
    
    func getPostMedias(){
        
        var id = self.fanPageId
        
        if self.type == .User {
            id = self.userId
        }
        
        let uri = self.type.getApiString(id: id)
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            
            response.result.ifFailure {
                return
            }
            
            self.aritlces.removeAll()
            
            let array = response.result.value ?? []
            
            for (i, article) in array.enumerated() {
                self.aritlces.append(article)
                
                if ( self.type == .Fan) {
                    if i % 5 == 0 && i != 0 && article.medias.count > 0 {
                        let post = Article.init()
                        self.aritlces.append(post)
                    }
                }
            }
            
            self.sections.value = [SectionOfArticleData(items:self.aritlces)]
        }
    }
    
    func initPostTable(){
        Observable.just(self.aritlces).map {(customDatas) -> [SectionOfArticleData] in
            [SectionOfArticleData(items: customDatas)]
            }.bind(to: self.sections).addDisposableTo(self.disposeBag)
        
        dataSource.configureCell = { ds, cv, ip, article in
            
            if article.type == ArticleType.googleAdFeed || article.type == ArticleType.FBAdFeed {
                let cell = cv.dequeueReusableCell(withReuseIdentifier: article.type.rawValue, for: ip) as! PostCollectionCell
                cell.vc = self
                return cell
            }
            
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "post", for: ip) as! PostCollectionCell
            
            if article.medias.count > 0 {
                let str = article.medias[0].imageUrl
                let url : URL = URL.init(string: str!)!
                cell.imageView.af_setImage(withURL: url)
            }
            
            if article.medias.count > 1 {
                cell.centerView.isHidden = false
                cell.imageCount.text = "\(article.medias.count)"
            }
            else {
                cell.centerView.isHidden = true
            }
            
            return cell
        }
        
        sections.asDriver().drive((collectionView?.rx.items(dataSource: self.dataSource))!).addDisposableTo(disposeBag)
    }
    
    func setHotPostCollectionCellTapHandling(){
        self.collectionView?.rx.modelSelected(Article.self)
            .subscribe(onNext: {
                article in
                if self.type == .Fan {
                    let vc = self.pushViewControllrer(storyboardName: "Fan", controllerName: "FanPage") as! FanPageController
                    vc.fanPageId = article.fanPageId
                }else {
                    let vc : FeedDetailViewController = self.pushViewControllrer(storyboardName: "FeedDetail", controllerName: "FeedDetailViewController") as! FeedDetailViewController
                    vc.articleId = article.id
                }
            }).addDisposableTo(disposeBag)
    }
}

extension PostCollectionViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let post = self.aritlces[indexPath.row]

        if post.type == ArticleType.googleAdFeed || post.type == ArticleType.FBAdFeed {
            return CGSize(width: collectionView.frame.size.width, height: 124)
        }else {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let totalSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(3 - 1))
            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(3))
            return CGSize(width: size, height: size)
        }
    }
}

class PostCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var imageCount: UILabel!
    
    var nativeAd :FBNativeAd!
    var adLoader: GADAdLoader!
    
    @IBOutlet weak var gadContentView: GADNativeContentAdView!
    @IBOutlet weak var gadInstallView: GADNativeAppInstallAdView!
    
    var vc : UIViewController!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        if self.reuseIdentifier == ArticleType.FBAdFeed.rawValue {
            self.initFBAD()
        }else if self.reuseIdentifier == ArticleType.googleAdFeed.rawValue {
            self.initGoogleAD()
        }
    }
    
    func initFBAD(){
        let placeMentID = "150088642241764_165434230707205"
        nativeAd = FBNativeAd(placementID: placeMentID)
        nativeAd.delegate = self
        nativeAd.mediaCachePolicy = FBNativeAdsCachePolicy.coverImage
        nativeAd.load()
    }
    
    func initGoogleAD(){
        var adTypes = [GADAdLoaderAdType]()
        adTypes.append(GADAdLoaderAdType.nativeContent)
        adTypes.append(GADAdLoaderAdType.nativeAppInstall)
        
        adLoader = GADAdLoader(adUnitID: Constants.GoogleADTest, rootViewController: vc,
                               adTypes: adTypes, options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
}

extension PostCollectionCell : GADNativeContentAdLoaderDelegate , GADNativeAppInstallAdLoaderDelegate{
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd){
        
        nativeContentAd.rootViewController = self.vc
        self.gadContentView.nativeContentAd = nativeContentAd

        (self.gadContentView.callToActionView as! UIButton).isUserInteractionEnabled = false

        let firstImage: GADNativeAdImage? = nativeContentAd.images?.first as? GADNativeAdImage
        (self.gadContentView.callToActionView as! UIButton).setBackgroundImage(firstImage?.image, for: .normal)

        self.gadInstallView.isHidden = true
        self.gadContentView.isHidden = false
    }
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAppInstallAd: GADNativeAppInstallAd){
        
        nativeAppInstallAd.rootViewController = self.vc

        self.gadInstallView.nativeAppInstallAd = nativeAppInstallAd

        (self.gadInstallView.callToActionView as! UIButton).isUserInteractionEnabled = false

        let firstImage: GADNativeAdImage? = nativeAppInstallAd.images?.first as? GADNativeAdImage
        (self.gadInstallView.callToActionView as! UIButton).setBackgroundImage(firstImage?.image, for: .normal)

        self.gadInstallView.isHidden = false
        self.gadContentView.isHidden = true
    }
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError){
        print(adLoader.adUnitID)
    }
}

extension PostCollectionCell : FBNativeAdDelegate {
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        if self.nativeAd != nil {
            self.nativeAd.unregisterView()
        }
        
        self.nativeAd = nativeAd
        
        nativeAd.coverImage?.loadAsync(block: {
            (image) in
            self.imageView.image = image
        })

        nativeAd.registerView(forInteraction: self.imageView, with: self.vc)
    }
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        
    }
}

enum PostType {
    case Search
    case Fan
    case My
    case FanPage
    case User
    
    func getApiString(id : Int) -> String {
        switch self {
        case .Search:
            return Constants.VyrlSearchURL.suggestPostList
        case .My :
            return Constants.VyrlFeedURL.FEEDMEDIA
        case .FanPage :
            return Constants.VyrlFanAPIURL.getFanPagePostMedias(fanPageId: id)
        case .Fan :
            return Constants.VyrlFanAPIURL.HOTPOST
        case .User :
            return Constants.VyrlFeedURL.feedOtherMedias(userId:id)
        }
    }
}

struct Profile : Mappable {
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    init?(map: Map) {
        
    }
    var userId : Int!
    var email : String!
    var nickName : String!
    var imagePath : String!
    var createdAt : String!
    var homepageUrl : String!
    var selfIntro : String!
    var socialType : String!
    var follow : Bool!
    
    var date : Date?
    
    mutating func mapping(map: Map){
        userId <- map["userId"]
        email <- map["email"]
        nickName <- map["nickName"]
        imagePath <- map["imagePath"]
        createdAt <- map["createdAt"]
        homepageUrl <- map["homepageUrl"]
        selfIntro <- map["selfIntro"]
        socialType <- map["socialType"]
        follow <- map["follow"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let dateString = map["createdAt"].currentValue as? String, let _date = dateFormatter.date(from: dateString){
            date = _date
        }
    }
}

struct ArticlePost {
    var article : Article!
    var type : String!
    
    init(_ article:Article) {
        self.article = article
    }
}
