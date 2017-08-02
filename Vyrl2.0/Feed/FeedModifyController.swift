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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.delegate = self
        self.enabledBtnSave(enabled: !self.textView.text.isEmpty)
        
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
    }
}

extension FeedModifyController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let chracterCount = textView.text?.characters.count ?? 0
        
        if (range.length + range.location > chracterCount){
            return false
        }
        
        let textLength = chracterCount + text.characters.count - range.length
        
        self.enabledBtnSave(enabled: textLength > 0)
        
        return true
    }
}
