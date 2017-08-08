//
//  FanPageController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 8. 7..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation


class FanPageController : UIViewController {
    
    var fanPage : FanPage!
    
    @IBOutlet weak var pageImage: UIImageView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var pageName: UILabel!
    
    @IBOutlet weak var signUpOrWithDraw: UIButton!
    @IBOutlet weak var pageIntro: UILabel!
    @IBOutlet weak var members: UIButton!
    
    @IBOutlet weak var feedView: UIView!
    @IBOutlet weak var noFeedView: UIView!
    
    @IBOutlet weak var feedContainer: UIView!
    @IBOutlet weak var post: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.initPage()
        
        self.setupFeed()
    }
    
    func setupFeed(){
        let storyboard = UIStoryboard(name: "FeedStyle", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "feedTable") as! FeedTableViewController
        addChildViewController(controller)
        feedContainer.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
        controller.resizeTable(height: feedContainer.frame.height)
    }
    
    func initPage() {
        if fanPage.level == "OWNER" {
            self.signUpOrWithDraw.setTitle("탈퇴하기", for: .normal)
            self.signUpOrWithDraw.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
            self.feedView.alpha = 1
            self.noFeedView.alpha = 0
        }else {
            self.signUpOrWithDraw.setTitle("가입하기", for: .normal)
            self.signUpOrWithDraw.backgroundColor = UIColor.ivLighterPurple
            self.feedView.alpha = 0
            self.noFeedView.alpha = 1
        }
        
        self.ownerLabel.text = fanPage.nickName + "님 개설"
        self.pageImage.af_setImage(withURL: URL.init(string: fanPage.pageprofileImagePath)!)
        self.pageName.text = fanPage.pageName
        
        if (fanPage.pageInfo) != nil {
            self.pageIntro.text = fanPage.pageInfo
        }
        
        var str = "\(fanPage.cntMember!) members"
        self.members.setTitle(str, for: .normal)
        
        str = "\(fanPage.cntPost!) posts"
        self.post.text = str
        
    }
    
    @IBAction func sortList(_ sender: Any) {
    }
    
    @IBAction func sortCollection(_ sender: Any) {
    }
    
    @IBAction func fanPageSetting(_ sender: Any) {
    }
}
