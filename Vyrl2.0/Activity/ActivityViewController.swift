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
         cell.delegate = self as ActivityTableViewCellProtocol
        cell.targetProfile = self.activityArray[indexPath.row].profile
        
        if(self.activityArray[indexPath.row].type == "FOLLOWER"){
            if(cell.targetProfile?.follow == false){
                cell.followButton.isHidden = false
            } else {
                cell.followButton.isHidden = true
            }
        }
        
        let nickname : String = self.activityArray[indexPath.row].profile.nickName
        let message : String = self.activityArray[indexPath.row].message
    
        cell.content.attributedText = self.getContentAttributedText(nickName: nickname, message: message)
        
        cell.timeLabel.text = self.activityArray[indexPath.row].date?.timeAgo()
        cell.photo.af_setImage(withURL: URL.init(string: self.activityArray[indexPath.row].profile.imagePath)!)
        
        return cell
    }
    
    func getContentAttributedText(nickName: String , message: String) -> NSMutableAttributedString{
        let attr: [String: AnyObject] = [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 13.0)!,
                                         NSForegroundColorAttributeName: UIColor(red: 62.0 / 255.0, green: 58.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)]
        let defaultAttr : [String: AnyObject] = [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-Regular", size: 13.0)!,
                                                 NSForegroundColorAttributeName: UIColor(red: 83.0 / 255.0, green: 79.0 / 255.0, blue: 78.0 / 255.0, alpha: 1.0)]
        let attributedString = NSMutableAttributedString.init(string: "\(nickName.description)\(message.description)")
        attributedString.addAttributes(attr, range: (attributedString.string as NSString).range(of: nickName))
        attributedString.addAttributes(defaultAttr, range: (attributedString.string as NSString).range(of: message))
        
        return attributedString
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

class ActivityTableViewCell : UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var mediaImageView: UIImageView!
    var targetProfile : Profile?
    
    var delegate: ActivityTableViewCellProtocol!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLabel))
        content.addGestureRecognizer(tap)
    }
    
    @IBAction func showOtherProfileView(_ sender: Any) {
        delegate.profileButtonDidSelect(profileId: (targetProfile?.userId)!)
    }
    
    @IBAction func showDetailView(_ sender: UIButton) {
        delegate.imageDidSelect(cell: self)
    }
    
    @IBAction func setFollow(_ sender: Any) {
        let method = HTTPMethod.post
        let uri = URL.init(string: Constants.VyrlFeedURL.follow(followId: (targetProfile?.userId)!))
        
        Alamofire.request(uri!, method: method, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
            response in switch response.result {
            case .success( _):
                self.followButton.isHidden = true
                break
                
            case .failure( _):
                break
                
            }
        })
    }
    
    
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        let text = (content.text)!
        let nickNameRange = (text as NSString).range(of: (targetProfile?.nickName)!)
        
        if gesture.didTapAttributedTextInLabel(label: content, inRange: nickNameRange) {
            print("Tapped nickname")
            delegate.profileButtonDidSelect(profileId: (targetProfile?.userId)!)
        } else {
            print("Tapped none")
        }
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

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint.init(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint.init(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
