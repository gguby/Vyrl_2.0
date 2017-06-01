//
//  MyViewController.swift
//  Vyrl2.0
//
//  Created by user on 2017. 5. 18..
//  Copyright © 2017년 smt. All rights reserved.
//

import UIKit

class MyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        registerSwipe()
        print("My");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showSetting(){
        self.pushView(storyboardName: "My", controllerName: "setting")
    }
    


}
