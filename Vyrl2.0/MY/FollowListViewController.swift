//
//  FollowListViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 9. 26..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire

public enum FollowType : String{
    case Follower   = "follower"
    case Following = "following"
}

class FollowListViewController: UIViewController {

    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var followType = FollowType.Follower
    
    var followUserArray = [[String : Any]]()
    var articleId : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestLikeUser()
    }
    
    func requestLikeUser() {
        followUserArray.removeAll()
        
        var uri = Constants.VyrlAPIURL.FOLLOWER
        self.likeLabel.text = "FOLLOWER"
        
        
        if(followType == FollowType.Following) {
            uri = Constants.VyrlAPIURL.FOLLOWING
            self.likeLabel.text = "FOLLOWING"
        }
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: LoginManager.sharedInstance.getHeader()).responseString(completionHandler: {
            response in
            switch response.result {
            case .success:
                if let statusesArray = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [[String: Any]] {
                    // Finally we got the username
                    if(statusesArray == nil) {
                        self.followUserArray.removeAll()
                    } else {
                        self.followUserArray = statusesArray!
                    }
                    
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        })
        
    }
}

extension FollowListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followUserArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LikeUserTableViewCell
        
        let user = self.followUserArray[indexPath.row]
        
        cell.nicNameLabel.text = user["nickName"] as? String
        
        if(user["profile"] != nil){
            let url = NSURL(string: (user["profile"] as? String)!)
            cell.profileImageView.af_setImage(withURL: url! as URL)
        }
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

