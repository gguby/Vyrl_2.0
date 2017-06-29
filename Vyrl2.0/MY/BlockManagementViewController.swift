//
//  BlockManagementViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 5. 31..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire

class BlockManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
     @IBOutlet weak var tableView: UITableView!
     var blockUserArray = [[String : Any]]()
    
     override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.requestBlockUser()
    }
    
    func requestBlockUser() {
        blockUserArray.removeAll()
        
        let uri = LoginManager.sharedInstance.baseURL + "my/blockedUser"
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: LoginManager.sharedInstance.getHeader()).responseString(completionHandler: {
            response in
            switch response.result {
            case .success:
                if let statusesArray = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [[String: Any]] {
                    // Finally we got the username
                    self.blockUserArray = statusesArray!
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Tableview Delegate & Datasource
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return blockUserArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Instantiate a cell
        let cell : BlockTableViewCell
        
        if(blockUserArray[indexPath.row]["accountLevel"] as! String == "GENERAL") {
             cell = self.tableView.dequeueReusableCell(withIdentifier: "GeneralCell", for: indexPath) as! BlockTableViewCell
        } else {
             cell = self.tableView.dequeueReusableCell(withIdentifier: "OfficialCell", for: indexPath) as! BlockTableViewCell
        }
        
        cell.nicNameLabel.text = blockUserArray[indexPath.row]["nickName"] as? String
        if(blockUserArray[indexPath.row]["profile"] != nil) {
            let url = NSURL(string: (blockUserArray[indexPath.row]["profile"] as? String)!)
            cell.profileImageView.af_setImage(withURL: url! as URL)
        }
        
        
        return cell;
    }

}

class BlockTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicNameLabel: UILabel!
    @IBOutlet weak var unBlockButton: UIButton!
    @IBOutlet weak var officialImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func unBlockUser(_ sender: UIButton) {
        let parameters : Parameters = [
            "blocked": false,
            "userId" : ""
        ]
        
        let uri = Constants.VyrlAPIConstants.baseURL + "my/block"
        
        Alamofire.request(uri, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: LoginManager.sharedInstance.getHeader()).responseString(completionHandler: {
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
