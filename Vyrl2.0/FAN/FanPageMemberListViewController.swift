//
//  FanPageMemberListViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 9. 5..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire

class FanPageMemberListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var userList = [FanPageUser]()
    var fanPage : FanPage!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getMemberList()
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    func getMemberList() {
        
       let uri = Constants.VyrlFanAPIURL.joinUserList(fanPageId: self.fanPage.fanPageId)
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[FanPageUser]>) in
            
            self.userList.removeAll()
            
            let array = response.result.value ?? []
            
            self.userList.append(contentsOf: array)
            
            
            self.memberLabel.text = "\(self.userList.count)명의 멤버"
            self.tableView.reloadData()
        }

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FanPageUserCell", for: indexPath) as! FanPageUserCell
        
        let fanPageUser = self.userList[indexPath.row]
        
        cell.profile.af_setImage(withURL: URL.init(string: fanPageUser.pageprofileImagePath!)!)
        cell.profileUserId = fanPageUser.fanPageMemberId
        
        if fanPageUser.level == "OWNER" {
            cell.isOwner = true
        }else {
            cell.isOwner = false
        }
        
        if fanPageUser.followCheck != "NONE" {
            if(fanPageUser.followCheck == "ME") {
                cell.isMe = true
            }
            cell.isFollow = true
        } else {
            cell.isFollow = false
        }
        
        
        cell.userTitle.text = fanPageUser.nickName
        
        return cell
    }
}

class FanPageUserCell : UITableViewCell {
    
    @IBOutlet weak var userTitle: UILabel!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var followUserButton: UIButton!
    
    var profileUserId : Int!
    var isMe : Bool! = false
    var isOwner : Bool! {
        didSet {
            if isOwner {
                self.profile.borderColor = UIColor.ivLighterPurple
            }else {
                self.profile.borderColor = UIColor.clear
            }
        }
    }
    
    var isFollow : Bool! {
        didSet {
            if isFollow {
                self.followUserButton.setImage(UIImage.init(named: "icon_check_05_on"), for: .normal)
                self.followUserButton.tag = 1
            } else {
                self.followUserButton.setImage(UIImage.init(named: "icon_add_01"), for: .normal)
                self.followUserButton.tag = 0
            }
        }
    }
   
    @IBAction func setFollow(_ sender: UIButton) {
        if(isMe){
            return;
        }
        
        var method = HTTPMethod.post
        
        if sender.tag == 1 {
            method = HTTPMethod.delete
        }
        
        let uri = URL.init(string: Constants.VyrlFeedURL.follow(followId: self.profileUserId))
        Alamofire.request(uri!, method: method, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON(completionHandler: {
            response in switch response.result {
            case .success(let json):
                
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


    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

