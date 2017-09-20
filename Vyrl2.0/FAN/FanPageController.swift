//
//  FanPageController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 8. 7..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation
import Alamofire

protocol FanPagePostDelegate {
    func upload(query: URL, array : Array<AVAsset>)
    func reloadFanPage()
}

class FanPageController : UIViewController {
    
    var fanPage : FanPage!
    var fanPageId : Int!
    
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
    
    @IBOutlet weak var writeBtn: UIButton!
    
    var delegate : FanViewControllerDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupFeed()
        
        self.reloadFanPage()
        
        self.writeBtn.addTarget(self, action: #selector(self.writePost(_:)), for: .touchUpInside)
    }
    
    func setupFeed(){
        let storyboard = UIStoryboard(name: "FeedStyle", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "feedTable") as! FeedTableViewController
        controller.feedType = .FANFEED
        controller.fanPageId = self.fanPageId
        controller.fanPageViewController = self
        controller.isEnableUpload = true
        addChildViewController(controller)
        
        controller.view.frame.size.height = feedContainer.frame.height
        feedContainer.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    func initPage() {
        if fanPage.level == "GUEST" {
            self.signUpOrWithDraw.setTitle("가입하기", for: .normal)
            self.signUpOrWithDraw.backgroundColor = UIColor.ivLighterPurple
            
            self.signUpOrWithDraw.addTarget(self, action: #selector(joinFanPage), for: .touchUpInside)
            
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
            self.noFeedBtn.addTarget(self, action: #selector(self.writePost(_:)), for: .touchUpInside)
            
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
            self.writeBtn.alpha = 0
        }
        else {
            self.feedView.alpha = 1
            self.noFeedView.alpha = 0
            self.writeBtn.alpha = 1            
        }
    }
    
    func showJoinAlert(fanPageId : Int){
        let alertController = UIAlertController (title:nil, message:"팬 페이지 가입 후 이용 가능합니다. 가입하시겠습니까?",preferredStyle:.alert)
        let ok = UIAlertAction(title: "네", style: .default, handler: { (action) -> Void in
            self.joinFanPage()
        })
        let cancel = UIAlertAction(title: "아니오", style: .cancel, handler: { (action) -> Void in
        })
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    func writePost(_ sender:UIButton){
        
        if fanPage.level == "GUEST" {
            self.showJoinAlert(fanPageId: self.fanPageId)
            return
        }
        
        let storyboard = UIStoryboard(name:"Write", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "writenavi") as? UINavigationController
        let controller =  vc?.topViewController as! WriteViewController
        controller.fanPage = self.fanPage
        controller.fanPagePostDelegate = self
        self.present(vc!, animated: true, completion: nil)
    }
    
    func shareAlert(){
        let alertController = UIAlertController (title:"어떻게 공유하시겠어요?", message:nil,preferredStyle:.alert)
        
        let share = UIAlertAction(title: "링크복사", style: .default,handler: { (action) -> Void in
            let uri = Constants.VyrlFeedURL.share(articleId: (self.fanPage.fanPageId)!)
            
            Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON(completionHandler: {
                response in
                switch response.result {
                case .success(let json) :
                    print(json)
                    
                    if let code = response.response?.statusCode {
                        if code == 200 {
                            let jsonData = json as! NSDictionary
                            
                            let url = jsonData["url"] as! String
                            
                            UIPasteboard.general.string = url
                            self.showToast(str: url)
                        }
                    }
                case .failure(let error) :
                    print(error)
                }
            })
        })
        
        let push = UIAlertAction(title: "내 Feed에서 공유", style: .default, handler: { (action) -> Void in
            
        })
        
        alertController.addAction(share)
        alertController.addAction(push)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func pushFanPage(){
        let uri = URL.init(string: Constants.VyrlFanAPIURL.fanPagePush(fanPageId: self.fanPage.fanPageId))
        Alamofire.request(uri!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                let jsonData = json as! NSDictionary
                
                let result = jsonData["result"] as? Bool
                
                if result == true {
                    
                }

            case .failure(let error):
                print(error)
            }
        }
    }
    
    func showDetailFanPage(_ sender:UIButton){
        
        let alertController = UIAlertController (title:nil, message:nil,preferredStyle:.actionSheet)
        
        let share = UIAlertAction(title: "공유하기", style: .default,handler: { (action) -> Void in
            self.shareAlert()
        })
        
        var str = "알림켜기"
        var content = "이 페이지의 모든 글을 알림으로 받으시겠습니까?"
        if self.fanPage.isAlarm == true {
            str = "알림끄기"
            content = "이 유저의 모든 글 알림을 끊습니다."
        }
        
        let push = UIAlertAction(title: str, style: .default, handler: { (action) -> Void in
            let alertController = UIAlertController (title:content, message:nil,preferredStyle:.alert)
            let ok = UIAlertAction(title: "네", style: .default, handler: { (action) -> Void in
                self.pushFanPage()
            })
            let cancel = UIAlertAction(title: "아니오", style: .cancel, handler: { (action) -> Void in
            })            
            
            alertController.addAction(ok)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(share)
        alertController.addAction(push)
        
        
        if fanPage.level == "OWNER" {
            let setting = UIAlertAction(title: "설정", style: .default, handler: { (action) -> Void in
                let vc = self.pushViewControllrer(storyboardName: "Fan", controllerName: "FanSetting") as! FanSettingViewController
                vc.fanPage = self.fanPage
                vc.fanPageView = self
            })
            
            alertController.addAction(setting)
            
        } else {
            
            let report = UIAlertAction(title: "신고하기", style: .default, handler: { (action) -> Void in
                let vc = self.pushViewControllrer(storyboardName: "Fan", controllerName: "Report") as! FanPageReportViewController
                vc.fanPage = self.fanPage
            })
            
            alertController.addAction(report)
        }
        
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func joinFanPage(){
        
        let uri = URL.init(string: Constants.VyrlFanAPIURL.joinFanPage(fanPageId: self.fanPage.fanPageId))
        Alamofire.request(uri!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                self.showToast(str: "가입되었습니다.")
                self.reloadFanPage()
                self.delegate?.refresh()
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
                
                self.showToast(str: "탈퇴되었습니다")
                self.reloadFanPage()
                self.delegate?.refresh()
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
    
    @IBAction func showMemberList(_ sender: UIButton) {
        
        let vc = self.pushViewControllrer(storyboardName: "FanDetail", controllerName: "MemberList") as! FanPageMemberListViewController
        vc.fanPage = self.fanPage

    }
    
}

extension FanPageController : FanPagePostDelegate {
    
    func reloadFanPage(){
        
        self.showLoading(show: true)
        
        let uri = URL.init(string: Constants.VyrlFanAPIURL.fanPage(fanPageId: self.fanPageId))
        
        Alamofire.request(uri!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseObject { (response: DataResponse<FanPage>) in
            self.fanPage = response.result.value
            
            self.initPage()
            
            let vc = self.childViewControllers[0] as! FeedTableViewController
            vc.getAllFeed()
            
            self.showLoading(show: false)
        }
    }

    func upload(query: URL, array : Array<AVAsset>){
        
        var fileName : String!
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            var count = 1
            
            for asset in array {
                
                if asset.type == .photo {
                    fileName = "\(count)" + ".jpg"
                    
                    if let imageData = asset.mediaData {
                        multipartFormData.append(imageData, withName: "files", fileName: fileName, mimeType: "image/jpg")
                    }
                    
                } else if asset.type == .gif {
                    fileName = "\(count)" + ".gif"
                    if let imageData = asset.mediaData {
                        multipartFormData.append(imageData, withName: "files", fileName: fileName, mimeType: "image/gif")
                    }
                }
                else {
                    fileName = "\(count)" + ".mpeg"
                    
                    if let imageData = asset.mediaData {
                        multipartFormData.append(imageData, withName: "files", fileName: fileName, mimeType: "video/mpeg")
                    }
                }
                
                count = count + 1
            }
            
        }, usingThreshold: UInt64.init(), to: query, method: .post, headers: Constants.VyrlAPIConstants.getHeader(), encodingCompletion:
            {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                    })
                    
                    upload.responseString { response in
                        
                        if ((response.response?.statusCode)! == 200){
                            self.reloadFanPage()
                        }
                        
                    }
                case .failure(let encodingError):
                    print(encodingError.localizedDescription)
                }
        })
    }
}
