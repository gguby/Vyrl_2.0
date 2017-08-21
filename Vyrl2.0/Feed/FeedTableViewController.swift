//
//  FeedTableViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 7..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import AVFoundation
import KRPullLoader

enum FeedTableType {
    case ALLFEED,MYFEED, BOOKMARK
}

class FeedTableViewController: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    var articleArray = [Article]()
    var loadMoreArray = [Article]()
    
    var feedType = FeedTableType.ALLFEED
    
    @IBOutlet weak var uploadLoadingView: UIView!
    @IBOutlet weak var uploadLoadingHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewContentHeight: NSLayoutConstraint!
    
    @IBOutlet weak var loadingImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getAllFeed()
        
        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.feedView = self
        
        self.initLoader()
        
       self.setUpRefresh()
    }
    
    func setUpRefresh(){
        let refreshView = FeedPullLoaderView()
        refreshView.delegate = self
        self.tableView.addPullLoadableView(refreshView, type: .refresh)
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        customView.backgroundColor = UIColor.clear
        let bottomRefresh = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        bottomRefresh.animationImages = self.getImgList()
        bottomRefresh.animationDuration = 1.0
        bottomRefresh.startAnimating()
        
        bottomRefresh.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(bottomRefresh)
        
        customView.addConstraints([
            NSLayoutConstraint(item: bottomRefresh, attribute: .centerX, relatedBy: .equal, toItem: customView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: bottomRefresh, attribute: .centerY, relatedBy: .equal, toItem: customView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
        
        self.tableView.tableFooterView = customView
    }
    
    func getImgList()->[UIImage]{
        var imgList = [UIImage]()
        
        for count in 1...3 {
            let strImageName : String = "icon_loader_02_\(count)"
            let image = UIImage(named: strImageName)
            imgList.append(image!)
        }
        
        return imgList
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        
        let reloadDistance = CGFloat(30.0)
        if y > h + reloadDistance {
            print("Load More")
            self.getFeedLoadMore()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        getAllFeed()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
    
    func resizeTable(height : CGFloat)
    {
        self.tableViewContentHeight.constant = height
    }
    
    func refresh(sender:AnyObject) {
        self.getAllFeed()        
    }
    
    func uploadHidden(hidden : Bool){
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        
                        if hidden {
                            self.uploadLoadingHeight.constant = 0
                            self.uploadLoadingView.alpha = 0
                        }else {
                            self.uploadLoadingHeight.constant = 63
                            self.uploadLoadingView.alpha = 1
                        }
        }, completion: nil)
    }
    
    func initLoader(){
        
        self.loadingImage.animationImages = self.getImgList()
        self.loadingImage.animationDuration = 1.0
        self.loadingImage.startAnimating()
        
        self.uploadHidden(hidden: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func photoClick(_ sender: UIButton) {
        self.pushView(storyboardName: "Feed", controllerName: "FeedFullScreenViewController")
    }
    
    func getFeedLoadMore(){
        var url: URL!
        if self.feedType == FeedTableType.ALLFEED {
            
            let parameters :[String:String] = [
                "lastId" : (self.articleArray.last?.idStr)!,
                "size" : "\(10)"
            ]
            
            url = URL.init(string: Constants.VyrlFeedURL.FEED, parameters: parameters)
        }else {
            url = URL.init(string: Constants.VyrlFeedURL.FEEDBOOKMARK)
        }
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            
            self.articleArray.removeAll()
            
            let array = response.result.value ?? []
            
            self.articleArray.append(contentsOf: array)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
   
    func getAllFeed(){
        var url: URL!
        if self.feedType == FeedTableType.ALLFEED {
            
            let parameters :[String:String] = [
                "size" : "\(10)"
            ]
            
            url = URL.init(string: Constants.VyrlFeedURL.FEED, parameters: parameters)
        }else {
            url = URL.init(string: Constants.VyrlFeedURL.FEEDBOOKMARK)
        }
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            
            self.articleArray.removeAll()
            
            let array = response.result.value ?? []
            
            for article in array {
                self.articleArray.append(article)
            }
            
            self.tableView.reloadData()
        }
    }
    
    func uploadPatch(query: URL){
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
        }, usingThreshold: UInt64.init(), to: query, method: .patch, headers: Constants.VyrlAPIConstants.getHeader(), encodingCompletion:
            {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                    })
                    
                    upload.responseString { response in
                        
                        if ((response.response?.statusCode)! == 200){
                            self.tabBarController?.selectedIndex = 0
                            self.uploadHidden(hidden: true)
                            self.getAllFeed()
                        }
                        
                    }
                case .failure(let encodingError):
                    self.uploadHidden(hidden: true)
                    print(encodingError.localizedDescription)
                }
        })
    }
    
    func upload(query: URL, array : Array<AVAsset>){
        
        var fileName : String!
        
        self.uploadHidden(hidden: false)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            var count = 1
            
            for asset in array {
                
                if asset.type == .photo {
                    fileName = "\(count)" + ".jpg"
                    
                    if let imageData = asset.mediaData {
                        multipartFormData.append(imageData, withName: "files", fileName: fileName, mimeType: "image/jpg")
                    }
                } else {
                    fileName = "\(count)" + ".mpeg"
                    
                    if let imageData = asset.mediaData {
                        multipartFormData.append(imageData, withName: "files", fileName: fileName, mimeType: "video/mpeg")
                    }
                }
                
                count = count + 1
            }
            
        }, usingThreshold: UInt64.init(), to: query, method: .post, headers: Constants.VyrlAPIConstants.getHeader(), encodingCompletion:
            {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                    })
                    
                    upload.responseString { response in

                        if ((response.response?.statusCode)! == 200){
                            self.tabBarController?.selectedIndex = 0
                            self.uploadHidden(hidden: true)
                            self.getAllFeed()
                        }
                        
                    }
                case .failure(let encodingError):
                    self.uploadHidden(hidden: true)
                    print(encodingError.localizedDescription)
                }
        })
    }
}

