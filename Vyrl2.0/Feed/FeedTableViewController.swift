//
//  FeedTableViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 7..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import KRPullLoader
import AVFoundation

class FeedTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , KRPullLoadViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    var articleArray = [Article]()
    
    var refreshControl : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getAllFeed()

        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
        tableView.tableFooterView = UIView(frame: .zero)
        
        let refreshView = KRPullLoadView()
        refreshView.delegate = self
        tableView.addPullLoadableView(refreshView, type: .refresh)       
    }
    
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType){
        switch state {
        case let .loading(completionHandler):
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                completionHandler()
                self.getAllFeed()
            }
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func photoClick(_ sender: UIButton) {
        self.pushView(storyboardName: "Feed", controllerName: "FeedFullScreenViewController")
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.articleArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
       
        var cell  = tableView.dequeueReusableCell(withIdentifier: "oneFeed") as! FeedTableCell
        
//        switch indexPath.row {
//        case 0:
//            cell = tableView.dequeueReusableCell(withIdentifier: "oneFeed") as! FeedTableCell
//            break
//        case 1:
//            cell = tableView.dequeueReusableCell(withIdentifier: "advertisingFeed") as! FeedTableCell
//            break
//        case 2:
//            cell = tableView.dequeueReusableCell(withIdentifier: "textOnlyFeed") as! FeedTableCell
//            break
//        case 3:
//            cell = tableView.dequeueReusableCell(withIdentifier: "multiFeed") as! FeedTableCell
//            break
//        case 4:
//            cell = tableView.dequeueReusableCell(withIdentifier: "channelFeed") as! FeedTableCell
//            break
//        default: break
//        }
        
        let article = self.articleArray[indexPath.row]

        cell = tableView.dequeueReusableCell(withIdentifier: article.type.rawValue, for: indexPath) as! FeedTableCell
        cell.article = article
        cell.contentLabel.text = article.content
        
        return cell
    }

    func getAllFeed(){
        self.articleArray.removeAll()
        
        let url = URL.init(string: Constants.VyrlFeedURL.FEED)
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            
                let array = response.result.value ?? []
            
                for article in array {
                    self.articleArray.append(article)
                }
            
            self.tableView.reloadData()
        }
    }
}

public enum ArticleType : String{
    case oneFeed   = "oneFeed"
    case multiFeed = "multiFeed"
    case textOnlyFeed = "textOnlyFeed"
}

struct Article : Mappable {
    var type : ArticleType!
    
    var id : Int!
    var content : String!
    
    var images : [String]!
    var videos : [String]!
    
    var medias : [String]!
    
    var comments : [String]!
    var cntComment : Int!
    var cntLike : Int!
    
    var mediaCount : Int!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        id <- map["id"]
        content <- map["content"]
        images <- map["images"]
        videos <- map["videos"]
        cntComment <- map["cntComment"]
        cntLike <- map["cntLike"]
        comments <- map["comments"]
        
        self.setUpType()
    }
    
    mutating func setUpType(){
        self.medias = self.images + self.videos
        self.mediaCount = self.medias.count
        if ( self.mediaCount > 1){
            type = ArticleType.multiFeed
        }else if ( self.mediaCount == 1){
            type = ArticleType.oneFeed
        }else if ( self.mediaCount == 0){
            type = ArticleType.textOnlyFeed
        }        
    }
}



