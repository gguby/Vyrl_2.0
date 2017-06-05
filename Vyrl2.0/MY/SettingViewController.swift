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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.delegate = self
//        scrollView.frame = CGRect(x: scrollView.contentOffset.x, y:scrollView.contentOffset.y, width:scrollView.frame.size.width, height: scrollView.frame.size.height)
        
        self.contentHeight.constant = 220
        
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
      let alert = UIAlertController(title: "Alert", message: "자주 묻는 질문", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
    @IBAction func showDataUsageView(_ sender: UIButton) {
      let alert = UIAlertController(title: "Alert", message: "데이터 사용 여부", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
    
    //terms of use
    @IBAction func showTermsofUseServiceView(_ sender: UIButton) {
      let alert = UIAlertController(title: "Alert", message: "서비스 이용 약관", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
    }
    @IBAction func showTermsofUseOfficialFanclubView(_ sender: UIButton) {
        self.pushView(storyboardName: "Setting", controllerName: "OfficialFanClubTerms")
    }
    @IBAction func showPrivacyPolicyView(_ sender: UIButton) {
      let alert = UIAlertController(title: "Alert", message: "개인정보 처리방침", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
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
