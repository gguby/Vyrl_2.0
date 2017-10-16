//
//  NotificationController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 10. 16..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import Alamofire


class NotificationController : UIViewController {
    
    
    @IBOutlet weak var noti1: UISwitch!
    @IBOutlet weak var noti2: UISwitch!
    @IBOutlet weak var noti3: UISwitch!
    @IBOutlet weak var noti4: UISwitch!
    @IBOutlet weak var noti5: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noti1.addTarget(self, action: #selector(noti(sender:)), for: UIControlEvents.valueChanged)
        noti2.addTarget(self, action: #selector(noti(sender:)), for: UIControlEvents.valueChanged)
        noti3.addTarget(self, action: #selector(noti(sender:)), for: UIControlEvents.valueChanged)
        noti4.addTarget(self, action: #selector(noti(sender:)), for: UIControlEvents.valueChanged)
        noti5.addTarget(self, action: #selector(noti(sender:)), for: UIControlEvents.valueChanged)
        
        self.getNoti()
    }
    
    func getNoti(){
        let uri = Constants.VyrlAPIURL.alert
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.getHeader()).responseJSON(completionHandler: {
            response in switch response.result {
            case .success(let json):
                
                let jsonData = json as! NSDictionary
                
                let follower = jsonData["follower"] as! Bool
                let mention = jsonData["mention"] as! Bool
                let comment = jsonData["comment"] as! Bool
                let share = jsonData["share"] as! Bool
                let like = jsonData["like"] as! Bool
                
                self.noti1.isOn = like
                self.noti2.isOn = comment
                self.noti3.isOn = mention
                self.noti4.isOn = share
                self.noti5.isOn = follower
                
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func noti(sender : UISwitch){
        
        let alertType = ALERTTYPE.init(rawValue: sender.tag)
        let parameters : Parameters = [
            "alertType": alertType?.type as Any,
            "checked" : sender.isOn
        ]
        
        let uri = Constants.VyrlAPIURL.alert
        
        Alamofire.request(uri, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: Constants.getHeader()).responseString(completionHandler: {
            response in
            switch response.result {
            case .success(let json) :
                print(json)
            case .failure(let error) :
                print(error)
            }
        })
    }
}


enum ALERTTYPE : Int {
    case COMMENT = 0
    case SHARE = 1
    case LIKE = 2
    case MENTION = 3
    case FOLLOWER = 4
    
    var type: String {
        get {
            switch self {
            case .COMMENT:
                return "COMMENT"
            case .FOLLOWER:
                return "FOLLOWER"
            case .LIKE :
                return "LIKE"
            case .MENTION :
                return "MENTION"
            case .SHARE:
                return "SHARE"
            }
        }
    }
}
