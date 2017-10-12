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
    var articleArray = [Article]()

    var feedType = FeedTableType.MYFEED
    var userId : Int!
    var fanPageId : Int!
    var isBottomRefresh = false
    var isEnableUpload = true
    
    @IBOutlet weak var uploadLoadingView: UIView!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var loadingImage: UIImageView!
    
    var bottomView : UIView!
    var refreshView : FeedPullLoaderView!
    
    var fanPageViewController : FanPageController!
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionOfArticleData>()
    let disposeBag = DisposeBag()
    
    private let sections = Variable<[SectionOfArticleData]>([])
    
    var feedView : FeedViewController?
    
    func initTable(){
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
        
        Observable.just(self.articleArray).map {(customDatas) -> [SectionOfArticleData] in
            [SectionOfArticleData(items: customDatas)]
            }.bind(to: self.sections).addDisposableTo(self.disposeBag)
        
        dataSource.configureCell = { ds, tv, ip, item in
            let cell = tv.dequeueReusableCell(withIdentifier: item.type.rawValue) as! FeedTableCell
            cell.article = item
            cell.delegate = self
            cell.contentTextView.text = item.content
            cell.contentTextView.resolveHashTags()
            cell.contentTextView.delegate = self
            return cell
        }
        
        self.tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        
        sections.asDriver().drive(tableView.rx.items(dataSource: self.dataSource)).addDisposableTo(disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
        
        self.initTable()
        
        self.setUpRefresh()
        
        self.initLoader()
        
        if isEnableUpload {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.feedView = self
        }
        
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
        
        self.bottomView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        let bottomRefresh = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        bottomRefresh.animationImages = self.getImgList()
        bottomRefresh.animationDuration = 1.0
        bottomRefresh.startAnimating()
        
        bottomRefresh.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(bottomRefresh)
        
        bottomView.addConstraints([
            NSLayoutConstraint(item: bottomRefresh, attribute: .centerX, relatedBy: .equal, toItem: bottomView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: bottomRefresh, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
        
        self.tableView.tableFooterView = self.bottomView
        
        self.isBottomRefresh = true
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
        
        if self.isBottomRefresh == false {
            return
        }
        
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
            parameters["lastId"] = (self.articleArray.last?.idStr)!
            parameters["createdAt"] = self.articleArray.last?.lastCreatedAt
        }
        
        url = self.getFeedType(parameters: parameters)
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            
            if self.feedType == FeedTableType.FANFEED {
                self.articleArray.removeAll()
            }
            
            let array = response.result.value ?? []
            
            self.articleArray.append(contentsOf: array)
            
            self.sections.value = [SectionOfArticleData(items:self.articleArray)]
//            self.tableView.reloadData()
            self.resetSizeTableView()
        }
    }
    
    func resetSizeTableView(){
        var wholeSize = self.tableView.contentSize
        
        wholeSize.height = self.tableView.contentSize.height - (self.tableView.tableFooterView?.frame.size.height)!
        self.tableView.contentSize = wholeSize
    }
   
    func getAllFeed(){

        let parameters :[String:String] = [
            "size" : "\(10)"
        ]
        
        let url = self.getFeedType(parameters: parameters)
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            
            response.result.ifFailure {
                LoginManager.sharedInstance.checkLogout(statusCode: (response.response?.statusCode)!)
                return
            }
            
            self.articleArray.removeAll()
            
            let array = response.result.value ?? []
            
            if array.count == 0{
                self.feedView?.embedController.remove()
                if LoginManager.sharedInstance.isFirstLogin == false {
                    self.tabBarController?.selectedIndex = 3
                    LoginManager.sharedInstance.isFirstLogin = true
                }
            }
            
            if ( array.count <= 2 ){
                self.tableView.tableFooterView = UIView(frame: .zero)
            }else {
                self.tableView.tableFooterView = self.bottomView
            }
            
            for article in array {
                self.articleArray.append(article)
            }
            
            self.sections.value = [SectionOfArticleData(items:self.articleArray)]
            
            self.resetSizeTableView()
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
                                    self.getAllFeed()
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

extension FeedTableViewController : UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        return self.articleArray.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
//    {
//        let article = self.articleArray[indexPath.row]
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: article.type.rawValue, for: indexPath) as! FeedTableCell
//        cell.article = article
//        cell.delegate = self
//        cell.contentTextView.text = article.content
//        cell.contentTextView.resolveHashTags()
//        cell.contentTextView.delegate = self
//
//        return cell
//    }
}

extension FeedTableViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        switch URL.scheme {
        case "hash"? :
            let vc : SearchViewController = UIStoryboard(name:"Search", bundle: nil).instantiateViewController(withIdentifier: "search") as! SearchViewController
            self.navigationController?.present(vc, animated: true, completion: {
                vc.searchBar.becomeFirstResponder()
                vc.searchBar.text = ((URL as NSURL).resourceSpecifier?.removingPercentEncoding)!
                vc.searchBar(vc.searchBar, textDidChange: vc.searchBar.text!)
            })
            
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
    func didPressPhoto(sender: Any, cell : FeedTableCell) {
        let storyboard = UIStoryboard(name: "Feed", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FeedFullScreenViewController") as! FeedFullScreenViewController // or whatever it is
        vc.mediasArray = cell.article?.medias
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didPressCell(sender: Any, cell : FeedTableCell) {
        let vc : FeedDetailViewController = self.pushViewControllrer(storyboardName: "FeedDetail", controllerName: "FeedDetailViewController") as! FeedDetailViewController
        vc.articleId = cell.article?.id
        vc.feedType = self.feedType
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
            
            Alamofire.request(uri, method: .delete, parameters: nil, encoding:JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    print(json)
                    
                    if let code = response.response?.statusCode {
                        if code == 200 {
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
    
    var isBookMark : Bool!
    var isMyArticle : Bool!
    var isLike :Bool!
    var openYn : Bool!
    
    var lastCreatedAt : String!
    
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
        lastCreatedAt <- map["lastCreatedAt"]
        openYn <- map["openYn"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let dateString = map["createdAt"].currentValue as? String, let _date = dateFormatter.date(from: dateString){
            date = _date
        }
        
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
    var fileSize :Int64?
    var mbFileSize : Int64?
    
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
        mbFileSize = fileSize! / 1024 / 1024
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


