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
import AlamofireImage
import AlamofireObjectMapper
import AVFoundation
import KRPullLoader
import RxCocoa
import RxSwift
import RxDataSources

enum FeedTableType {
    case ALLFEED,MYFEED, BOOKMARK, USERFEED, FANFEED, FANALLFEED
}

class FeedTableViewController: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var uploadLoadingView: UIView!
    @IBOutlet weak var loadingImage: UIImageView!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var bottomRefresh: UIImageView!
    
    var articleArray = [Article]()

    var feedType = FeedTableType.ALLFEED
    var userId : Int!
    var fanPageId : Int!
    
    var isEnableUpload = true
    var isFeedTab = false
    
    
    var bottomView : UIView!
    var refreshView : FeedPullLoaderView!
    
    var fanPageViewController : FanPageController!
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfArticleData>()
    let disposeBag = DisposeBag()
    
    private let sections = Variable<[SectionOfArticleData]>([])
    
    var feedView : FeedViewController?
    
    @IBOutlet weak var networkErrorView: UIView!
    
    func showNetworkError(isShow : Bool) {
        self.networkErrorView.alpha = isShow ? 1.0 : 0.0
    }
    
    @IBAction func refresh(_ sender: Any) {
        self.getAllFeed()
    }
    
    func initTable(){
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
        
        Observable.just(self.articleArray).map {(customDatas) -> [SectionOfArticleData] in
            [SectionOfArticleData(items: customDatas)]
            }.bind(to: self.sections).addDisposableTo(self.disposeBag)
        
        dataSource.configureCell = { ds, tv, ip, item in
            let cell = tv.dequeueReusableCell(withIdentifier: item.type.rawValue) as! FeedTableCell
            
            if item.type == ArticleType.oneFeed || item.type == ArticleType.multiFeed || item.type == ArticleType.textOnlyFeed  {
                cell.article = item
                cell.fanPageViewController = self.fanPageViewController                
                cell.delegate = self
                cell.contentTextView.text = item.content
                cell.contentTextView.resolveHashTags()
                cell.contentTextView.delegate = self
            }
            
            return cell
        }
        
        self.tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        
        sections.asDriver().drive(tableView.rx.items(dataSource: self.dataSource)).addDisposableTo(disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initTable()
        
        self.setUpRefresh()
        
        self.initLoader()
        
        if isEnableUpload {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.feedView = self
        }
        
        self.showNetworkError(isShow: false)
        
        self.getAllFeed()
    }
    
    deinit {
        self.tableView.removePullLoadableView(refreshView)
    }
    
    func setUploadDelegate(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.feedView = self
    }
    
    func setUpRefresh(){
        refreshView = FeedPullLoaderView()
        refreshView.delegate = self
        self.tableView.addPullLoadableView(refreshView, type: .refresh)
        
        self.bottomRefresh.animationImages = self.getImgList()
        self.bottomRefresh.animationDuration = 1.0
        self.bottomRefresh.startAnimating()
        self.footerView.isHidden = true
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

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        
        let reloadDistance = CGFloat(100.0)
        if y > h + reloadDistance {
            self.footerView.isHidden = false
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        
        let reloadDistance = CGFloat(50)
        if y > h + reloadDistance {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                UIView.animate(withDuration: 0.5, animations: {
                    self.footerView.isHidden = true
                }, completion: {
                    (true) in
                    self.getFeedLoadMore()
                })
            })
        }
    }
    
    func refresh(sender:AnyObject) {
        self.getAllFeed()        
    }
    
    func uploadHidden(hidden : Bool){
        
        self.uploadLoadingView.isHidden = hidden
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

    func getFeedType(parameters : [String:String]) -> URL! {
        
        var url : URL!
        
        if self.feedType == FeedTableType.ALLFEED {
            url = URL.init(string: Constants.VyrlFeedURL.FEEDALL, parameters: parameters)
        }else if self.feedType == FeedTableType.MYFEED{
            url = URL.init(string: Constants.VyrlFeedURL.FEED, parameters: parameters)
        }else if self.feedType == .USERFEED {
            url = URL.init(string: Constants.VyrlFeedURL.feed(userId: self.userId))
        }else if self.feedType == .FANFEED {
            url = URL.init(string: Constants.VyrlFanAPIURL.getFanPagePosts(fanPageId: self.fanPageId))
        }else if self.feedType == .FANALLFEED {
            url = URL.init(string: Constants.VyrlFanAPIURL.FANPAGEALLFEED)
        }
        else {
            url = URL.init(string: Constants.VyrlFeedURL.FEEDBOOKMARK)
        }

        return url
    }
    
    func getFeedLoadMore(){
        var url: URL!
        
        var parameters :[String:String] = [
            "size" : "\(10)"
        ]
        
        if self.articleArray.count > 0 {
            let pageId = self.articleArray.last?.pageId
            
            if pageId != nil {
                parameters["lastId"] = "\(pageId!)"
            }
        }
        
        url = self.getFeedType(parameters: parameters)
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            
            if self.feedType == FeedTableType.FANFEED {
                self.articleArray.removeAll()
            }
            
            let array = response.result.value ?? []
            
            for (i, article) in array.enumerated() {
                self.articleArray.append(article)
                if i % 4 == 0 && i != 0 && self.isFeedTab == true {
                    let adMobArticle = Article.init()
                    self.articleArray.append(adMobArticle)
                }
            }
            
            self.sections.value = [SectionOfArticleData(items:self.articleArray)]
        }
    }
   
    func getAllFeed(){

        let parameters :[String:String] = [
            "size" : "\(10)"
        ]
        
        let url = self.getFeedType(parameters: parameters)
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            
            switch response.result {
            case .success(let json) :
                
                self.showNetworkError(isShow: false)
                self.articleArray.removeAll()
                
                let array = response.result.value ?? []
                
                if array.count == 0{
                    self.feedView?.embedController.remove()
                    if LoginManager.sharedInstance.isFirstLogin == true {
                        self.feedView?.goSearch()
                        LoginManager.sharedInstance.isFirstLogin = false
                    }
                }
                
                for (i,article) in array.enumerated() {
                    self.articleArray.append(article)
                    if i % 4 == 0 && i != 0 && self.isFeedTab == true {
                        let adMobArticle = Article.init()
                        self.articleArray.append(adMobArticle)
                    }
                }
                
                self.sections.value = [SectionOfArticleData(items:self.articleArray)]
            case .failure(let error) :
                
                self.showNetworkError(isShow: true)
                if let code = response.response?.statusCode {
                    print(code)
                    LoginManager.sharedInstance.checkLogout(statusCode: code)
                    return
                }
            }
        }
    }
    
    func uploadPatch(query: URL, completion : (() -> Void)?){
        
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
                            if self.feedType != .FANFEED {
                                self.tabBarController?.selectedIndex = 0
                            }else {
                                completion!()
                            }
                            
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
    
    func upload(query: URL, array : Array<AVAsset>, completion : (() -> Void)?){
        
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
                    } else if asset.type == .gif {
                        fileName = "\(count)" + ".gif"
                        if let imageData = asset.mediaData {
                            multipartFormData.append(imageData, withName: "files", fileName: fileName, mimeType: "image/gif")
                        }
                    }else {
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
                                    if self.feedType != .FANFEED {
                                        self.tabBarController?.selectedIndex = 0
                                        
                                    }else {
                                        completion!()
                                    }
                                    
                                    self.feedView?.refresh()
                                    self.uploadHidden(hidden: true)
                                }
                            }
                        case .failure(let encodingError):
                            self.uploadHidden(hidden: true)
                            print(encodingError.localizedDescription)
                        }
            })
        }
}

