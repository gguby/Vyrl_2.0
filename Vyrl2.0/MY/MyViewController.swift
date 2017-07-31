//
//  MyViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class MyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var dropTableView: UIView!
    
    @IBOutlet weak var accountTable: UITableView!
    
    @IBOutlet weak var feedTable: UITableView!
  
    @IBOutlet weak var footer: UIView!
    
    var accountList  = [Account]()
    var articleArray = [Article]()    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var homepageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerSwipe()
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.borderWidth = 1.0
        
        self.accountTable.delegate = self
        self.accountTable.dataSource = self
        self.accountTable.rowHeight = 50
        
        self.setupFeedTable()
        
        self.getAllFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadMyProfile()
    }
    
    func loadMyProfile(){
        
        self.accountList.removeAll()
        
        self.accountList.append(LoginManager.sharedInstance.getCurrentAccount()!)
        
        for account in LoginManager.sharedInstance.includeNotCurrentUser(){
            self.accountList.append(account)
        }
        
        self.accountTable.reloadData()
        
        let currentAccount = LoginManager.sharedInstance.getCurrentAccount()
        
        if let image = UserDefaults.standard.image(forKey: (currentAccount?.userId)!){
            self.profileImage.image = image;
        }else{
            if let imagePath = currentAccount?.imagePath {
                
                Alamofire.request(imagePath).responseImage { response in
                    if let responseImg = response.result.value {
                        
                        self.profileImage.image = responseImg;
                        UserDefaults.standard.set(image: responseImg, forKey: (currentAccount?.userId)!)
                    }
                }            
            }
        }
        
        let uri = Constants.VyrlAPIURL.MYPROFILE
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON(completionHandler: {
            response in
            
            switch response.result {
            case .success(let json):
                
                if let code = response.response?.statusCode {
                    if code == 200 {
                        let jsonData = json as! NSDictionary
                        
                        self.nickNameLabel.text = jsonData["nickName"] as? String
                        self.introLabel.text = jsonData["selfIntro"] as? String
                        self.homepageLabel.text = jsonData["homepageUrl"] as? String
                        
                        let account = LoginManager.sharedInstance.getCurrentAccount()
                        
                        account?.nickName = jsonData["nickName"] as? String
                        account?.imagePath = jsonData["imagePath"] as? String
                        
                        LoginManager.sharedInstance.replaceAccount(account: account!)
                        
                        let index = self.accountList.index(where :{ $0.userId == account?.userId })
                        if let index = index {
                            self.accountList[index] = account!
                        }
                        
                        guard let image = UserDefaults.standard.image(forKey: (currentAccount?.userId)!) else {
                            if(account?.imagePath != nil) {
                                let url = URL.init(string: (account?.imagePath)!)
                                self.profileImage.af_setImage(withURL: url!)
                            }
                            return
                        }
                        
                        self.profileImage.image = image
                    }
                }
                
                print((response.response?.statusCode)!)
                print(json)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showAccountSelectView(_ sender: Any) {
        
        UIView.transition(with: self.dropTableView, duration: 0.5, options: .transitionCrossDissolve, animations: { () -> Void in
            
            self.dropTableView.isHidden  = !self.dropTableView.isHidden
            self.tabBarController?.tabBar.isHidden = !self.dropTableView.isHidden
            
        }, completion: nil)
        
        self.accountTable.reloadData()
    }
    
    @IBAction func pushProfile(_ sender: Any) {
        self.pushView(storyboardName: "My", controllerName: "profile")
    }
    
    @IBAction func showSetting(){
        self.pushView(storyboardName: "My", controllerName: "setting")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == feedTable {
            return self.articleArray.count
        }
        
        return accountList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == feedTable {
            let article = self.articleArray[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: article.type.rawValue, for: indexPath) as! FeedTableCell

            cell.article = article
            cell.delegate = self
            cell.contentLabel.text = article.content
            
            return cell
        }
        
        let cell :MyAccountCell = tableView.dequeueReusableCell(withIdentifier: "myaccountcell") as! MyAccountCell
        
        let account : Account = accountList[indexPath.row]
        
        cell.name.text = account.nickName
        
        if ( UserDefaults.standard.image(forKey: account.userId!) == nil ){
            if let imagePath = account.imagePath {
                let url = URL.init(string: imagePath)
                cell.profileView.af_setImage(withURL: url!)
            }
        }else {
            if let image = UserDefaults.standard.image(forKey: account.userId!){
                cell.profileView.image = image
            }
        }
        
        let currentAccount : Account = LoginManager.sharedInstance.getCurrentAccount()!
        
        if ( account.userId == currentAccount.userId ){
            cell.iconCheck.image = UIImage(named: "icon_check_05_on")
            cell.iconDot.isHidden = true
            cell.name.textColor = UIColor.ivLighterPurple
        }
        else {
            cell.iconCheck.isHidden = true
            cell.iconDot.isHidden = false
            cell.name.textColor = UIColor.ivGreyishBrownTwo
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if ( tableView == feedTable ) {return}
        
        let account : Account = accountList[indexPath.row]
        
        let currentAccount : Account = LoginManager.sharedInstance.getCurrentAccount()!
        
        if ( account.userId == currentAccount.userId ){
            return
        }else {
            LoginManager.sharedInstance.changeCookie(account: account)
            
            self.dropTableView.isHidden  = true
            self.tabBarController?.tabBar.isHidden = !self.dropTableView.isHidden
            
            self.loadMyProfile()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if ( tableView == feedTable ) {return 0}
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if ( tableView == feedTable ) {return nil}
        
        return footer
    }

    @IBAction func showAccountManagement(_ sender: Any) {
        self.pushView(storyboardName: "Setting", controllerName: "AccountManagement")
    }
}

extension MyViewController : YourCellDelegate {
    func didPressCell(sender: Any) {
        self.pushView(storyboardName: "FeedStyle", controllerName: "FeedDetailViewController")
    }
    
    func setupFeedTable(){
        self.feedTable.delegate = self
        self.feedTable.dataSource = self
        self.feedTable.rowHeight = UITableViewAutomaticDimension
        self.feedTable.estimatedRowHeight = 400
    }
    
    func getAllFeed(){
        self.articleArray.removeAll()
        
        let url = URL.init(string: Constants.VyrlFeedURL.FEED)
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseArray { (response: DataResponse<[Article]>) in
            
            let array = response.result.value ?? []
            
            for article in array {
                self.articleArray.append(article)
            }
            
            DispatchQueue.main.async {
                self.feedTable.reloadData()
            }
        }
    }
}

class MyAccountCell : UITableViewCell{
    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var iconCheck: UIImageView!
    @IBOutlet weak var iconDot: UIImageView!
    
}
