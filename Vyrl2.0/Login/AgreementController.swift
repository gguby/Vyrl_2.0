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
    
        persnalCheckBox.delegate = self
        serviceCheckBox.delegate = self
        
        btnClose.backgroundColor = UIColor.ivGreyish
        btnClose.isEnabled = false;
        
        let bottomOffset = CGPoint.init(x: 0, y: persnalTextView.contentSize.height - persnalTextView.bounds.size.height)
        persnalTextView.setContentOffset(bottomOffset, animated: true)
        
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
            btnClose.isEnabled = true
        }
        else
        {
            btnClose.backgroundColor = UIColor.ivGreyish
            btnClose.isEnabled = false
        }
    }
}
