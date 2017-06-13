//
//  FeedDetailViewController.swift
//  Vyrl2.0
//
//  Created by  KoMyeongbu on 2017. 6. 13..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class FeedDetailViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentTextFieldBottomConstraint: NSLayoutConstraint!
    var kbHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 400
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.reloadData()
        
        self.commentTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardShow(notification: NSNotification) {
//        var userInfo = notification.userInfo!
//        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
//        let changeInHeight = (keyboardFrame.height) * 1
//        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
//            let index = IndexPath(row: 9, section: 0)
//            self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
////            self.commentTextFieldBottomConstraint.constant += changeInHeight
//             self.commentTextFieldBottomConstraint.constant += 200
//        })
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                kbHeight = keyboardSize.height
                self.animateTextField(up: true)
                let index = IndexPath(row: 9, section: 0)
                self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
            }
        }
    }
    
    func keyboardHide(notification: NSNotification) {
//        var userInfo = notification.userInfo!
//        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
//         UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
//            self.commentTextFieldBottomConstraint.constant = 0
//        })
        self.animateTextField(up: false)
    }
    
    func animateTextField(up: Bool) {
        var movement = (up ? -kbHeight : kbHeight)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement!)
        })
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

extension FeedDetailViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

class FeedDetailTableCell : UITableViewCell {
    
    
    
}
