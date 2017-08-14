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

class FeedTableViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    var articleArray = [Article]()
    
    var refreshControl : UIRefreshControl!
    
    @IBOutlet weak var uploadLoadingView: UIView!
    @IBOutlet weak var uploadLoadingHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewContentHeight: NSLayoutConstraint!
    
    @IBOutlet weak var loadingImage: UIImageView!
    
    var refreshLoadingView : UIView!
    var refreshColorView : UIView!
    var refreshLoadingImageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewContentHeight.constant = UIScreen.main.bounds.height - 44 - 20 - 45

        self.getAllFeed()
        
        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.feedView = self
        
        self.initLoader()
        self.initRefresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAllFeed()
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
    
    func initRefresh(){
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.black
        
        self.refreshLoadingView = UIView(frame: self.refreshControl!.bounds)
        self.refreshControl.backgroundColor = UIColor.clear
        
        self.refreshColorView = UIView(frame: self.refreshControl!.bounds)
        self.refreshColorView.backgroundColor = UIColor.clear
        self.refreshColorView.alpha = 0.30
        
        self.refreshLoadingImageView = UIImageView.init(image: UIImage.init(named: "icon_loader_02_1"))
        
        var imgList = [UIImage]()
        
        for count in 1...3 {
            let strImageName : String = "icon_loader_02_\(count)"
            let image = UIImage(named: strImageName)
            imgList.append(image!)
        }
        
        self.refreshLoadingImageView.animationImages = imgList
        self.refreshLoadingImageView.animationDuration = 1.0
        self.refreshLoadingImageView.startAnimating()
        
        self.refreshLoadingView.addSubview(self.refreshLoadingImageView)
        self.refreshLoadingView.clipsToBounds = true
        
        let x = UIScreen.main.bounds.width / 2 - 10
        
        self.refreshLoadingImageView.frame = CGRect(x: x, y: 20, width: 20, height: 20)
        
        self.refreshControl!.tintColor = UIColor.clear
        self.refreshControl!.addSubview(self.refreshColorView)
        self.refreshControl!.addSubview(self.refreshLoadingView)
        
        self.refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    func initLoader(){
        var imgList = [UIImage]()
        
        for count in 1...3 {
            let strImageName : String = "icon_loader_02_\(count)"
            let image = UIImage(named: strImageName)
            imgList.append(image!)
        }
        
        self.loadingImage.animationImages = imgList
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
   
    
    func getAllFeed(){
        
        let url = URL.init(string: Constants.VyrlFeedURL.FEED)
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            
            self.articleArray.removeAll()
            
            let array = response.result.value ?? []
            
            for article in array {
                self.articleArray.append(article)
            }
            
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
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
        let vc : FeedDetailViewController = self.pushViewControllrer(storyboardName: "FeedStyle", controllerName: "FeedDetailViewController") as! FeedDetailViewController
        vc.articleId = cell.article?.id

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
    
    func showFeedAlert(cell : FeedTableCell) {
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let dateString = map["createdAt"].currentValue as? String, let _date = dateFormatter.date(from: dateString){
            date = _date
        }
        
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





