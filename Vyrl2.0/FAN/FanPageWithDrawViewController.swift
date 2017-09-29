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

protocol AuthChangeDelegate {
    func change(cell : DelegateUserCell)
}

class FanPageWithDrawViewController : UIViewController ,UITableViewDelegate, UITableViewDataSource, AuthChangeDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var userList = [FanPageUser]()
    var fanPage : FanPage!
    var isRequestDelegate = false
    
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
        cell.fanPageUser = fanPageUser
        cell.delegate = self
        
        return cell
    }
    
    func change(cell: DelegateUserCell) {
        let fanPageUser = cell.fanPageUser
        
        let parameters : Parameters = [
            "fanPageId": "\(fanPageUser!.fanPageId!)",
            "fanPageMemberId": "\(fanPageUser!.fanPageMemberId!)"
        ]
        
        let uri = URL.init(string: Constants.VyrlFanAPIURL.AuthChange, parameters: parameters as! [String:String])
        
        Alamofire.request(uri!, method: .post,encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                
                let jsonData = json as! NSDictionary
                
                let result = jsonData["result"] as? Bool
                
                if result == true {
                    self.getFanPageUserList()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

class DelegateUserCell : UITableViewCell {
    
    @IBOutlet weak var userTitle: UILabel!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var delegateUser: UIButton!
    
    var delegate : AuthChangeDelegate!
    var fanPageUser : FanPageUser! {
        didSet {
            
            self.profile.af_setImage(withURL: URL.init(string: fanPageUser.pageprofileImagePath!)!)
            
            if fanPageUser.level == "OWNER" {
                self.isOwner = true
            }else {
                self.isOwner = false
            }
            
            self.userTitle.text = fanPageUser.nickName
            
            self.deleageStatus = DelegateStatus.init(rawValue: fanPageUser.requestState)

        }
    }
    
    var isOwner : Bool! {
        didSet {
            if isOwner {
                self.profile.borderColor = UIColor.ivLighterPurple
                self.delegateUser.isEnabled = false
            }else {
                self.profile.borderColor = UIColor.black
            }
        }
    }
    
    var deleageStatus : DelegateStatus! {
        didSet {
            if deleageStatus == DelegateStatus.none {
                self.delegateUser.isEnabled = true
            }else if deleageStatus == DelegateStatus.disable {
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
        self.delegateUser.addTarget(self, action: #selector(delegateUser(sender:)), for: .touchUpInside)
    }
    
    func delegateUser(sender : UIButton ){
        self.delegate.change(cell: self)
    }
    
}

struct FanPageUser : Mappable {
    
    var fanPageId : Int!
    var fanPageMemberId : Int!
    var followCheck : String!
    var level : String!
    var nickName : String!
    var pageprofileImagePath : String!
    var requestState : String!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        fanPageId <- map["fanPageId"]
        fanPageMemberId <- map["fanPageMemberId"]
        followCheck <- map["followCheck"]
        level <- map["level"]
        nickName <- map["nickName"]
        pageprofileImagePath <- map["profileImagePath"]
        requestState <- map["requestState"]
    }
}

enum DelegateStatus : String {
    case none = "NONE"
    case request = "REQUEST"
    case disable = "DISABLE"
}
