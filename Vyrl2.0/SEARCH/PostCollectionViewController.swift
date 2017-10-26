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

class PostCollectionViewController : UICollectionViewController {
    
    var type : PostType = .Fan
    var hotPosts = [HotPost]()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.getHotPost()
        
        self.collectionView?.delegate = nil
        self.collectionView?.dataSource = nil
        
        self.searchHotPost()
        self.setHotPostCollectionCellTapHandling()
    }
    
    func searchHotPost(){
        let officialAccountObservable : Observable<[Article]> = SearchAPI.sharedAPI.suggestPosts()
        officialAccountObservable.bind(to: (self.collectionView?.rx.items(cellIdentifier: "post", cellType: PostCollectionCell.self))!) {
            (index, article , cell) in
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
            }.addDisposableTo(disposeBag)
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

class PostCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var imageCount: UILabel!
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
        id <- map["id"]
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
