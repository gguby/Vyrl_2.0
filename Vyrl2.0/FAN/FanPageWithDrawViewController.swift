//
//  FanPageWithDrawViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 9. 1..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

class FanPageWithDrawViewController : UIViewController ,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    var userList = [FanPageUser]()
    var fanPage : FanPage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getFanPageUserList()
        
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func getFanPageUserList(){
        let uri = Constants.VyrlFanAPIURL.joinUserList(fanPageId: self.fanPage.fanPageId)
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[FanPageUser]>) in
            
            self.userList.removeAll()
            
            let array = response.result.value ?? []
            
            self.userList.append(contentsOf: array)
            
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "delegateUser", for: indexPath) as! DelegateUserCell
        
        let fanPageUser = self.userList[indexPath.row]
        
        cell.profile.af_setImage(withURL: URL.init(string: fanPageUser.pageprofileImagePath!)!)
        
        if fanPageUser.level == "OWNER" {
            cell.isOwner = true
        }else {
            cell.isOwner = false
        }
        
        cell.userTitle.text = fanPageUser.nickName
        
        return cell
    }
}

class DelegateUserCell : UITableViewCell {
    
    @IBOutlet weak var userTitle: UILabel!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var delegateUser: UIButton!
    
    var isOwner : Bool! {
        didSet {
            if isOwner {
                self.profile.borderColor = UIColor.ivLighterPurple
            }else {
                self.profile.borderColor = UIColor.black
            }
        }
    }
    
    var deleageStatus : DelegateStatus! {
        didSet {
            if deleageStatus == DelegateStatus.normal {
                self.delegateUser.isEnabled = true
            }else if deleageStatus == DelegateStatus.notRequest {
                self.delegateUser.isEnabled = false
            }else {
                self.delegateUser.backgroundColor = UIColor.ivLighterPurple
                self.delegateUser.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.delegateUser.setTitleColor(UIColor.init(red: 62.0/255.0, green: 58.0/255.0, blue: 57.0/255.0, alpha: 1), for: .normal)
        self.delegateUser.setTitleColor(UIColor.ivGreyish, for: .disabled)
    }
}

struct FanPageUser : Mappable {
    
    var fanPageId : Int!
    var fanPageMemberId : Int!
    var followCheck : String!
    var level : String!
    var nickName : String!
    var pageprofileImagePath : String!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        fanPageId <- map["fanPageId"]
        fanPageMemberId <- map["fanPageMemberId"]
        followCheck <- map["followCheck"]
        level <- map["level"]
        nickName <- map["nickname"]
        pageprofileImagePath <- map["profileImagePath"]
    }
}

enum DelegateStatus : Int {
    case normal = 1
    case request = 2
    case notRequest = 3
}
