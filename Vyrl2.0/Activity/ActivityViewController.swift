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
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activityArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NoMediaActivityCell", for: indexPath) as! ActivityTableViewCell
        
         if let media = self.activityArray[indexPath.row].media
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "MediaActivityCell", for: indexPath) as! ActivityTableViewCell
            
            cell.mediaImageView.af_setImage(withURL: URL.init(string: media.imageUrl)!)
        }
        
        cell.delegate = self as! ActivityTableViewCellProtocol
        cell.targetProfile = self.activityArray[indexPath.row].profile
        
        let nickname : String = self.activityArray[indexPath.row].profile.nickName
        let message : String = self.activityArray[indexPath.row].message
        
        let attr: [String: AnyObject] = [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 13.0)!,
                                         NSForegroundColorAttributeName: UIColor(red: 62.0 / 255.0, green: 58.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)]
        let defaultAttr : [String: AnyObject] = [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Regular", size: 13.0)!,
                                                 NSForegroundColorAttributeName: UIColor(red: 83.0 / 255.0, green: 79.0 / 255.0, blue: 78.0 / 255.0, alpha: 1.0)]
        let attributedString = NSMutableAttributedString.init(string: "\(nickname.description)\(message.description)")
        attributedString.addAttributes(attr, range: (attributedString.string as NSString).range(of: nickname))
        attributedString.addAttributes(defaultAttr, range: (attributedString.string as NSString).range(of: message))
        cell.content.attributedText = attributedString
        
        cell.timeLabel.text = self.activityArray[indexPath.row].date?.timeAgo()
        cell.photo.af_setImage(withURL: URL.init(string: self.activityArray[indexPath.row].profile.imagePath)!)
        
        return cell
    }
}

extension ActivityViewController : ActivityTableViewCellProtocol {
    func profileButtonDidSelect(profileId: Int) {
        let otherProfile = self.pushViewControllrer(storyboardName: "Search", controllerName: "OtherProfile") as! OtherProfileViewController
        otherProfile.profileUserId = profileId
    }
    
    func imageDidSelect(cell: ActivityTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        let vc : FeedDetailViewController = self.pushViewControllrer(storyboardName: "FeedDetail", controllerName: "FeedDetailViewController") as! FeedDetailViewController
        vc.articleId = self.activityArray[indexPath.row].articleId
        
    }
    
    
}

protocol ActivityTableViewCellProtocol {
    func profileButtonDidSelect(profileId : Int)
    func imageDidSelect(cell : ActivityTableViewCell)
}

class ActivityTableViewCell : UITableViewCell {
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var mediaImageView: UIImageView!
    
    var targetProfile : Profile?
    
    var delegate: ActivityTableViewCellProtocol!
    
    @IBAction func showOtherProfileView(_ sender: Any) {
        delegate.profileButtonDidSelect(profileId: (targetProfile?.userId)!)
    }
    
    @IBAction func showDetailView(_ sender: UIButton) {
        delegate.imageDidSelect(cell: self)
    }
}


struct ActivityMessage : Mappable {
    var articleId : Int!
    var id : Int!
    var userId : Int!
    var profile : Profile!
    
    var message : String!
    var nickName : String!
    var type : String!
    
    var createAt : String!
    var media : ArticleMedia!
    var date : NSDate?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        articleId <- map["articleId"]
        createAt <- map["createdAt"]
        message <- map["message"]
        id <- map["id"]
        nickName <- map["nickName"]
         type <- map["type"]
        userId <- map["userId"]
        profile <- map["profile"]
        media <- map["media"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let dateString = map["createdAt"].currentValue as? String, let _date = dateFormatter.date(from: dateString){
            date = _date as NSDate
        }
    }
    
    
}
