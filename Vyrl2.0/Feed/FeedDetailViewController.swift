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
    var feedDetail : FeedDetail!
    
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
        requestComment()
        
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func likeListButtonClick(_ sender: UIButton) {
        print("like")
        self.pushView(storyboardName: "Feed", controllerName: "FeedLikeUserListViewController")
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
                    self.requestComment()
                    self.showButtonView()
                })
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func likeButtonClick(_ sender: UIButton) {
        if sender.tag == 0 {
            let uri = URL.init(string: Constants.VyrlFeedURL.feedLike(articleId: (articleId)!))
            Alamofire.request(uri!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
                response in switch response.result {
                case .success(let json):
                    print(json)
                    sender.setImage(UIImage.init(named: "icon_heart_01_on"), for: .normal)
                    sender.tag = 1
                case .failure(let error):
                    print(error)
                }
            })
        }else {
            
            let uri = URL.init(string: Constants.VyrlFeedURL.feedLike(articleId: (articleId)!))
            Alamofire.request(uri!, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
                response in switch response.result {
                case .success(let json):
                    print(json)
                    sender.setImage(UIImage.init(named: "icon_heart_01"), for: .normal)
                    sender.tag = 0
                    
                case .failure(let error):
                    print(error)
                }
            })
        }
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
        let uri = URL.init(string: Constants.VyrlFeedURL.feedComment(articleId: articleId))
        
        Alamofire.request(uri!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Comment]>) in
            
            let array = response.result.value ?? []
            self.commentArray.removeAll()
            for comment in array {
               self.commentArray.append(comment)
             }
            self.tableView.reloadData()
        }
    }
    
    func requestFeedDetail() {
         let url = URL.init(string: Constants.VyrlFeedURL.feed(articleId: articleId))
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                
                if let code = response.response?.statusCode {
                    if code == 200 {
                        let jsonData = json as! NSDictionary
                        self.feedDetail = FeedDetail.init()
                        self.feedDetail.commentCount = jsonData["cntComment"] as! Int
                        self.feedDetail.likeCount = jsonData["cntLike"] as! Int
                        self.feedDetail.shareCount = jsonData["cntShare"] as! Int
                        self.feedDetail.content = jsonData["content"] as! String
                        self.feedDetail.id = jsonData["id"] as! Int
                        self.feedDetail.mediasArray = jsonData["media"] as? [[String:
                            String]]
                        
                        let profile = jsonData["profile"] as! [String : AnyObject]
                        
                        self.feedDetail.profileId = profile["id"] as! Int
                        self.feedDetail.profileImagePath = profile["imagePath"] as! String
                        self.feedDetail.profileNickname = profile["nickName"] as! String
                        
                        self.likeButton.setTitle("\(self.feedDetail.likeCount as Int)", for: .normal)
                        self.commentButton.setTitle("\(self.feedDetail.commentCount as Int)", for: .normal)
                        self.shareButton.setTitle("\(self.feedDetail.shareCount as Int)", for: .normal)
                        
                        self.tableView.reloadData()
                    }
                }
             case .failure(let error):
                print(error)
            }

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

    
    func showReportAlert(indexPath: IndexPath) {
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        
        let action1 = UIAlertAction(title: "성인 컨텐츠", style: .default, handler: { (action) -> Void in
            self.alertControllerBackgroundTapped()
        })
        
        let action2 = UIAlertAction(title: "해롭겁나 불쾌", style: .default, handler: { (action) -> Void in
            self.alertControllerBackgroundTapped()
        })
        
        let action3 = UIAlertAction(title: "스팸 또는 사기", style: .default, handler: { (action) -> Void in
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
            
            Alamofire.request(url, method: .delete, parameters: nil, encoding:JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: { (response) in
                switch response.result {
                case .success(let json):
                    if(response.response?.statusCode == 200){
                        self.requestComment()
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
        
        
//        alertController.popoverPresentationController?.sourceView = currentCell?.contentView
//        alertController.popoverPresentationController?.sourceRect = self.tableView.cellForRow(at: indexPath)!.frame
//        alertController.popoverPresentationController?.sourceRect = self.tableView.convert(self.tableView.rectForRow(at: indexPath), to: self.tableView.superview)
        
        present(alertController, animated: true, completion: {
            alertController.view.superview?.subviews[1].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            alertController.view.superview?.subviews[1].isUserInteractionEnabled = true
        })
    }
    
    func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }

}

extension FeedDetailViewController : UITableViewDelegate, UITableViewDataSource {
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
            let delete = UITableViewRowAction(style: .destructive, title: "       ") { (action, indexPath) in
                // delete item at indexPath
                self.showAlert(indexPath: indexPath)
            }
            delete.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "icon_more_02.png")!)
            
            return [delete]
        } else {
            let more = UITableViewRowAction(style: .normal, title: "       ") { (action, indexPath) in
                self.showMoreAlert(indexPath: indexPath)
            }
            more.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "icon_more_02.png")!)
            
            return [more]
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.commentArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "oneFeed") as! FeedDetailTableCell
            if(self.feedDetail != nil) {
                cell.feedDetail = self.feedDetail
                cell.initImageVideo()
                
                cell.contentTextView.text = self.feedDetail.content
                cell.contentTextView.resolveHashTags()
                cell.likeCountButton.setTitle(String("좋아요 \(self.feedDetail.likeCount!)명"), for: .normal)
                cell.shareCountButton.setTitle(String("공유 \(self.feedDetail.shareCount!)명"), for: .normal)
                cell.pageLabel.text = String("1 / \(self.feedDetail.mediasArray.count)")
                
                cell.profileButton.af_setBackgroundImage(for: .normal, url: URL.init(string: self.feedDetail.profileImagePath)!)
                cell.nickNameLabel.text = self.feedDetail.profileNickname
                
                cell.profileId = self.feedDetail.profileId
                cell.delegate = self
            }
            return cell
            
        default:
          let  cell = tableView.dequeueReusableCell(withIdentifier: "Comment") as! FeedCommentTableCell
            cell.commentNicknameLabel.text = self.commentArray[indexPath.row-1].nickName
            cell.commentContextTextView.text = self.commentArray[indexPath.row-1].content
            cell.commentProfileButton.af_setBackgroundImage(for: .normal, url: URL.init(string: self.commentArray[indexPath.row-1].profileImageURL)!)
            
            return cell
        }
        
        
    }
}

