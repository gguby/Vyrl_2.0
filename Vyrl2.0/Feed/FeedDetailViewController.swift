//
//  FeedDetailViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 13..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import GrowingTextView
import AVFoundation
import Alamofire
import ObjectMapper
import NSDate_TimeAgo
import NukeFLAnimatedImagePlugin
import FLAnimatedImage

class FeedDetailViewController: UIViewController{
   

    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
  
    @IBOutlet weak var commentFieldView: UIView!
    @IBOutlet weak var closeEmoticonButton: UIButton!
    @IBOutlet weak var emoticonImageView: UIImageView!
    @IBOutlet weak var showEmoticonButton: UIButton!
    @IBOutlet weak var postCommentButton: UIButton!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var articleId : Int!
    var emoticonView : EmoticonView!
    var kbHeight: CGFloat!
    
    var commentArray : [Comment] = []
    var feedType = FeedTableType.MYFEED
    
    var article : Article? {
        didSet {
            self.likeButton.setTitle(article?.likeCount, for: .normal)
            self.commentButton.setTitle(article?.commentCount, for: .normal)
            self.shareButton.setTitle(article?.shareCount, for: .normal)
            
            if (article?.isLike)! {
                self.likeButton.setImage(UIImage.init(named: "icon_heart_01_on"), for: .normal)
                self.likeButton.tag = 1
                self.likeButton.setTitleColor(UIColor.ivLighterPurple, for: .normal)
            } else {
                self.likeButton.setImage(UIImage.init(named: "icon_heart_01"), for: .normal)
                self.likeButton.tag = 0
                self.likeButton.setTitleColor(UIColor.ivGreyishBrown, for: .normal)
            }
        }
    }
    
    var commentLastId = 0
    
    var tapGesture : UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: .zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        
         self.commentTextView.textContainerInset = UIEdgeInsetsMake(12, 0, 12, 0)
        