extension FeedTableViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        switch URL.scheme {
        case "hash"? :
            let vc : TagSearchCollectionViewController = UIStoryboard(name:"Search", bundle: nil).instantiateViewController(withIdentifier: "TagSearch") as! TagSearchCollectionViewController
            let result = ((URL as NSURL).resourceSpecifier?.removingPercentEncoding)!
            vc.tagString = result
            
            self.navigationController?.pushViewController(vc, animated: false)
            
            
        case "mention"? :
            showHashTagAlert(tagType: "mention", payload: ((URL as NSURL).resourceSpecifier?.removingPercentEncoding)!)
        default:
            print("just a regular url")
        }
        
        return true
    }
    
    func showHashTagAlert(tagType:String, payload:String){
        let alertView = UIAlertView()
        alertView.title = "\(tagType) tag detected"
        // get a handle on the payload
        alertView.message = "\(payload)"
        alertView.addButton(withTitle: "Ok")
        alertView.show()
    }
}

extension FeedTableViewController : FeedCellDelegate {
    func showFanPage(cell: FeedTableCell) {
        let vc = self.pushViewControllrer(storyboardName: "Fan", controllerName: "FanPage") as! FanPageController
        vc.fanPageId = cell.article?.fanPageId
    }
    
    func didPressPhoto(sender: Any, cell : FeedTableCell) {
        let vc = self.pushViewControllrer(storyboardName: "Feed", controllerName: "FeedFullScreenViewController") as! FeedFullScreenViewController // or whatever it is
        vc.mediasArray = cell.article?.medias
    }
    
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
            
