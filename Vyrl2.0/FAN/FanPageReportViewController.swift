//
//  FanPageReportViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 9. 4..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire

class FanPageReportViewController: UIViewController {

    @IBOutlet weak var fanPageName: UILabel!
    @IBOutlet weak var reportContentTextfield: UITextField!
    
    var fanPage : FanPage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.fanPageName.text = fanPage.pageName
    }

   
    @IBAction func reportButtonClick(_ sender: UIButton) {
        self.reportsFanpage()
    }
    
    func reportsFanpage(){
        let uri = URL.init(string: Constants.VyrlFanAPIURL.reportFanPage())
        
        let parameters : Parameters = [
            "fanPageId": self.fanPage.fanPageId,
            "report": self.reportContentTextfield.text,]
        
        Alamofire.request(uri!, method: .post, parameters: parameters as! [String : String], encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON { (response) in
            
        }
        
    }


}
