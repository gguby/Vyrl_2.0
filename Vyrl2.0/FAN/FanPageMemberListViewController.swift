//
//  FanPageMemberListViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 9. 5..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire

class FanPageMemberListViewController: UIViewController {

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
        
        if fanPageUser.level == "OWNER" {
            cell.isOwner = true
        }else {
            cell.isOwner = false
        }
        
        cell.userTitle.text = fanPageUser.nickName
        
        return cell
    }
}

class FanPageUserCell : UITableViewCell {
    
    @IBOutlet weak var userTitle: UILabel!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var followUserButton: UIButton!
    
    var isOwner : Bool! {
        didSet {
            if isOwner {
                self.profile.borderColor = UIColor.ivLighterPurple
            }else {
                self.profile.borderColor = UIColor.black
            }
        }
    }
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

