//
//   SMLoginViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 5. 22..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class SMLoginViewController : UIViewController {
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var SMLoginLabel: UILabel!
    override func viewDidLoad() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func dismiss(sender :AnyObject )
    {
        self.dismiss(animated: true, completion: nil);
    }
}
