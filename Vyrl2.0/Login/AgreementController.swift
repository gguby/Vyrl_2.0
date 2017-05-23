//
//  File.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 22..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class AgreeMentController : UIViewController, checkBoxDelegate {
    
    @IBOutlet weak var btnClose: UIButton!

    @IBOutlet weak var persnalCheckBox: CheckBox!
    @IBOutlet weak var serviceCheckBox: CheckBox!
    
    @IBOutlet weak var agreeLabel01: UILabel!
    @IBOutlet weak var agreeLabel02: UILabel!
    
    @IBOutlet weak var serviceTextView: UITextView!
    @IBOutlet weak var persnalTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceCheckBox.label = agreeLabel01
        persnalCheckBox.label = agreeLabel02        
        
        serviceTextView.textContainer.lineFragmentPadding = 0
        serviceTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        persnalTextView.textContainer.lineFragmentPadding = 0
        persnalTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        persnalCheckBox.delegate = self
        serviceCheckBox.delegate = self
        
        btnClose.backgroundColor = UIColor.ivGreyish
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func dismiss(sender :AnyObject )
    {
        self.dismiss(animated: true, completion: nil);
    }
    
    func respondCheckBox(checkBox: CheckBox) {
        if ( persnalCheckBox.isChecked && serviceCheckBox.isChecked )
        {
            btnClose.backgroundColor = UIColor.hexStringToUIColor(hex: "#8052F5")
        }
        else
        {
            btnClose.backgroundColor = UIColor.ivGreyish
        }
    }
}
