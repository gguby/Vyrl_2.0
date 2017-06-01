//
//  WriteViewController.swift
//  Vyrl2.0
//
//  Created by wsjung on 2017. 6. 1..
//  Copyright © 2017년 smt. All rights reserved.
//

import Foundation

class WriteViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerSwipe()
        
        self.tabBarItem.image = UIImage(named: "icon_write_01")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
    }
    
}
