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
        
        cell.content.text = self.activityArray[indexPath.row].type
        
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
    
    var message : String!
    var nickName : String!
    var type : String!
    
    var createAt : String!
    
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
    }
    
    
}