        showButtonView()
        requestFeedDetail()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        requestFeedDetail()
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func likeListButtonClick(_ sender: UIButton) {
        print("like")
        let storyboard = UIStoryboard(name: "Feed", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FeedLikeUserListViewController") as! FeedLikeUserListViewController // or whatever it is
       vc.articleId =  self.articleId
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func shareListButtonClick(_ sender: UIButton) {
        print("share")
    }
    @IBAction func translateContent(_ sender: UIButton) {
        
    }
    
    func showButtonView() {
        self.commentTextView.resignFirstResponder()
        
        commentFieldView.isHidden = true
        buttonView.isHidden = false
    }
    
    func showCommentFieldView() {
        view.addGestureRecognizer(tapGesture)
        commentFieldView.isHidden = false
        buttonView.isHidden = true
    }
    
    func showEmoticonImageView() {
        commentTextView.isHidden = true
        emoticonImageView.isHidden = false
        closeEmoticonButton.isHidden = false
        showEmoticonButton.setImage(UIImage.init(named: "icon_emoji_01_on"), for: .normal)
    }
    
    func showCommentTextView() {
        commentTextView.isHidden = false
        emoticonImageView.isHidden = true
        closeEmoticonButton.isHidden = true
        showEmoticonButton.setImage(UIImage.init(named: "icon_emoji_01_off"), for: .normal)
    }
    
    @IBAction func commentButtonclick(_ sender: UIButton) {
        self.commentTextView.becomeFirstResponder()
        
        showCommentFieldView()
        showCommentTextView()
    }
    
    @IBAction func openEmoticon(_ sender: UIButton) {
        
        let keyboard = UIApplication.shared.windows[1]
        emoticonView.frame = CGRect.init(x: 0, y: keyboard.frame.size.height - kbHeight, width: keyboard.frame.size.width, height: kbHeight)
        keyboard.bringSubview(toFront: emoticonView)
        
        
        self.commentTextView.bringSubview(toFront: closeEmoticonButton)
        
        showEmoticonImageView()
    }
    
    @IBAction func closeEmoticon(_ sender: UIButton) {
        let keyboard : UIWindow = UIApplication.shared.windows[1]
        emoticonView.frame = CGRect.init(x: 0, y: keyboard.frame.size.height, width: keyboard.frame.size.width, height:0)
        
        showCommentTextView()
    }

    @IBAction func postButtonClick(_ sender: UIButton) {
        let uri = URL.init(string: Constants.VyrlFeedURL.feedComment(articleId: articleId))
        
        let parameters : Parameters = [
            "content": self.commentTextView.text!,
            ]

        
        Alamofire.request(uri!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                print(json)
                DispatchQueue.main.async(execute: {
                    if(response.response?.statusCode == 200){
                        let jsonData = json as! NSDictionary
                        self.article?.cntComment = jsonData["cntComment"] as! Int
                        self.commentButton.setTitle(self.article?.commentCount, for: .normal)
                        self.requestNewComment()
                        self.showButtonView()
                        }
                   })
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func likeButtonClick(_ sender: UIButton) {
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
                self.likeButton.setTitle("\(cntLike)", for: .normal)
                
                if sender.tag == 0 {
                    sender.setImage(UIImage.init(named: "icon_heart_01_on"), for: .normal)
                    self.likeButton.setTitleColor(UIColor.ivLighterPurple, for: .normal)
                    sender.tag = 1
                }else {
                    sender.setImage(UIImage.init(named: "icon_heart_01"), for: .normal)
                    self.likeButton.setTitleColor(UIColor.ivGreyishBrown, for: .normal)
                    sender.tag = 0
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    @IBAction func shareButtonClick(_ sender: UIButton) {
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        
        let share = UIAlertAction(title: "내 Feed로 공유", style: .default,handler: { (action) -> Void in
            
            let uri = Constants.VyrlFeedURL.share(articleId: (self.article?.id)!)
            
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
                            self.shareButton.setTitle("\(cntShare)", for: .normal)
                        }
                    }
                case .failure(let error) :
                    print(error)
                }
            })
            
        })
        let linkCopy = UIAlertAction(title: "링크 복사", style: .default, handler: { (action) -> Void in
            
            let uri = Constants.VyrlFeedURL.share(articleId: (self.article?.id)!)
            
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

    
    func keyboardShow(notification: NSNotification) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }

        
         if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
           
            kbHeight = keyboardSize.height
            emoticonView = EmoticonView.init(frame: CGRect.init(x: 0, y: keyboardSize.origin.y + keyboardSize.height, width: keyboardSize.width, height: keyboardSize.height), delegate: self as EmoticonViewDelegate)
            emoticonView.backgroundColor = UIColor.white
            UIApplication.shared.windows[UIApplication.shared.windows.count-1].addSubview(emoticonView)
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
    }
    
    func keyboardHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        } else {
            debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
        }
    }
    
    func tapGestureHandler() {
        view.endEditing(true)
        view.removeGestureRecognizer(tapGesture)
        showButtonView()
    }
    
    func requestComment() {
        let parameters : Parameters = [
            "lastId": "\(self.commentLastId)",
            "size": "\(20)"
        ]
        
        let uri = URL.init(string: Constants.VyrlFeedURL.feedComment(articleId: articleId), parameters: parameters as! [String : String])
        

        Alamofire.request(uri!, method: .get, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Comment]>) in
            
            var array = response.result.value ?? []
            array.append(contentsOf: self.commentArray)
            self.commentArray = array
            
            self.commentLastId = self.commentArray[0].id
            
