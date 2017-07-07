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
    
    @IBAction func openEmoticon(_ sender: UIButton) {
        
//        let tempWindow = UIApplication.shared.windows[1]
//        let keyboard : UIView
//        
//        for(int i = 0; i < tempWindow.subviews.count; i++)
//        {
//            keyboard = tempWindow.subviews[i]
//            
//            if(keyboard.description.hasPrefix("UIKeyboard") == true)
//            {
//                keyboard.bringSubview(toFront: self.tableView)
//            }
//        }
        
        let keyboard = UIApplication.shared.windows[1]
        
        
        
    }
 
    @IBAction func postButtonClick(_ sender: UIButton) {
        self.commentFieldView.isHidden = true
        self.commentTextView.text = ""
        self.commentTextView.resignFirstResponder()
        self.buttonView.isHidden = false
    }
    
    func keyboardShow(notification: NSNotification) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }

        
         if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
            
            
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }

    }
    
    func keyboardHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        } else {
            debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
        }
    }
    
    func tapGestureHandler() {
        view.endEditing(true)
        self.commentFieldView.isHidden = true
        self.buttonView.isHidden = false
        
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
