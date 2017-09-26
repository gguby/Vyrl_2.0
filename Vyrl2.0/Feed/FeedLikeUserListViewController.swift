//
//  FeedLikeUserListViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 8. 3..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire

class FeedLikeUserListViewController: UIViewController {
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var likeUserArray = [[String : Any]]()
    var articleId : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestLikeUser()
    }
    
    func requestLikeUser() {
        likeUserArray.removeAll()
        
        let uri = Constants.VyrlFeedURL.usersFeedLike(articleId: self.articleId)
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: LoginManager.sharedInstance.getHeader()).responseString(completionHandler: {
            response in
            switch response.result {
            case .success:
                if let statusesArray = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [[String: Any]] {
                    // Finally we got the username
                    if(statusesArray == nil) {
                        self.likeUserArray.removeAll()
                    } else {
                        self.likeUserArray = statusesArray!
                    }
                    self.likeLabel.text = "\(self.likeUserArray.count)명이 좋아해요"
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        })

    }
    
}

extension FeedLikeUserListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likeUserArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LikeUserTableViewCell
        
        let user = self.likeUserArray[indexPath.row]
        
        cell.nicNameLabel.text = user["nickName"] as? String
        let url = NSURL(string: (user["profile"] as? String)!)
        cell.profileImageView.af_setImage(withURL: url! as URL)
        cell.profileUserId = user["id"] as! Int
        
        
        if user["follow"] as? String != "false" {
            if(LoginManager.sharedInstance.getCurrentAccount()?.nickName == user["nickName"] as? String) {
                cell.isMe = true
            }
            cell.isFollow = true
        } else {
            cell.isFollow = false
        }
        
        return cell
    }
}

class LikeUserTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicNameLabel: UILabel!
    @IBOutlet weak var officialImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    
    var profileUserId : Int!
    var isMe : Bool! = false
    
    var isFollow : Bool! {
        didSet {
            if isFollow {
                self.followButton.setImage(UIImage.init(named: "icon_check_05_on"), for: .normal)
                self.followButton.tag = 1
            } else {
                self.followButton.setImage(UIImage.init(named: "icon_add_01"), for: .normal)
                self.followButton.tag = 0
            }
        }
    }

    @IBAction func followButtonClick(_ sender: UIButton) {
        if(isMe){
            return;
        }
        
        var method = HTTPMethod.post
        
        if sender.tag == 1 {
            method = HTTPMethod.delete
        }
        
        let uri = URL.init(string: Constants.VyrlFeedURL.follow(followId: self.profileUserId))
        Alamofire.request(uri!, method: method, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
            response in switch response.result {
            case .success(let result):
                if sender.tag == 0 {
                    sender.setImage(UIImage.init(named: "icon_check_05_on"), for: .normal)
                    sender.tag = 1
                }else {
                    sender.setImage(UIImage.init(named: "icon_add_01"), for: .normal)
                    sender.tag = 0
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
}

