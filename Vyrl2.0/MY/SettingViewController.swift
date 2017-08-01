//
//  SettingViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 5. 29..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!

    @IBOutlet weak var socialLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.delegate = self
        
        self.contentHeight.constant = 220
        
        let account : Account = LoginManager.sharedInstance.getCurrentAccount()!
        
        socialLabel.text = account.service! + " 로그인 중"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //account
    @IBAction func showAccountManagementView(_ sender: Any) {
        self.pushView(storyboardName: "Setting", controllerName: "AccountManagement")
    }
    @IBAction func showBlockManagementView(_ sender: Any) {
        self.pushView(storyboardName: "Setting", controllerName: "BlockManagement")
    }
    
    //service management
    @IBAction func showNotificationManagementView(_ sender: UIButton) {
        self.pushView(storyboardName: "Setting", controllerName: "NotificationManagement")
    }
    @IBAction func showOfficialFanclubManagementView(_ sender: UIButton) {
        self.pushView(storyboardName: "Setting", controllerName: "FanclubManagement")
    }
    
    //customer support
    @IBAction func showNoticeView()
    {
        self.pushView(storyboardName: "Setting", controllerName: "notice")
    }
    
    @IBAction func showFAQView(_ sender: UIButton) {
        let vc : NoticeController = self.pushViewControllrer(storyboardName: "Setting", controllerName: "notice") as! NoticeController
        vc.isNoticeType = false;
    }
    
    @IBAction func showDataUsageView(_ sender: UIButton) {
      let alert = UIAlertController(title: "Alert", message: "데이터 사용 여부", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
    
    //terms of use
    @IBAction func showTermsofUseServiceView(_ sender: UIButton) {
      let view : TermsOfUseViewController = self.pushViewControllrer(storyboardName: "Setting", controllerName: "ServiceTerms") as! TermsOfUseViewController
        view.type = .Use
    }
    
    @IBAction func showTermsofUseOfficialFanclubView(_ sender: UIButton) {
        self.pushView(storyboardName: "Setting", controllerName: "OfficialFanClubTerms")
    }
    
    @IBAction func showPrivacyPolicyView(_ sender: UIButton) {
    let view : TermsOfUseViewController = self.pushViewControllrer(storyboardName: "Setting", controllerName: "ServiceTerms") as! TermsOfUseViewController
        view.type = .Privacy
    } 
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    /*
    // MARK : ScrollView Delegate
    */
    
}
