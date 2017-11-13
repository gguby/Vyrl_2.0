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
    var hotPosts = [HotPost]()
    
    let disposeBag = DisposeBag()
    
    var aritlces = [Article]()
    var hashTagString : String = ""
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfArticleData>()
    private let sections = Variable<[SectionOfArticleData]>([])
    
    var cellSizeWidth = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.delegate = nil
        self.collectionView?.dataSource = nil
        
        self.initPostTable()
        
        self.getSearchSuggestPost()
       
        self.setHotPostCollectionCellTapHandling()
        self.collectionView?.rx.setDelegate(self).addDisposableTo(disposeBag)
        
        let size = UIScreen.main.bounds
        self.cellSizeWidth = Int(size.width / 3)
    }
    
    func refresh(){
       self.getSearchSuggestPost()
    }
    
    func getSearchSuggestPost(){
        let uri = Constants.VyrlSearchURL.suggestPostList
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            
            response.result.ifFailure {
                return
            }
            
            self.aritlces.removeAll()
            
            let array = response.result.value ?? []
            
            for (i, article) in array.enumerated() {
                
                self.aritlces.append(article)
                
                if i % 5 == 0 && i != 0 && article.medias.count > 0 {
                    let adArticle = Article.init()
                    self.aritlces.append(adArticle)
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
            
            let str = article.medias[0].url
            let url : URL = URL.init(string: str!)!
            cell.imageView.af_setImage(withURL: url)
            
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
                let vc : FeedDetailViewController = self.pushViewControllrer(storyboardName: "FeedDetail", controllerName: "FeedDetailViewController") as! FeedDetailViewController
                vc.articleId = article.id
            }).addDisposableTo(disposeBag)
    }
    
    
    func getHotPost(){
        let url = URL.init(string: Constants.VyrlFanAPIURL.HOTPOST)
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[HotPost]>) in
            
            self.hotPosts.removeAll()
            
            let array = response.result.value ?? []
            
            for post in array {
                self.hotPosts.append(post)
            }
            
            self.collectionView!.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath)
        
        return cell
    }
    
     override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.hotPosts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension PostCollectionViewController : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let article = self.aritlces[indexPath.row]

        if article.type == ArticleType.googleAdFeed || article.type == ArticleType.FBAdFeed {
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
}

struct HotPost : Mappable {
    
    var fanPageId : Int!
    var fanPagePostId : Int!
    
    var content : String!
    var mediaPath : String!
    var type : String!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        fanPageId <- map["fanPageId"]
        content <- map["content"]
        fanPagePostId <- map["fanPagePostId"]
        mediaPath <- map["mediaPath"]
        type <- map["type"]
    }
}

struct Profile : Mappable {
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    init?(map: Map) {
        
    }
    var id : Int!
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
        id <- map["userId"]
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
