//
//  ActivityViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 11. 3..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import NSDate_TimeAgo


class ActivityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var activityArray : [ActivityMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getActivityList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getActivityList() {
        let uri = Constants.VyrlAPIURL.ACTIVITY
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[ActivityMessage]>) in
            
            response.result.ifFailure {
                return
            }
            
            let array = response.result.value ?? []
            self.activityArray.removeAll()
            self.activityArray = array
            
            self.tableView.reloadData()
        }
    }
}

extension ActivityViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activityArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        
        
        let followerNickname : String = self.activityArray[indexPath.row].profile.nickName
        let attr: [String: AnyObject] = [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 13.0)!,
                                         NSForegroundColorAttributeName: UIColor(red: 62.0 / 255.0, green: 58.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)]
        let attributedString = NSMutableAttributedString.init(string: "\(followerNickname.description)님이 회원님을 팔로우 하였습니다.")
        attributedString.addAttributes(attr, range: (attributedString.string as NSString).range(of: followerNickname))
        
        cell.content.attributedText = attributedString
        cell.timeLabel.text = self.activityArray[indexPath.row].date?.timeAgo()
        
        return cell
    }
}

class ActivityTableViewCell : UITableViewCell {
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}

struct ActivityMessage : Mappable {
    var articleId : Int!
    var id : Int!
    var userId : Int!
    var targetId : Int!
    var profile : Profile!
    
    var message : String!
    var nickName : String!
    var type : String!
    
    var createAt : String!
    var date : NSDate?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        articleId <- map["articleId"]
        createAt <- map["createdAt"]
        message <- map["message"]
        id <- map["id"]
        nickName <- map["nickName"]
        targetId <- map["targetId"]
        type <- map["type"]
        userId <- map["userId"]
        profile <- map["profile"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let dateString = map["createdAt"].currentValue as? String, let _date = dateFormatter.date(from: dateString){
            date = _date as NSDate
        }
    }
    
    
}
