//
//  TermsOfUseViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 7. 11..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TermsOfUseViewController: UIViewController {
    @IBOutlet weak var termsTextView: UITextView!

    var type : TermsType = .Use
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getTermsOfUse()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getTermsOfUse() {
        let uri = Constants.VyrlAPIConstants.baseURL + "/terms/USE/KO"
        
        Alamofire.request(uri, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: Constants.VyrlAPIConstants.getHeader()).responseJSON(completionHandler: {
            response in
            
            switch response.result {
            case .success(let data):
                print(data)
                let json = JSON(data)
                if let result = json["content"].string {
                    self.termsTextView.attributedText = self.stringFromHtml(string: result)
                }
            case .failure(let error):
                print(error)
            }
        })

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    private func stringFromHtml(string: String) -> NSAttributedString? {
        do {
            let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
            if let d = data {
                let str = try NSAttributedString(data: d,
                                                 options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                 documentAttributes: nil)
                return str
            }
        } catch {
        }
        return nil
    }

}

enum TermsType {
    case Privacy, Use, Operation
}

