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

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        cell.nicNameLabel.text = likeUserArray[indexPath.row]["nickName"] as? String
        if(likeUserArray[indexPath.row]["profile"] != nil) {
            let url = NSURL(string: (likeUserArray[indexPath.row]["profile"] as? String)!)
            cell.profileImageView.af_setImage(withURL: url! as URL)
        }
        
        return cell
    }
}

class LikeUserTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicNameLabel: UILabel!
    @IBOutlet weak var officialImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    
    let id : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func followButtonClick(_ sender: UIButton) {
    }
    
}

