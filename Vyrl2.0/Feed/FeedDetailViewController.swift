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
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var closeEmoticonButton: UIButton!
    @IBOutlet weak var emoticonImageView: UIImageView!
    @IBOutlet weak var showEmoticonButton: UIButton!
    
    @IBOutlet weak var postCommentButton: UIButton!
   
    var emoticonView : EmoticonView!
    var kbHeight: CGFloat!
    
    var commentArray : [Comment] = []
    
    var tapGesture : UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.reloadData()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        
         self.commentTextView.textContainerInset = UIEdgeInsetsMake(12, 0, 12, 0)
        
        showButtonView()
        requestComment()
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
        let uri = Constants.VyrlAPIConstants.baseURL + "feeds/17/comments"

        
        let parameters : Parameters = [
            "content": self.commentTextView.text!,
            ]

        
        Alamofire.request(uri, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON { (response) in
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
       
        let uri = Constants.VyrlAPIConstants.baseURL + "/feeds/17/comments"
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Comment]>) in
            
            let array = response.result.value ?? []
            self.commentArray.removeAll()
            for comment in array {
               
                self.commentArray.append(comment)
                
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
            let uri = Constants.VyrlAPIConstants.baseURL + "/feeds/17/comments/\(self.commentArray[indexPath.row-1].id as Int)"
            
            Alamofire.request(uri, method: .delete, parameters: nil, encoding:JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: { (response) in
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
        var cell :FeedDetailTableCell = tableView.dequeueReusableCell(withIdentifier: "oneFeed") as! FeedDetailTableCell
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "oneFeed") as! FeedDetailTableCell
            break
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "Comment") as! FeedDetailTableCell
            cell.commentNicknameLabel.text = self.commentArray[indexPath.row-1].nickName
            cell.commentContextTextView.text = self.commentArray[indexPath.row-1].content
            cell.commentProfileButton.af_setBackgroundImage(for: .normal, url: URL.init(string: self.commentArray[indexPath.row-1].profileImageURL)!)
            
            break
        }
        
        return cell
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

class FeedDetailTableCell : UITableViewCell {
    let samplePhotos = ["https://cdn2.vyrl.com/vyrl/images/post/_temp/temp/4ec6d08055c4ebcc76494080bbcd4ee2.jpg",
                        "https://cdn2.vyrl.com/vyrl/images/post/_temp/54841/cfc79b7201ff0caae5fb1f25ac7145a8.jpg",
                        "https://cdn2.vyrl.com/vyrl/images/post/_temp/temp/ae47d8dd720a1f1b36c6aebe635663c7.jpg",
                        "https://cdn2.vyrl.com/vyrl/images/post/_temp/temp/77ee0896da31740db3ee64fd2f30795a.jpg",
                        "https://cdn2.vyrl.com/vyrl/images/post/_temp/temp/b0926fdcadf9b4ab2083efaee041cfc7.jpg"
    ]
    let sampleVideo = ["http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v",
                       "https://firebasestorage.googleapis.com/v0/b/shaberi-a249e.appspot.com/o/message-videos%2F8EDAC3FC-D754-4165-990A-97F6ECE120A6.mp4?alt=media&token=b3271370-a408-467d-abbc-7df2beef45c7"
    ]
    var imageViewArray : [UIImageView] = []
    var index : Int = 0;
    
   
    @IBOutlet weak var commentNicknameLabel: UILabel!
    @IBOutlet weak var commentProfileButton: UIButton!
    @IBOutlet weak var commentContextTextView: UITextView!
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if(self.imageScrollView != nil) {
            self.imageScrollView.delegate = self as UIScrollViewDelegate
            self.index = 0
            self.initImageVideo()
        } else if (commentNicknameLabel != nil) {
            
        }
    }
    
    func initImageVideo() {
        for i in 0..<(samplePhotos.count) + (sampleVideo.count)  {
            let contentImageView = UIImageView()
            contentImageView.frame = CGRect.init(x: 0, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
            self.imageViewArray.append(contentImageView)
            
            self.imageScrollView.contentSize.width = contentImageView.frame.width * CGFloat(i+1)
            self.imageScrollView.addSubview(contentImageView)
        }
        
        requestImageVideo()
    }
    
    func requestImageVideo() {
        if(self.index > self.samplePhotos.count-1)
        {
            let asset = AVURLAsset.init(url: URL(string:sampleVideo[1])!)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try! imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let uiImage = UIImage.init(cgImage:  cgImage)
            
            self.imageViewArray[self.index].image = uiImage
            self.imageViewArray[self.index].contentMode = .scaleAspectFit
            
            let xPosition = self.imageScrollView.frame.width * CGFloat(self.index)
            self.imageViewArray[self.index].frame = CGRect.init(x: xPosition, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
            
        } else {
            Alamofire.request(samplePhotos[index])
                .downloadProgress(closure: { (progress) in
                    
                }).responseData { response in
                    if let data = response.result.value {
                       let image = UIImage(data: data)
                        
                        self.imageViewArray[self.index].image = image
                        self.imageViewArray[self.index].contentMode = .scaleAspectFit
                        
                        let xPosition = self.imageScrollView.frame.width * CGFloat(self.index)
                        self.imageViewArray[self.index].frame = CGRect.init(x: xPosition, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
                    }
            }
        }
    }
    
   
}

extension FeedDetailTableCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(Double(scrollView.contentOffset.x) / Double(scrollView.bounds.size.width)))
        
        if(page > self.index) {
            self.index = page
            self.requestImageVideo()
        }
        
    }
}