extension FeedDetailViewController : CellDidSelectProtocol {
    func profileButtonDidSelect(profileId : Int) {
        
    }
    
    func imageDidSelect(profileId : Int) {
        let storyboard = UIStoryboard(name: "Feed", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FeedFullScreenViewController") as! FeedFullScreenViewController // or whatever it is
        vc.mediasArray = self.feedDetail.mediasArray
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FeedDetailViewController : GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
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
    var content : String!
    var nickName : String!
    var profileImageURL : String!

    mutating func mapping(map: Map){
        id <- map["id"]
        content <- map["content"]
        nickName <- map["nickName"]
        profileImageURL <- map["profile"]
    }
}

struct FeedDetail{
    init() {
        
    }
    
    var id : Int!
    var mediasArray : [[String:String]]!
    var content : String!
    var commentCount : Int!
    var likeCount : Int!
    var shareCount : Int!
    
    var profileId: Int!
    var profileImagePath : String!
    var profileNickname : String!
    
}

protocol CellDidSelectProtocol {
    func profileButtonDidSelect(profileId : Int)
    func imageDidSelect(profileId : Int)
}

class FeedDetailTableCell : UITableViewCell {
    var feedDetail : FeedDetail!
    var imageViewArray : [UIImageView] = []
    var index : Int = 0;
    var profileId : Int!
    var delegate: CellDidSelectProtocol!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var shareCountButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imageScrollView.delegate = self as UIScrollViewDelegate
        self.contentTextView.textContainerInset = UIEdgeInsets.zero
        self.contentTextView.textContainer.lineFragmentPadding = 0
    }
    
    func initImageVideo() {
        self.index = 0
        
        for i in 0..<(feedDetail.mediasArray.count) {
            let contentImageView = UIImageView()
            contentImageView.frame = CGRect.init(x: 0, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            contentImageView.isUserInteractionEnabled = true
            contentImageView.addGestureRecognizer(tapGestureRecognizer)
            
            self.imageViewArray.append(contentImageView)
            
            self.imageScrollView.contentSize.width = contentImageView.frame.width * CGFloat(i+1)
            self.imageScrollView.addSubview(contentImageView)
        }

        self.requestImageVideo()
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        delegate.imageDidSelect(profileId: self.profileId)
    }
    
    func requestImageVideo() {
        
        var uri : URL
        if(feedDetail.mediasArray[index]["type"] == "IMAGE"){
            uri = URL.init(string: feedDetail.mediasArray[index]["url"]!)!
        } else {
            uri = URL.init(string: feedDetail.mediasArray[index]["thumbnail"]!)!
        }
        
            Alamofire.request(uri)
                .downloadProgress(closure: { (progress) in
                    
                }).responseData { response in
                    if let data = response.result.value {
                       let image = UIImage(data: data)
                        
                        self.imageViewArray[self.index].image = image
                        self.imageViewArray[self.index].contentMode = .scaleAspectFit
                        
                        let xPosition = self.imageScrollView.frame.width * CGFloat(self.index)
                        self.imageViewArray[self.index].frame = CGRect.init(x: xPosition, y: 0, width: self.imageScrollView.frame.width, height: (image?.size.height)!)
                        
                        self.imageScrollView.contentSize.height = (image?.size.height)!
                    }
            }
      }
 
}

extension FeedDetailTableCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(Double(scrollView.contentOffset.x) / Double(scrollView.bounds.size.width)))
        self.pageLabel.text =  String("\(page+1) / \(self.feedDetail.mediasArray.count)")
        
        if(page > self.index) {
            self.index = page
            self.requestImageVideo()
        }
        
    }
}

class FeedCommentTableCell : UITableViewCell {
    @IBOutlet weak var commentNicknameLabel: UILabel!
    @IBOutlet weak var commentProfileButton: UIButton!
    @IBOutlet weak var commentContextTextView: UITextView!
    
    override func awakeFromNib() {
        self.commentContextTextView.textContainerInset = UIEdgeInsets.zero
        self.commentContextTextView.textContainer.lineFragmentPadding = 0
    }
}
