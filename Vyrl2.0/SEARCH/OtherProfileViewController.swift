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
    
    var profileUserId : Int!
    var followState : Bool! = false
    
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
        let controller = storyboard.instantiateViewController(withIdentifier: "PostCollection")
        
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
                        
                        if(jsonData["follow"].bool == true)
                        {
                            self.followButton.setImage(UIImage.init(named: "icon_check_05_on"), for: .normal)
                            self.followButton.tag = 1
                        } else {
                            self.followButton.setImage(UIImage.init(named: "icon_check_05_off"), for: .normal)
                            self.followButton.tag = 0
                        }
                        
                        self.post.text = "\(jsonData["articleCount"].intValue)"
                        self.following.text = "\(jsonData["followingCount"].intValue)"
                        self.follower.text = "\(jsonData["followerCount"].intValue)"
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
        self.setupFeed(feedType: FeedTableType.USERFEED)
    }
    
    @IBAction func showPost(_ sender: Any) {
        self.setupPostContainer()
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
