//
//  FeedDetailViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 13..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit
import GrowingTextView

class FeedDetailViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
  
    @IBOutlet weak var commentFieldView: UIView!
    @IBOutlet weak var buttonView: UIView!
    
    
    var kbHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func commentButtonclick(_ sender: UIButton) {
        self.commentFieldView.isHidden = false
        self.commentTextView.becomeFirstResponder()
        self.buttonView.isHidden = true
    }
    @IBAction func postButtonClick(_ sender: UIButton) {
        self.commentFieldView.isHidden = true
        self.commentTextView.text = ""
        self.commentTextView.resignFirstResponder()
        self.buttonView.isHidden = false
    }
    
    func keyboardShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                kbHeight = keyboardSize.height
                self.animateTextField(up: true)
                let index = IndexPath(row: 9, section: 0)
                self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
            }
        }
//        let endFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        bottomConstraint.constant = UIScreen.main.bounds.height - endFrame.origin.y
//        self.view.layoutIfNeeded()
    }
    
    func keyboardHide(notification: NSNotification) {
        self.animateTextField(up: false)
    }
    
    func animateTextField(up: Bool) {
        var movement = (up ? -kbHeight : kbHeight)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement!)
        })
    }
    
    func tapGestureHandler() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell :FeedDetailTableCell = tableView.dequeueReusableCell(withIdentifier: "oneFeed") as! FeedDetailTableCell
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "oneFeed") as! FeedDetailTableCell
            break
       
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "Comment") as! FeedDetailTableCell
            break
        }
        
        return cell
    }


}

extension FeedDetailViewController : GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

class FeedDetailTableCell : UITableViewCell {
    
    
    
}
