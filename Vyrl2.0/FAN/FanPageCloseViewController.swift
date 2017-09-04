//
//  FanPageCloseViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 9. 1..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import Alamofire

class FanPageCloseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userList = [FanPageUser]()
    var fanPage : FanPage!
    
    @IBOutlet weak var pushAllBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getFanPageUserList()
        
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    @IBAction func pushAllWithDraw(_ sender: UIButton) {
        if sender.tag == 0 {
            
        }else {
            
        }
    }
    func getFanPageUserList(){
        let uri = Constants.VyrlFanAPIURL.joinUserList(fanPageId: self.fanPage.fanPageId)
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[FanPageUser]>) in
            
            self.userList.removeAll()
            
            let array = response.result.value ?? []
            
            self.userList.append(contentsOf: array)
            
            self.tableView.reloadData()
            
            if array.count == 0 {
                self.pushAllBtn.setTitle("팬페이지 폐쇄하기", for: .normal)
                self.pushAllBtn.tag = 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fanclosecell", for: indexPath) as! FanCloseCell
        
        let fanPageUser = self.userList[indexPath.row]
        
        cell.profile.af_setImage(withURL: URL.init(string: fanPageUser.pageprofileImagePath!)!)
        
        if fanPageUser.level == "OWNER" {
            cell.isOwner = true
        }else {
            cell.isOwner = false
        }
        
        cell.nickname.text = fanPageUser.nickName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fanPageUser = self.userList[indexPath.row]
        
        let otherProfile = self.pushViewControllrer(storyboardName: "Search", controllerName: "OtherProfile") as! OtherProfileViewController
        otherProfile.profileUserId = fanPageUser.fanPageMemberId
    }

}

class FanCloseCell : UITableViewCell {
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    
    var isOwner : Bool! {
        didSet {
            if isOwner {
                self.profile.borderColor = UIColor.ivLighterPurple
            }else {
                self.profile.borderColor = UIColor.black
            }
        }
    }
    
}
