//
//  FanPageController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 8. 7..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import Alamofire

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
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var noFeedTopLbl: UILabel!
    @IBOutlet weak var noFeedDownLbl: UILabel!
    
    @IBOutlet weak var noFeedBtn: UIButton!
    
    @IBOutlet weak var detailBtn: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.initPage()
    }
    
    func setupFeed(){
        let storyboard = UIStoryboard(name: "FeedStyle", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "feedTable") as! FeedTableViewController
        controller.feedType = .FANFEED
        controller.fanPageId = fanPage.fanPageId
        addChildViewController(controller)
        feedContainer.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    func initPage() {
        if fanPage.level == "GUEST" {
            self.signUpOrWithDraw.setTitle("가입하기", for: .normal)
            self.signUpOrWithDraw.backgroundColor = UIColor.ivLighterPurple
            
            self.signUpOrWithDraw.addTarget(self, action: #selector(joinFanPage(_:)), for: .touchUpInside)
            
            self.detailBtn.alpha = 0
        }else {
            self.signUpOrWithDraw.setTitle("탈퇴하기", for: .normal)
            self.signUpOrWithDraw.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
            self.feedView.alpha = 1
            self.noFeedView.alpha = 0
            
            self.signUpOrWithDraw.addTarget(self, action: #selector(withDrawFanPage(_:)), for: .touchUpInside)
            
            self.noFeedTopLbl.text = "팬페이지에 아직 글이 없습니다."
            self.noFeedDownLbl.text = "새 글을 작성해보세요~!"
            self.noFeedBtn.setTitle("글쓰기", for: .normal)
            
            self.detailBtn.alpha = 1
            self.detailBtn.addTarget(self, action: #selector(showDetailFanPage(_:)), for: .touchUpInside)
        }
        
        if fanPage.level == "OWNER" {
            self.signUpOrWithDraw.alpha = 0
        }
        
        self.ownerLabel.text = fanPage.nickName + "님 개설"
         if fanPage.pageprofileImagePath.isEmpty == false {
            self.pageImage.af_setImage(withURL: URL.init(string: fanPage.pageprofileImagePath!)!)
        }
        self.pageName.text = fanPage.pageName
        
        if (fanPage.pageInfo) != nil {
            self.pageIntro.text = fanPage.pageInfo
        }
        
        var str = "\(fanPage.cntMember!) members"
        self.members.setTitle(str, for: .normal)
        
        str = "\(fanPage.cntPost!) posts"
        self.post.text = str
        
        if fanPage.cntPost == 0 {
            self.feedView.alpha = 0
            self.noFeedView.alpha = 1
        }
        else {
            self.feedView.alpha = 1
            self.noFeedView.alpha = 0
            
            self.setupFeed()
        }
    }
    
    func showDetailFanPage(_ sender:UIButton){
        if fanPage.level == "OWNER" {
            let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
            
            let share = UIAlertAction(title: "공유하기", style: .default,handler: { (action) -> Void in
                
            })
            
            let push = UIAlertAction(title: "알림켜기", style: .default, handler: { (action) -> Void in
                
            })
            
            let setting = UIAlertAction(title: "설정", style: .default, handler: { (action) -> Void in
                let vc = self.pushViewControllrer(storyboardName: "Fan", controllerName: "FanSetting") as! FanSettingViewController
                vc.fanPage = self.fanPage
                vc.fanPageView = self
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                alertController.dismiss(animated: true, completion: nil)
            })
            
            alertController.addAction(share)
            alertController.addAction(push)
            alertController.addAction(setting)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
            
            let share = UIAlertAction(title: "공유하기", style: .default,handler: { (action) -> Void in
                
            })
            
            let push = UIAlertAction(title: "알림켜기", style: .default, handler: { (action) -> Void in
                
            })
            
            let report = UIAlertAction(title: "신고하기", style: .default, handler: { (action) -> Void in
                let vc = self.pushViewControllrer(storyboardName: "Fan", controllerName: "Report") as! FanPageReportViewController
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                alertController.dismiss(animated: true, completion: nil)
            })
            
            alertController.addAction(share)
            alertController.addAction(push)
            alertController.addAction(report)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true, completion: nil)

        }
    }
    
    func joinFanPage(_ sender: UIButton){
        
        let uri = URL.init(string: Constants.VyrlFanAPIURL.joinFanPage(fanPageId: self.fanPage.fanPageId))
        Alamofire.request(uri!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                print(json)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func withDrawFanPage(_ sender: UIButton){
        let uri = Constants.VyrlFanAPIURL.withdrawFanPage(fanPageId: self.fanPage.fanPageId)
        
        Alamofire.request(uri, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseString(completionHandler: {
            response in
            
            switch response.result {
            case .success(let json):
                
                print(json)
                
            case .failure(let error):
                print(error)
            }
        })
    }
    
    @IBAction func sortList(_ sender: Any) {
    }
    
    @IBAction func sortCollection(_ sender: Any) {
    }
    
    @IBAction func fanPageSetting(_ sender: Any) {
    }
    
    func reloadFanPage(){
        let uri = URL.init(string: Constants.VyrlFanAPIURL.fanPage(fanPageId: self.fanPage.fanPageId))
        
        Alamofire.request(uri!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseObject { (response: DataResponse<FanPage>) in
            self.fanPage = response.result.value
            
            self.initPage()
        }
    }
    
    func reportsFanpage(){
        let uri = URL.init(string: Constants.VyrlFanAPIURL.reportFanPage())
        
        let parameters : Parameters = [
            "fanPageId": self.fanPage.fanPageId,
            "report": "",]
        
        Alamofire.request(uri!, method: .post, parameters: parameters as! [String : String], encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON { (response) in
            
        }

    }
    
    @IBAction func showMemberList(_ sender: UIButton) {
        
        let vc = self.pushViewControllrer(storyboardName: "FanDetail", controllerName: "MemberList") as! FanPageMemberListViewController
        vc.fanPage = self.fanPage

    }
    
}
