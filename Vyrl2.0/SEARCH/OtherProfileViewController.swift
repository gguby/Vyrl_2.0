//
//  OtherProfileViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 9. 1..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class OtherProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var homepageLabel: UILabel!
    
    @IBOutlet weak var post: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var follower: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var middlePostBtn: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var followerView: UIView!
    @IBOutlet weak var followingView: UIView!
    
    @IBOutlet weak var detailBtn: UIButton!
    var profileUserId : Int!
    var isFollow : Bool! = false
    var isAlert : Bool! = false
    var isBlock : Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupFeed(feedType: FeedTableType.USERFEED)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadUserProfile()
        
        let followerGesture = UITapGestureRecognizer(target: self, action: #selector(self.clickFollowList(sender:)))
        let followingGesture = UITapGestureRecognizer(target: self, action: #selector(self.clickFollowList(sender:)))
        self.followerView.addGestureRecognizer(followerGesture)
        self.followingView.addGestureRecognizer(followingGesture)
    }
    
    func clickFollowList(sender: UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "My", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FollowListViewController") as! FollowListViewController // or whatever it is
        
        if(sender.view == self.followerView){
            vc.followType = FollowType.Follower
        } else {
            vc.followType = FollowType.Following
        }
        
        vc.userId = "\(self.profileUserId!)"
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func setupPostContainer(){
        let storyboard = UIStoryboard(name: "PostCollectionViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PostCollection") as! PostCollectionViewController
        controller.type = .User
        controller.userId = self.profileUserId
        
        controller.removeFromParentViewController()
        controller.view.removeFromSuperview()
        
        addChildViewController(controller)
        containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }

    func setupFeed(feedType : FeedTableType){
        let storyboard = UIStoryboard(name: "FeedStyle", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "feedTable") as! FeedTableViewController
        
        controller.feedType = feedType
        controller.userId = profileUserId
        controller.isEnableUpload = false
        controller.removeFromParentViewController()
        controller.view.removeFromSuperview()
        
        addChildViewController(controller)
        
        controller.view.frame.size.height = containerView.frame.height
        
        containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }

    func getProfile(){
        var uri = Constants.VyrlAPIURL.MYPROFILE
        
        uri = Constants.VyrlAPIURL.userProfile(userId: self.profileUserId)
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON(completionHandler: {
            response in
            
            switch response.result {
            case .success(let json):
                
                if let code = response.response?.statusCode {
                    if code == 200 {
                        let jsonData = JSON(json)
                        
                        self.nickNameLabel.text = jsonData["nickName"].string
                        self.introLabel.text = jsonData["selfIntro"].string
                        self.homepageLabel.text = jsonData["homepageUrl"].string
                        
                        let image = jsonData["imagePath"].string
                        
                        if image?.isEmpty == false {
                            let url = URL.init(string: (image)!)
                            self.profileImage.af_setImage(withURL: url!)
                        }
                        
                        self.isFollow = jsonData["follow"].bool
                        self.isAlert = jsonData["alert"].bool
                        self.isBlock = jsonData["blocked"].bool
                        
                        if(self.isFollow == true)
                        {
                            self.followButton.setImage(UIImage.init(named: "icon_check_05_on"), for: .normal)
                            self.followButton.tag = 1
                        } else {
                            self.followButton.setImage(UIImage.init(named: "icon_check_05_off"), for: .normal)
                            self.followButton.tag = 0
                        }
                        
                        self.post.text = "\(jsonData["articleCount"].intValue)"
                        self.middlePostBtn.text = "\(jsonData["articleCount"].intValue) Post"
                        self.following.text = "\(jsonData["followingCount"].intValue)"
                        self.follower.text = "\(jsonData["followerCount"].intValue)"
                        
                        self.detailBtn.isEnabled = !LoginManager.sharedInstance.isMyProfile(id: self.profileUserId)
                    }
                }
                
                print((response.response?.statusCode)!)
                print(json)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func loadUserProfile(){
        self.getProfile()
    }
    
    @IBAction func showFeed(_ sender: Any) {
        self.setupPostContainer()
    }
    
    @IBAction func showPost(_ sender: Any) {
        self.setupFeed(feedType: FeedTableType.USERFEED)
    }
    
    func showPushCheck(){
        
        var msg = "이 유저의 모든 글을 알림으로 받으시겠습니까?"
        if self.isAlert {
            msg = "이 유저의 모든 글을 알림을 끊습니다."
        }
        
        let alertController = UIAlertController (title:nil, message:msg,preferredStyle:.alert)
        
        let ok = UIAlertAction(title: "네", style: .default,handler: { (action) -> Void in
            
            let uri = Constants.VyrlAPIURL.alert
            
            let parameters : Parameters = [
                "alert": !self.isAlert,
                "followingId" : self.profileUserId
            ]
            
            Alamofire.request(uri, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: Constants.getHeader()).responseString(completionHandler: {
                response in switch response.result {
                case .success(let json):
                   print(json)
                case .failure(let error):
                    print(error)
                }
            })
            
            alertController.dismiss(animated: true, completion: nil )
        })
        
        let cancel = UIAlertAction(title: "아니오", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion:nil)
    }
    
    func showBlockAlert(){
        var str = "이 유저를 차단하면 팔로우가 해제 되고 이 유저는 나를 팔로우 할 수 없게 되며 관련 모든 알림을 받지 않게 됩니다. 차단하시겠습니까?"
        var action = "차단"
        
        if self.isBlock {
            str = "이 유저의 차단을 해제 합니다."
            action = "네"
        }
        
        let alertController = UIAlertController (title:str, message:nil,preferredStyle:.alert)
        
        let prevent = UIAlertAction(title: action, style: .default,handler: { (action) -> Void in
            
            self.blocUser()
            alertController.dismiss(animated: true, completion: nil )
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(prevent)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion:nil)
    }
    
    func showAlert() {
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        
        var str = "알림끄기"
     
        if self.isAlert {
            str = "알림켜기"
        }
        
        let alertAction = UIAlertAction(title: str, style: .default,handler: { (action) -> Void in
            
            self.showPushCheck()
            alertController.dismiss(animated: true, completion: nil )
        })
        
        let preventAction = UIAlertAction(title: "차단하기", style: .default, handler: { (action) -> Void in
            
            self.showBlockAlert()
            alertController.dismiss(animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        if (self.followButton.tag == 1 ){
            alertController.addAction(alertAction)
        }
        
        alertController.addAction(preventAction)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion:nil)
    }
    
    func blocUser(){
        
        let parameters : [String:Any] = [
            "userId": "\(self.profileUserId!)",
            "blocked" : !self.isBlock,
        ]
        
        let uri = URL.init(string: Constants.VyrlAPIURL.BLOCKUSER)
        
        Alamofire.request(uri!, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString { (response) in
            switch response.result {
            case .success(let result) :
                print(result)
                if let code = response.response?.statusCode {
                    if code == 200 {
                        print("200")
                    }
                }
            case .failure(let error) :
                print(error)
            }
        }
    }
    
    @IBAction func showAlert(_ sender: Any) {
        self.showAlert()
    }
    
    @IBAction func setFollow(_ sender: UIButton) {
        var method = HTTPMethod.post
        
        if sender.tag == 1 {
            method = HTTPMethod.delete
        }
        
        let uri = URL.init(string: Constants.VyrlFeedURL.follow(followId: self.profileUserId))
        Alamofire.request(uri!, method: method, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
            response in switch response.result {
            case .success(let json):
                print(json)
                if sender.tag == 0 {
                    sender.setImage(UIImage.init(named: "icon_check_05_on"), for: .normal)
                    sender.tag = 1
                }else {
                    sender.setImage(UIImage.init(named: "icon_check_05_off"), for: .normal)
                    sender.tag = 0
                }
            case .failure(let error):
                print(error)
            }
        })
    }
}

extension OtherProfileViewController : FeedCellDelegate {
    func didPressCell(sender: Any, cell : FeedTableCell) {
        self.pushView(storyboardName: "FeedDetail", controllerName: "FeedDetailViewController")
    }
}