extension FeedTableViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.articleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let article = self.articleArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: article.type.rawValue, for: indexPath) as! FeedTableCell
        cell.article = article
        cell.delegate = self
        cell.contentTextView.text = article.content
        cell.contentTextView.resolveHashTags()
        cell.contentTextView.delegate = self
        
        return cell
    }
}

extension FeedTableViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension FeedTableViewController : FeedCellDelegate {
    func didPressCell(sender: Any, cell : FeedTableCell) {
        let vc : FeedDetailViewController = self.pushViewControllrer(storyboardName: "FeedDetail", controllerName: "FeedDetailViewController") as! FeedDetailViewController
        vc.articleId = cell.article?.id
    }
    
    func setBookMark(cell: FeedTableCell) {
        let articleId = (cell.article?.id)!
        
        let parameters : Parameters = [
            "articleId": articleId,
            "contentType" : "ARTICLE"
        ]
        
        let uri = Constants.VyrlFeedURL.FEEDBOOKMARK
        
        var method : HTTPMethod = .post
        
        if ( cell.isBookMark == true ){
            method = .delete
        }
        
        Alamofire.request(uri, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
            response in
            switch response.result {
            case .success(let json) :
                print(json)
                
                if let code = response.response?.statusCode {
                    if code == 200 {
                        if method == .post{
                            self.showToast(str: "저장되었습니다.My 에서 확인하세요!")
                            cell.isBookMark = true
                        } else {
                            cell.isBookMark = false
                        }
                    }
                }
            case .failure(let error) :
                print(error)
            }
        })
    }
    
    func showFeedShareAlert(cell: FeedTableCell) {
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        
        let share = UIAlertAction(title: "내 Feed로 공유", style: .default,handler: { (action) -> Void in
            
        })
        let linkCopy = UIAlertAction(title: "링크 복사", style: .default, handler: { (action) -> Void in
            UIPasteboard.general.string = "Feed link"
            self.showToast(str: UIPasteboard.general.string!)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(share)
        alertController.addAction(linkCopy)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertNotMine(cell: FeedTableCell){
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        
        let report = UIAlertAction(title: "이 게시물 신고하기", style: .default,handler: { (action) -> Void in
            
        })
        
        let notShow = UIAlertAction(title: "이 게시물 안보기", style: .default, handler: { (action) -> Void in            
            
        })
    
        let prevent = UIAlertAction(title: "작성자 차단", style: .default, handler: { (action) -> Void in
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(report)
        alertController.addAction(notShow)
        alertController.addAction(prevent)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showFeedAlert(cell : FeedTableCell) {
        
        if cell.isMyArticle == false {
            self.showAlertNotMine(cell: cell)
            return
        }
        
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        
        let modify = UIAlertAction(title: "수정", style: .default,handler: { (action) -> Void in
            let vc : FeedModifyController = self.pushModal(storyboardName: "FeedStyle", controllerName: "feedModify") as! FeedModifyController
            vc.setText(text: cell.contentTextView.text!)
            vc.articleId = cell.article?.id
        })
        let remove = UIAlertAction(title: "삭제", style: .default, handler: { (action) -> Void in
            
            let articleId = (cell.article?.id)!
            
            let uri = Constants.VyrlFeedURL.feed(articleId: articleId)
            
            Alamofire.request(uri, method: .delete, parameters: nil, encoding:JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    print(json)
                    
                    if let code = response.response?.statusCode {
                        if code == 200 {
                            self.getAllFeed()
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            })
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(modify)
        alertController.addAction(remove)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension FeedTableViewController : KRPullLoadViewDelegate {
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType){
        switch state {
        case let .loading(completionHandler: completionHandler):
            
            DispatchQueue.main.async {
                completionHandler()
                self.getFeedLoadMore()
            }
            
        default:
            break
        }
    }
}

extension FeedTableViewController : FeedPullLoaderDelegate {
    func pullLoadView(_ pullLoadView: FeedPullLoaderView, didChageState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        if (type == .loadMore){
            
            switch state {
            case let .loading(completionHandler: completionHandler):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    completionHandler()
                    
//                    self.tableView.removePullLoadableView(self.bottomRefresh)
                    
                    self.getFeedLoadMore()
                    
                }
            default:
                break
            }

            return
        }
        
        switch state {
        case let .loading(completionHandler: completionHandler):
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                completionHandler()
                self.getAllFeed()
            }
        default:
            break
        }
    }
}

public enum ArticleType : String{
    case oneFeed   = "oneFeed"
    case multiFeed = "multiFeed"
    case textOnlyFeed = "textOnlyFeed"
    case advertisingFeed = "advertisingFeed"
    case channelFeed = "channelFeed"
}

struct Article : Mappable {
    var type : ArticleType!
    
    var id : Int!
    var content : String!
    
    var comments : [Comment]!
    var medias : [ArticleMedia]!
    
    var cntComment : Int!
    var cntLike : Int!
    var cntShare : Int!
    
    var profile : Profile!
    var date : Date?
    
    var commentCount : String!
    var likeCount : String!
    var shareCount: String!
    var idStr : String!
    
    var location : String!
    
    var isBookMark : Bool!
    var isMyArticle : Bool!
    var isLike :Bool!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        id <- map["id"]
        content <- map["content"]
        cntComment <- map["cntComment"]
        cntLike <- map["cntLike"]
        comments <- map["comments"]
        cntShare <- map["cntShare"]
        profile <- map["profile"]
        medias <- map["media"]
        location <- map["location"]
        isBookMark <- map["bookmark"]
        isLike <- map["like"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let dateString = map["createdAt"].currentValue as? String, let _date = dateFormatter.date(from: dateString){
            date = _date
        }
        
        commentCount = "\(cntComment!)"
        likeCount = "\(cntLike!)"
        shareCount = "\(cntShare!)"
        idStr = "\(id!)"
        
        isMyArticle = LoginManager.sharedInstance.isMyProfile(id: profile.id)
        
        self.setUpType()
    }
    
    mutating func setUpType(){
        if ( self.medias.count > 1){
            type = ArticleType.multiFeed
        }else if ( self.medias.count == 1){
            type = ArticleType.oneFeed
        }else if ( self.medias.count == 0){
            type = ArticleType.textOnlyFeed
        }        
    }
}

struct ArticleMedia : Mappable {

    var thumbnail : String?
    var type : String?
    var url : String?
    
    var image : String!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        thumbnail <- map["thumbnail"]
        type <- map["type"]
        url <- map["url"]
        
        if type! == "IMAGE" {
            image = url
        } else {
            image = thumbnail
        }
    }
}