            let uri = Constants.VyrlFeedURL.share(articleId: (cell.article?.id)!)
            
            Alamofire.request(uri, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON(completionHandler: {
                response in
                switch response.result {
                case .success(let json) :
                    print(json)
                    
                    if let code = response.response?.statusCode {
                        if code == 200 {
                            
                            self.showToast(str: "공유가 완료되었습니다!")
                            
                            let jsonData = json as! NSDictionary
                            
                            let cntShare = jsonData["cntShare"] as! Int
                            cell.share.setTitle("\(cntShare)", for: .normal)
                        }
                    }
                case .failure(let error) :
                    print(error)
                }
            })

        })
        let linkCopy = UIAlertAction(title: "링크 복사", style: .default, handler: { (action) -> Void in
            
            let uri = Constants.VyrlFeedURL.share(articleId: (cell.article?.id)!)
            
            Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON(completionHandler: {
                response in
                switch response.result {
                case .success(let json) :
                    print(json)
                    
                    if let code = response.response?.statusCode {
                        if code == 200 {
                            let jsonData = json as! NSDictionary
                            
                            let url = jsonData["url"] as! String
                            
                            UIPasteboard.general.string = url
                            self.showToast(str: url)
                        }
                    }
                case .failure(let error) :
                    print(error)
                }
            })
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(share)
        alertController.addAction(linkCopy)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func report(articleId : Int, reportType : ReportType){
        let parameters : [String:String] = [
            "articleId": "\(articleId)",
            "reportType" : reportType.rawValue,
            "contentType" : "ARTICLE"
        ]
        
        let uri = Constants.VyrlFeedURL.FEEDREPORT
        
        let url = URL.init(string: uri, parameters: parameters)
        
        Alamofire.request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
            response in
            switch response.result {
            case .success(let json) :
                print(json)
                
                if let code = response.response?.statusCode {
                    if code == 200 {
                       self.showToast(str: "정상적으로 신고 되었습니다! 감사합니다.")
                    }
                }
            case .failure(let error) :
                print(error)
            }
        })
    }
    
    func showReport(articleId : Int){
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        
        let adult = UIAlertAction(title: "성인컨텐츠", style: .default,handler: { (action) -> Void in
            self.report(articleId: articleId, reportType: ReportType.ADULT)
        })
        
        let offend = UIAlertAction(title: "해롭거나 불쾌", style: .default, handler: { (action) -> Void in
            self.report(articleId: articleId, reportType: ReportType.OFFEND)
        })
        
        let spam = UIAlertAction(title: "스팸 또는 사기", style: .default, handler: { (action) -> Void in
            self.report(articleId: articleId, reportType: ReportType.SPAM)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(adult)
        alertController.addAction(offend)
        alertController.addAction(spam)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showHideAlert(articleId : Int){
        let alertController = UIAlertController (title:nil, message:"해당 게시글을 Feed에서 숨깁니다.",preferredStyle:.alert)
        
        let ok = UIAlertAction(title: "확인", style: .default,handler: { (action) -> Void in
            self.hideFeed(articleId: articleId)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func hideFeed(articleId : Int){
        let uri = Constants.VyrlFeedURL.feedHide(articleId: articleId)
        
        self.showLoading(show: true)
        
        Alamofire.request(uri, method: .post, parameters: nil, encoding:JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let json):
                
                if let code = response.response?.statusCode {
                    if code == 200 {
                        
                        let jsonData = json as! NSDictionary
                        
                        let result = jsonData["result"] as! Bool
                        
                        if result {
                            self.showLoading(show: false)
                            self.getAllFeed()
                        }
                    }
                }
            case .failure(let error):
                self.showLoading(show: false)
                print(error)
            }
        })
    }
    
    func showAlertNotMine(cell: FeedTableCell){
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        
        let report = UIAlertAction(title: "이 게시물 신고하기".localized(comment: ""), style: .default,handler: { (action) -> Void in
            self.showReport(articleId: (cell.article?.id)!)
        })
        
        let notShow = UIAlertAction(title: "이 게시물 안보기", style: .default, handler: { (action) -> Void in            
            self.showHideAlert(articleId: (cell.article?.id)!)
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
            vc.fanPagePostDelegate = self.fanPageViewController
            vc.setText(text: cell.contentTextView.text!)
            vc.articleId = cell.article?.id
        })
        let remove = UIAlertAction(title: "삭제", style: .default, handler: { (action) -> Void in
            
            let articleId = (cell.article?.id)!
            
            var uri = Constants.VyrlFeedURL.feed(articleId: articleId)
            
            if self.feedType == .FANFEED {
                uri = Constants.VyrlFanAPIURL.fanPagePost(articleId: articleId)
            }
            
            self.showLoading(show: true)
            
            Alamofire.request(uri, method: .delete, parameters: nil, encoding:JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    print(json)
                    
                    if let code = response.response?.statusCode {
                        if code == 200 {
                            
                            self.showLoading(show: false)
                            
                            self.getAllFeed()
                            
                            if self.feedType == .FANFEED {
                                self.fanPageViewController.reloadFanPage()
                            }
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
    
    func showUserProfileView(userId: Int) {
        if(LoginManager.sharedInstance.getCurrentAccount()?.userId == "\(userId)"){
            let profile = self.pushViewControllrer(storyboardName: "My", controllerName: "My") as! MyViewController
            profile.profileUserId = userId
        } else {
            let otherProfile = self.pushViewControllrer(storyboardName: "Search", controllerName: "OtherProfile") as! OtherProfileViewController
            otherProfile.profileUserId = userId
        }
    }
    
    func showLikesUserList(articelId: Int) {
        let storyboard = UIStoryboard(name: "Feed", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FeedLikeUserListViewController") as! FeedLikeUserListViewController // or whatever it is
        vc.articleId =  articelId
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FeedTableViewController : FeedPullLoaderDelegate {
    func pullLoadView(_ pullLoadView: FeedPullLoaderView, didChageState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        if (type == .loadMore){
            
            switch state {
            case let .loading(completionHandler: completionHandler):
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                    completionHandler()
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
    case channelFeed = "channelFeed"
    case FBAdFeed = "FBAdFeed"
    case googleAdFeed = "googleAdFeed"
}

struct Article : Mappable {
    var type : ArticleType!
    
    var id : Int!
    var content : String!
    
    var comments : [Comment]!
    var medias : [ArticleMedia]!
    
    var cntComment : Int!
    {
        didSet
        {
            commentCount = "\(cntComment!)"
        }
    }
    var cntLike : Int!
    {
        didSet
        {
            likeCount = "\(cntLike!)"
        }
    }
    var cntShare : Int!
    {
        didSet
        {
            shareCount = "\(cntShare!)"
        }
    }
    
    var profile : Profile!
    var date : Date?
    
    var commentCount : String!
    var likeCount : String!
    var shareCount: String!
    var idStr : String!
    
    var location : String!
    
    var isFanPageType : Bool!
    var isBookMark : Bool!
    var isMyArticle : Bool!
    var isLike :Bool!
    var openYn : Bool!
    
    var lastCreatedAt : String!
    
    var contentType : String!{
        didSet
        {
            if(contentType == "FANPAGE")
            {
                isFanPageType = true
            } else {
                isFanPageType = false
            }
        }
    }
    
    var fanPageId : Int!
    var fanPageName : String!
    
    var pageId : Int!
    
    var likeUsers : [SearchUser]!
    var shareUsers : [SearchUser]!
    
    init() {
        let diceRoll = Int(arc4random_uniform(2))
        self.type = diceRoll == 0 ? ArticleType.FBAdFeed : ArticleType.googleAdFeed
    }
    
    init?(map: Map) {
        self.init()
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
        lastCreatedAt <- map["lastCreatedAt"]
        openYn <- map["openYn"]
        contentType <- map["contentType"]
        pageId <- map["pageId"]
        likeUsers <- map["likeUsers"]
        shareUsers <- map["shareUsers"]
        
        if(contentType == "FANPAGE"){
            fanPageId <- map["fanPageId"]
            fanPageName <- map["pageName"]
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let dateString = map["createdAt"].currentValue as? String, let _date = dateFormatter.date(from: dateString){
            date = _date
        }
        
        idStr = "\(id!)"
        
        isMyArticle = LoginManager.sharedInstance.isMyProfile(id: profile.userId)
        
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
    var fileSize :Int64?
    var fileSizeString : String?
    
    var imageUrl : String!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        thumbnail <- map["thumbnail"]
        type <- map["type"]
        url <- map["url"]
        
        if type! == "IMAGE" {
            imageUrl = url
        } else {
            imageUrl = thumbnail
        }
        
        fileSize <- map["fileSize"]
        
        fileSizeString = ByteCountFormatter.string(fromByteCount: fileSize!, countStyle: .file)
    }

}

enum ReportType :String {
    case ADULT = "ADULT", OFFEND = "OFFEND", SPAM = "SPAM"
}

struct SectionOfArticleData {
    var items : [Item]
}

extension SectionOfArticleData : SectionModelType {
    typealias Item = Article
    
    init(original: SectionOfArticleData, items: [Article]) {
        self = original
        self.items = items
    }
}


