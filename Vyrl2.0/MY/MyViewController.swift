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
import SwiftyJSON


class MyViewController: UIViewController{
    
    @IBOutlet weak var dropTableView: UIView!
    
    @IBOutlet weak var accountTable: UITableView!
    
    @IBOutlet weak var footer: UIView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var emptyView: UIView!
    
    var accountList  = [Account]()
    
    var isMyProfile = true
    
    var profileUserId : Int! {
        didSet {
            isMyProfile = false
        }
    }
    
    var postCount = 0
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var homepageLabel: UILabel!
    
    @IBOutlet weak var storeBtn: UIButton!
    
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var post: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var follower: UILabel!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var accountSelect: SmallButton!
    @IBOutlet weak var bookMakrBtn: UIButton!
    @IBOutlet weak var middlePostBtn: UILabel!
    
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
        
        if self.isMyProfile == true {
            self.setupFeed(feedType: FeedTableType.MYFEED)
            self.accountSelect.isHidden = false
            self.bottomSpace.constant = 45
            self.bookMakrBtn.isHidden = false
        }else {
            self.storeBtn.setImage(UIImage.init(named: "icon_back_01"), for: .normal)
            self.storeBtn.addTarget(self, action: #selector(back(sender:)), for: .touchUpInside)
            self.setupFeed(feedType: FeedTableType.USERFEED)
            self.bottomSpace.constant = 0
            self.accountSelect.isHidden = true
            self.bookMakrBtn.isHidden = true
        }
    }
    
    func back(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupPostContainer(){
        let storyboard = UIStoryboard(name: "PostCollectionViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PostCollection")
        
        self.childViewControllers.last?.willMove(toParentViewController: nil)
        self.childViewControllers.last?.view.removeFromSuperview()
        self.childViewControllers.last?.removeFromParentViewController()
        addChildViewController(controller)
        containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    func setupFeed(feedType : FeedTableType){
        let storyboard = UIStoryboard(name: "FeedStyle", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "feedTable") as! FeedTableViewController
        
        controller.feedType = feedType
        controller.userId = profileUserId
        controller.isEnableUpload = false
        controller.removeFromParentViewController()
        
        self.childViewControllers.last?.willMove(toParentViewController: nil)
        self.childViewControllers.last?.view.removeFromSuperview()
        self.childViewControllers.last?.removeFromParentViewController()
        
        controller.view.frame.size.height = containerView.frame.height
        
        addChildViewController(controller)
        
        containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadMyProfile()
    }
    
    func refreshMyAccout(){
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
    }
    
    func getProfile(){
        var uri = Constants.VyrlAPIURL.MYPROFILE
        
        if self.isMyProfile == false {
            uri = Constants.VyrlAPIURL.userProfile(userId: self.profileUserId)
        }
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON(completionHandler: {
            response in
            
            switch response.result {
            case .success(let json):
                
                if let code = response.response?.statusCode {
                    if code == 200 {
                        
                        let json = JSON(json)
                        
                        self.nickNameLabel.text = json["nickName"].string
                        self.introLabel.text = json["selfIntro"].string
                        self.homepageLabel.text = json["homepageUrl"].string
                        let image = json["imagePath"].string
                        
                        if image?.isEmpty == false {
                            let url = URL.init(string: (image)!)
                            self.profileImage.af_setImage(withURL: url!)
                        } else {
                            self.profileImage.image = UIImage.init(named: "icon_user_03")
                        }
                        
                        if self.isMyProfile {
                            let account = LoginManager.sharedInstance.getCurrentAccount()
                            
                            account?.nickName = json["nickName"].string
                            account?.imagePath = json["imagePath"].string
                            
                            LoginManager.sharedInstance.replaceAccount(account: account!)
                        }else {
                            self.titleLbl.text = json["nickName"].string
                        }
                        
                        self.post.text = "\(json["articleCount"].intValue)"
                        self.postCount = json["articleCount"].intValue
                        
                        if self.postCount == 0 {
                            self.emptyView.alpha = 1
                        }else {
                            self.emptyView.alpha = 0
                        }
                        
                        self.following.text = "\(json["followingCount"].intValue)"
                        self.follower.text = "\(json["followerCount"].intValue)"
                    }
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func loadMyProfile(){
        
        if self.isMyProfile {
            self.refreshMyAccout()
        }
        
        self.getProfile()
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
    
    @IBAction func showAccountManagement(_ sender: Any) {
        self.pushView(storyboardName: "Setting", controllerName: "AccountManagement")
    }
    
    @IBAction func showFeed(_ sender: Any) {
        self.setupFeed(feedType: FeedTableType.ALLFEED)
    }
    
    @IBAction func showPost(_ sender: Any) {
        self.setupPostContainer()
    }
    
    @IBAction func showBookmark(_ sender: Any) {
        self.setupFeed(feedType: FeedTableType.BOOKMARK)
    }
}

extension MyViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return accountList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
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
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return footer
    }
}

extension MyViewController : FeedCellDelegate {
    
    func didPressCell(sender: Any, cell : FeedTableCell) {
        self.pushView(storyboardName: "FeedDetail", controllerName: "FeedDetailViewController")
    }
}

class MyAccountCell : UITableViewCell{
    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var iconCheck: UIImageView!
    @IBOutlet weak var iconDot: UIImageView!
    
}
