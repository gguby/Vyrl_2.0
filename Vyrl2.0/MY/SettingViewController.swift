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
    
    
    @IBAction func showNoticeView()
    {
        self.pushView(storyboardName: "Setting", controllerName: "notice")
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
