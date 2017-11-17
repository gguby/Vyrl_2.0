//
//  TagSearchCollectionViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 11. 13..
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

class TagSearchCollectionViewController: UIViewController {
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tagString : String = ""
    
    var type : HashTagType = .Tag
    var cellSizeWidth = 0
    var hashTagPosts = [HashTagPost]()
    
    let disposeBag = DisposeBag()
    let dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfHashTagData>()
    private let sections = Variable<[SectionOfHashTagData]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.resultLabel.text = "#\(tagString)"
        
        self.initPostTable()
        self.getHashTagPost()
        self.setHashTagPostCollectionCellTapHandling()
        
//        self.collectionView?.rx.setDelegate(self.collectionView as! UIScrollViewDelegate).addDisposableTo(disposeBag)
        let size = UIScreen.main.bounds
        self.cellSizeWidth = Int(size.width / 3)
    }
    
    func initPostTable(){
        Observable.just(self.hashTagPosts).map {(customDatas) -> [SectionOfHashTagData] in
            [SectionOfHashTagData(items: customDatas)]
            }.bind(to: self.sections).addDisposableTo(self.disposeBag)
        
        dataSource.configureCell = { ds, cv, ip, hashTagPost in
            
            if hashTagPost.type == HashTagType.Advertise {
                let cell = cv.dequeueReusableCell(withReuseIdentifier: ArticleType.FBAdFeed.rawValue, for: ip) as! PostCollectionCell
                cell.vc = self
                return cell
            }
            
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "post", for: ip) as! PostCollectionCell
            
            let str = hashTagPost.url
            let url : URL = URL.init(string: str!)!
            cell.imageView.af_setImage(withURL: url)
            
           cell.centerView.isHidden = true
            
            
            return cell
        }
        
        sections.asDriver().drive((collectionView?.rx.items(dataSource: self.dataSource))!).addDisposableTo(disposeBag)
    }
    
    func getHashTagPost(){
        let uri = Constants.VyrlSearchURL.searchHashTag(searchWord: tagString)
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[HashTagPost]>) in
            
            response.result.ifFailure {
                return
            }
            
            self.hashTagPosts.removeAll()
            
            let array = response.result.value ?? []
            self.postLabel.text = "\((array.count)) Posts"
            
            for hashTagPost in array {
                self.hashTagPosts.append(hashTagPost)
            }
            
            self.sections.value = [SectionOfHashTagData(items:self.hashTagPosts)]
        }
    }
    
    func setHashTagPostCollectionCellTapHandling(){
        self.collectionView?.rx.modelSelected(HashTagPost.self)
            .subscribe(onNext: {
                article in
                let vc : FeedDetailViewController = self.pushViewControllrer(storyboardName: "FeedDetail", controllerName: "FeedDetailViewController") as! FeedDetailViewController
                vc.articleId = article.articleId
            }).addDisposableTo(disposeBag)
    }
}

enum HashTagType {
    case Tag
    case Advertise
}

struct HashTagPost : Mappable {
    var id : Int!
    var articleId : Int!
    var url : String!
    var type : HashTagType = HashTagType.Tag
    
    init() {
       
    }
    
    init?(map: Map) {
       
    }
    
    mutating func mapping(map: Map){
        id <- map["id"]
        url <- map["url"]
        articleId <- map["articleId"]
    }
}

struct SectionOfHashTagData {
    var items : [Item]
}

extension SectionOfHashTagData : SectionModelType {
    typealias Item = HashTagPost
    
    init(original: SectionOfHashTagData, items: [HashTagPost]) {
        self = original
        self.items = items
    }
}


