//
//  FeedModifyController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 8. 2..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation


class FeedModifyController : UIViewController
{
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var btnSave: UIButton!
    
    var articleId : Int!
    var originText : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.delegate = self
        self.enabledBtnSave(enabled: false)
        
        self.textView.becomeFirstResponder()
    }
    
    func enabledBtnSave(enabled : Bool){
        self.btnSave.isEnabled = enabled
        if enabled {
            self.btnSave.setTitleColor(UIColor.ivLighterPurple, for: .normal)
        } else {
            self.btnSave.setTitleColor(UIColor.ivGreyish, for: .normal)
        }
    }
    
    @IBAction func save(_ sender: Any) {
        self.textView.resignFirstResponder()
        
        let parameters :[String:String] = [
            "content": textView.text
        ]
        
        let uri = Constants.VyrlFeedURL.feed(articleId: self.articleId)
        
        let queryUrl = URL.init(string: uri, parameters: parameters)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.feedView.uploadPatch(query: queryUrl!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setText(text :String){
        self.textView.text = text
        originText = text
    }
}

extension FeedModifyController : UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView){
        let enable = self.originText != textView.text && textView.text.isEmpty == false
        self.enabledBtnSave(enabled: enable)
    }
}
