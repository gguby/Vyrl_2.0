//
//  OtherProfileViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 9. 1..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class OtherProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var homepageLabel: UILabel!
    
    @IBOutlet weak var post: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var follower: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var middlePostBtn: UILabel!
    
    var profileUserId : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func setupPostContainer(){
        let storyboard = UIStoryboard(name: "PostCollectionViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PostCollection")
        
        controller.removeFromParentViewController()
        controller.view.removeFromSuperview()
        
        addChildViewController(controller)
        containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }

    func setupFeed(feedType : FeedTableType){
        let storyboard = UIStoryboard(name: "FeedStyle", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "feedTable") as! FeedTableViewController
        
        controller.feedType = feedType
        controller.userId = profileUserId
        controller.removeFromParentViewController()
        controller.view.removeFromSuperview()
        
        addChildViewController(controller)
        
        containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadUserProfile()
    }
    
    func getProfile(){
        var uri = Constants.VyrlAPIURL.MYPROFILE
        
        uri = Constants.VyrlAPIURL.userProfile(userId: self.profileUserId)
        
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
                        
                        let image = jsonData["imagePath"] as? String
                        
                        if image?.isEmpty == false {
                            let url = URL.init(string: (image)!)
                            self.profileImage.af_setImage(withURL: url!)
                        }
                    }
                }
                
                print((response.response?.statusCode)!)
                print(json)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func loadUserProfile(){
        
         self.getProfile()
    }
    
    @IBAction func showFeed(_ sender: Any) {
        self.setupFeed(feedType: FeedTableType.ALLFEED)
    }
    
    @IBAction func showPost(_ sender: Any) {
        self.setupPostContainer()
    }
}

extension OtherProfileViewController : FeedCellDelegate {
    func didPressCell(sender: Any, cell : FeedTableCell) {
        self.pushView(storyboardName: "FeedDetail", controllerName: "FeedDetailViewController")
    }
}