           self.tableView.reloadData()
        }
    }
    
    func requestNewComment() {
        let parameters : Parameters = [
            "size": "\(20)"
        ]
        
        let uri = URL.init(string: Constants.VyrlFeedURL.feedComment(articleId: articleId), parameters: parameters as! [String : String])
        
        
        Alamofire.request(uri!, method: .get, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Comment]>) in
            
            self.commentArray.removeAll()
            
            var array = response.result.value ?? []
            array.append(contentsOf: self.commentArray)
            self.commentArray = array
            
            self.commentLastId = self.commentArray[0].id
            
            self.tableView.reloadData()
        }

    }
    
    func requestFeedDetail() {
         var url = URL.init(string: Constants.VyrlFeedURL.feed(articleId: articleId))
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseObject { (response: DataResponse<Article>) in
            let article = response.result.value
            self.article = article
            
            if(article?.comments != nil && (article?.comments.count)! > 0){
                for comment in (article?.comments)! {
                    self.commentArray.append(comment)
                }
                
                self.commentLastId = self.commentArray[0].id
            }
            self.tableView.reloadData()
        }
    }
    
    func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                self.showAlert(indexPath: indexPath)
            }
        }
    }

    func report(id : Int, reportType : ReportType){
        let parameters : [String:String] = [
            "id": "\(id)",
            "reportType" : reportType.rawValue,
            "contentType" : "COMMENT"
        ]
        
        let uri = Constants.VyrlFeedURL.FEEDREPORT
        
        Alamofire.request(uri, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
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
    
    func showReportAlert(indexPath: IndexPath) {
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        var id : Int!
        
        if(self.article?.comments != nil && (self.article?.cntComment)! > 20 && self.article?.cntComment != self.commentArray.count) {
            id = self.commentArray[indexPath.row - 2].id
        } else {
            id = self.commentArray[indexPath.row - 1].id
        }
        
        let action1 = UIAlertAction(title: "성인 컨텐츠", style: .default, handler: { (action) -> Void in
            self.report(id: id, reportType: ReportType.ADULT)
            self.alertControllerBackgroundTapped()
        })
        
        let action2 = UIAlertAction(title: "해롭겁나 불쾌", style: .default, handler: { (action) -> Void in
             self.report(id: id, reportType: ReportType.OFFEND)
            self.alertControllerBackgroundTapped()
        })
        
        let action3 = UIAlertAction(title: "스팸 또는 사기", style: .default, handler: { (action) -> Void in
             self.report(id: id, reportType: ReportType.SPAM)
            self.alertControllerBackgroundTapped()
        })
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        
        present(alertController, animated: true, completion: {
            alertController.view.superview?.subviews[1].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            alertController.view.superview?.subviews[1].isUserInteractionEnabled = true
        })
    }

    
    func showMoreAlert(indexPath: IndexPath) {
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        
        let reportAction = UIAlertAction(title: "이 게시물 신고하기", style: .default, handler: { (action) -> Void in
            self.alertControllerBackgroundTapped()
            self.showReportAlert(indexPath: indexPath)
        })
       
        let blindAction = UIAlertAction(title: "이 댓글 안보기", style: .default, handler: { (action) -> Void in
            self.alertControllerBackgroundTapped()
        })
        
        let blockAction = UIAlertAction(title: "작성자 차단", style: .default, handler: { (action) -> Void in
            self.alertControllerBackgroundTapped()
        })
        
        let translateAction = UIAlertAction(title: "번역 보기", style: .default, handler: { (action) -> Void in
            self.alertControllerBackgroundTapped()
        })
        
        
        alertController.addAction(reportAction)
        alertController.addAction(blindAction)
        alertController.addAction(blockAction)
        alertController.addAction(translateAction)
        
        
        present(alertController, animated: true, completion: {
            alertController.view.superview?.subviews[1].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            alertController.view.superview?.subviews[1].isUserInteractionEnabled = true
        })
    }
    

    func showAlert(indexPath: IndexPath) {
        let alertController = UIAlertController (title:nil, message:"이 댓글을 영구적으로 삭제하시겠습니가?",preferredStyle:.actionSheet)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .default,handler: { (action) -> Void in
             let url = Constants.VyrlFeedURL.feedCommentDelete(articleId: self.articleId, commentId: self.commentArray[indexPath.row-1].id)
            
            Alamofire.request(url, method: .delete, parameters: nil, encoding:JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    if(response.response?.statusCode == 200){
                        var index = 0
                        let jsonData = json as! NSDictionary
                        self.article?.cntComment = jsonData["cntComment"] as! Int
                        if(self.article?.comments != nil && (self.article?.cntComment)! > 20 && self.article?.cntComment != self.commentArray.count - 1)  {
                            index = 2
                        } else {
                            index = 1
                        }
                        self.commentButton.setTitle(self.article?.commentCount, for: .normal)
                        self.commentArray.remove(at: indexPath.row - index)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                case .failure(let error):
                    print(error)
                }
            })

        })
        let cancelAction = UIAlertAction(title: "취소", style: .destructive, handler: { (action) -> Void in
           self.alertControllerBackgroundTapped()
        })
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: {
            alertController.view.superview?.subviews[1].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            alertController.view.superview?.subviews[1].isUserInteractionEnabled = true
        })
    }
    
    func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showEditFeedAlert(_ sender: UIButton) {
        
        if self.article?.isMyArticle == false {
            return
        }
        
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        
        let modify = UIAlertAction(title: "수정", style: .default,handler: { (action) -> Void in
            let vc : FeedModifyController = self.pushModal(storyboardName: "FeedStyle", controllerName: "feedModify") as! FeedModifyController
            vc.setText(text: (self.article?.content)!)
            vc.articleId = self.article?.id
        })
        let remove = UIAlertAction(title: "삭제", style: .default, handler: { (action) -> Void in
            
            let articleId = (self.article?.id)!
            
            let uri = Constants.VyrlFeedURL.feed(articleId: articleId)
            
            Alamofire.request(uri, method: .delete, parameters: nil, encoding:JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    print(json)
                    
                    if let code = response.response?.statusCode {
                        if code == 200 {
                            self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func followUser(_ sender: UIButton)
    {
        if self.article?.isMyArticle == true {
            return
        }

        
        let uri = URL.init(string: Constants.VyrlFeedURL.follow(followId: (self.article?.profile.id)!))
        Alamofire.request(uri!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
            response in switch response.result {
            case .success(let json):
                print(json)
            case .failure(let error):
                print(error)
            }
        })
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

extension FeedDetailViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.article != nil && self.article?.comments != nil && (self.article?.cntComment)! > 20) {
            if(indexPath.row == 1) {
                self.requestComment()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(self.article?.comments != nil && (self.article?.cntComment)! > 20 && self.article?.cntComment != self.commentArray.count) {
            return self.commentArray.count + 2
        }
        
        return self.commentArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(indexPath.row == 0) {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let currentAccount : Account = LoginManager.sharedInstance.getCurrentAccount()!
        if(currentAccount.nickName == self.commentArray[indexPath.row-1].nickName)
        {
            let delete = UITableViewRowAction(style: .normal, title: "DEL") { (action, indexPath) in
               self.showAlert(indexPath: indexPath)
            }
            delete.backgroundColor = UIColor.red
            return [delete]
        } else {
            let more = UITableViewRowAction(style: .normal, title: "  \u{205D}  ") { (action, indexPath) in
                self.showMoreAlert(indexPath: indexPath)
            }
            more.backgroundColor = UIColor.ivGreyish
            
            return [more]
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneFeed") as! FeedDetailTableCell
            if(self.article != nil) {
                cell.article = self.article
                if((self.article?.medias.count)! > 0){
                    cell.imageScrollView.isHidden = false
                    cell.pageLabel.isHidden = false

                    cell.initImageVideo()
                } else {
                    cell.imageScrollView.isHidden = true
                    cell.pageLabel.isHidden = true
                 }
                
                if (article?.profile.follow)! {
                    cell.followButton.isHidden = true
                } else {
                    cell.followButton.isHidden = false
                }
                
                if(self.feedType == FeedTableType.FANFEED)
                {
                    cell.fanView.isHidden = false
                } else {
                    cell.fanView.isHidden = true
                }
                
                if(article?.isMyArticle == false) {
                    cell.settingButton.isHidden = true
                } else {
                    cell.settingButton.isHidden = false
                }
                
                cell.contentTextView.text = self.article?.content
                cell.contentTextView.resolveHashTags()
                cell.contentTextView.delegate = self
                cell.timeLabel.text = (self.article?.date! as! NSDate).timeAgo()
                
                cell.likeCountButton.setTitle(String("좋아요 \(self.article?.cntLike as! Int)명"), for: .normal)
                cell.shareCountButton.setTitle(String("공유 \(self.article?.cntShare as! Int)명"), for: .normal)
                cell.pageLabel.text = String("1 / \(self.article?.medias.count as! Int)")
                
                if self.article?.profile.imagePath != nil {
                    cell.profileButton.af_setBackgroundImage(for: .normal, url: URL.init(string: (self.article?.profile.imagePath)!)!)
                }
                cell.nickNameLabel.text = self.article?.profile.nickName
                
                cell.profileId = self.article?.profile.id
                cell.delegate = self as FeedDetailTableCellProtocol
            }
            return cell

        } else if (indexPath.row == 1 && self.article != nil) {
            if(self.article?.comments != nil && (self.article?.cntComment)! > 20 && self.article?.cntComment != self.commentArray.count) {
                let  cell = tableView.dequeueReusableCell(withIdentifier: "moreComment") as! FeedDetailTableCell
                return cell
            }
        }
        
        var index = 0
        let  cell = tableView.dequeueReusableCell(withIdentifier: "Comment") as! FeedCommentTableCell
        if(self.article != nil)
        {
           if(self.article?.comments != nil && (self.article?.cntComment)! > 20 && self.article?.cntComment != self.commentArray.count) {
                 index = indexPath.row - 2
            } else {
                 index = indexPath.row - 1
            }
            
            cell.delegate = self as FeedCommentTableCellProtocol
            cell.userId = self.commentArray[index].userId
            cell.commentNicknameLabel.text = self.commentArray[index].nickName
            cell.commentContextTextView.text = self.commentArray[index].content
            cell.commentProfileButton.af_setBackgroundImage(for: .normal, url: URL.init(string: self.commentArray[index].profileImageURL)!)
            cell.commentTimaLavel.text = self.commentArray[index].createAt.toDateTime().timeAgo()

        }
        
        return cell

    }
}

extension FeedDetailViewController : FeedDetailTableCellProtocol {
    func profileButtonDidSelect(profileId : Int) {
        self.showUserProfileView(userId: profileId)
    }
    
    func imageDidSelect(profileId : Int) {
        let storyboard = UIStoryboard(name: "Feed", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FeedFullScreenViewController") as! FeedFullScreenViewController // or whatever it is
        vc.mediasArray = self.article?.medias
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FeedDetailViewController : FeedCommentTableCellProtocol {
    func commentProfileButtonDidSelect(profileId : Int) {
        self.showUserProfileView(userId: profileId)
    }
}

extension FeedDetailViewController : GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension FeedDetailViewController : UITextViewDelegate {
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
            print("mention : \(((URL as NSURL).resourceSpecifier?.removingPercentEncoding)!)")
        default:
            print("just a regular url")
        }
        
        return true
    }

}

extension FeedDetailViewController : EmoticonViewDelegate {
    func setEmoticonID(emoticonID: String) {
        emoticonImageView.isHidden = false
        commentTextView.isHidden = true
        
        emoticonImageView.image = UIImage.init(named: "\(emoticonID)")
    }
    
    func unsetEmoticonID() {
        emoticonImageView.isHidden = true
        commentTextView.isHidden = false
    }
}

struct Comment : Mappable {
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    init?(map: Map) {
        
    }
    var id : Int!
    var userId : Int!
    var content : String!
    var nickName : String!
    var profileImageURL : String!
    var createAt : String!

    mutating func mapping(map: Map){
        id <- map["id"]
        content <- map["content"]
        nickName <- map["nickName"]
        profileImageURL <- map["profile"]
        createAt <- map["createdAt"]
        userId <- map["userId"]
    }
}


protocol FeedDetailTableCellProtocol {
    func profileButtonDidSelect(profileId : Int)
    func imageDidSelect(profileId : Int)
}

class FeedDetailTableCell : UITableViewCell {
    var article : Article!
    var imageViewArray : [UIImageView] = []
    var subScrollViewArray : [UIScrollView] = []
    var lastRequestIndex : Int = 0;
    var currentIndex : Int = 0;
    var profileId : Int!
    var delegate: FeedDetailTableCellProtocol!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var shareCountButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var fanView: UIView!
    @IBOutlet weak var videoPlayButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if(self.imageScrollView != nil) {
            self.imageScrollView.delegate = self as UIScrollViewDelegate
            self.contentTextView.textContainerInset = UIEdgeInsets.zero
            self.contentTextView.textContainer.lineFragmentPadding = 0
        }
    }
    
    func initImageVideo() {
        self.lastRequestIndex = 0
        
        for i in 0..<(article.medias.count) {
            var contentImageView : UIImageView
            
            let url = URL.init(string: article.medias[i].imageUrl)
            if(url?.pathExtension == "gif")
            {
                contentImageView = FLAnimatedImageView()
            } else {
                
                contentImageView = UIImageView()
            }
            
            self.imageViewArray.append(contentImageView)
           
            let subScrollView = UIScrollView()
            subScrollView.frame = CGRect.init(x: 0, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            subScrollView.addGestureRecognizer(tapGestureRecognizer)
           
            self.subScrollViewArray.append(subScrollView)
            self.imageScrollView.contentSize.width = self.imageScrollView.frame.width * CGFloat(i+1)
            self.imageScrollView.addSubview(subScrollView)
        }

        self.requestImageVideo()
        self.showVideoButton()
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.delegate.imageDidSelect(profileId: profileId)
    }
    
    func requestImageVideo() {
        
        var uri : URL
        uri = URL.init(string: article.medias[lastRequestIndex].imageUrl!)!
        
        Alamofire.request(uri)
                .downloadProgress(closure: { (progress) in
                    
                }).responseData { response in
                    if let data = response.result.value {
                        if(uri.pathExtension == "gif") {
                           (self.imageViewArray[self.lastRequestIndex] as! FLAnimatedImageView).animatedImage = FLAnimatedImage.init(animatedGIFData: data)
                        } else {
                            self.imageViewArray[self.lastRequestIndex].image =  UIImage(data: data)!
                        }
                        self.imageViewArray[self.lastRequestIndex].contentMode = .scaleAspectFit
                        self.imageViewArray[self.lastRequestIndex].frame = CGRect.init(x: 0, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
                        
                        self.subScrollViewArray[self.lastRequestIndex].addSubview(self.imageViewArray[self.lastRequestIndex])
                        
                        let xPosition = self.imageScrollView.frame.width * CGFloat(self.lastRequestIndex)
                        self.subScrollViewArray[self.lastRequestIndex].frame = CGRect.init(x: xPosition, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
                }
            }
      }
    
    func showVideoButton() {
        if(self.article.medias[currentIndex].type == "VIDEO")
        {
            self.videoPlayButton.isHidden = false
        } else {
            self.videoPlayButton.isHidden = true
        }
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        let uri : URL = URL.init(string: self.article.medias[currentIndex].url!)!
        
        if(self.imageViewArray[currentIndex].layer.sublayers != nil) {
            self.imageViewArray[currentIndex].layer.sublayers?.removeAll()
        }
        
        self.player?.pause()
        
        self.playerItem = AVPlayerItem.init(url: uri)
        self.player = AVPlayer.init(playerItem: self.playerItem)
        
        self.playerLayer = AVPlayerLayer(player: player)
        self.imageViewArray[currentIndex].layer.addSublayer(self.playerLayer!)
        self.playerLayer?.frame = self.imageViewArray[currentIndex].frame
        
        self.player?.play()
        
        self.videoPlayButton.isHidden = true
    }
    
    @IBAction func profileButtonClick(_ sender: UIButton) {
        delegate.profileButtonDidSelect(profileId: self.profileId)
    }
    
 
}

extension FeedDetailTableCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("\(#function)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("\(#function)")
        self.showVideoButton()
        
        let page = Int(round(Double(scrollView.contentOffset.x) / Double(scrollView.bounds.size.width)))
        self.currentIndex = page
        self.pageLabel.text =  String("\(page+1) / \(self.article.medias.count)")
        
        if(page > self.lastRequestIndex) {
            self.lastRequestIndex = page
            self.requestImageVideo()
        }
    }

}

protocol FeedCommentTableCellProtocol {
    func commentProfileButtonDidSelect(profileId : Int)
}

class FeedCommentTableCell : UITableViewCell {
    @IBOutlet weak var commentNicknameLabel: UILabel!
    @IBOutlet weak var commentProfileButton: UIButton!
    @IBOutlet weak var commentContextTextView: UITextView!
    @IBOutlet weak var commentTimaLavel: UILabel!
    var userId : Int!
    
    var delegate: FeedCommentTableCellProtocol!
    
    override func awakeFromNib() {
        self.commentContextTextView.textContainerInset = UIEdgeInsets.zero
        self.commentContextTextView.textContainer.lineFragmentPadding = 0
    }
    
    @IBAction func profileButtonClick(_ sender: UIButton) {
        delegate.commentProfileButtonDidSelect(profileId: self.userId)
    }
    
}

extension String
{
    func toDateTime() -> NSDate
    {
        //Create Date Formatter
        let dateFormatter = DateFormatter()
        
        //Specify Format of String to Parse
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        //Parse into NSDate
        let dateFromString : NSDate = dateFormatter.date(from: self)! as NSDate
        
        //Return Parsed Date
        return dateFromString
    }
}
